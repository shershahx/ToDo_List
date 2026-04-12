import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/utils/colors.dart';

// ─── Riverpod State Notifiers ───────────────────────────────────────────────

/// Simple counter managed by Riverpod (mirrors CounterProvider).
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final counterProvider = StateNotifierProvider<CounterNotifier, int>(
  (ref) => CounterNotifier(),
);

/// A minimal task model for the demo.
class DemoTask {
  final String title;
  final bool done;
  const DemoTask({required this.title, this.done = false});
  DemoTask copyWith({String? title, bool? done}) =>
      DemoTask(title: title ?? this.title, done: done ?? this.done);
}

/// Task list managed by Riverpod (mirrors TaskProvider).
class TaskListNotifier extends StateNotifier<List<DemoTask>> {
  TaskListNotifier() : super([
    const DemoTask(title: 'Grab coffee beans from the local roaster', done: true),
    const DemoTask(title: 'Reply to Sarah about the weekend trip'),
    const DemoTask(title: 'Read chapter 4 of the design book'),
  ]);

  void add(String title) =>
      state = [...state, DemoTask(title: title.trim())];

  void toggle(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(done: !state[i].done) else state[i],
    ];
  }

  void delete(int index) =>
      state = [...state]..removeAt(index);
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<DemoTask>>(
  (ref) => TaskListNotifier(),
);

// Derived providers — Riverpod makes this trivially compile-safe
final pendingCountProvider = Provider<int>(
  (ref) => ref.watch(taskListProvider).where((t) => !t.done).length,
);

final doneCountProvider = Provider<int>(
  (ref) => ref.watch(taskListProvider).where((t) => t.done).length,
);

// ─── Screen ─────────────────────────────────────────────────────────────────

/// Entry point — wraps the demo in its own [ProviderScope] so it
/// stays independent from the app's Provider-based state.
class RiverpodDemoScreen extends StatelessWidget {
  const RiverpodDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: const _RiverpodDemoContent(),
    );
  }
}

class _RiverpodDemoContent extends ConsumerWidget {
  const _RiverpodDemoContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final tasks = ref.watch(taskListProvider);
    final pendingCount = ref.watch(pendingCountProvider);
    final doneCount = ref.watch(doneCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Riverpod Explorer',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Info banner ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.accent.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science_rounded, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Riverpod vs Provider',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _infoBullet('✓ Compile-safe — no runtime ProviderNotFoundException'),
                  _infoBullet('✓ No BuildContext needed to read state'),
                  _infoBullet('✓ Auto-dispose when listeners go away'),
                  _infoBullet('✓ Derived providers with zero boilerplate'),
                ],
              ),
            ),
          ),

          // ── Counter section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                'COUNTER DEMO',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Text(
                      '$counter',
                      key: ValueKey(counter),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Managed by StateNotifierProvider',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton(
                        icon: Icons.remove_rounded,
                        color: AppColors.error,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(counterProvider.notifier).decrement();
                        },
                      ),
                      const SizedBox(width: 16),
                      _actionButton(
                        icon: Icons.refresh_rounded,
                        color: AppColors.textSecondary,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(counterProvider.notifier).reset();
                        },
                      ),
                      const SizedBox(width: 16),
                      _actionButton(
                        icon: Icons.add_rounded,
                        color: AppColors.success,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(counterProvider.notifier).increment();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Task list section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Text(
                    'TASK LIST DEMO',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$doneCount done',
                      style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$pendingCount pending',
                      style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add task button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _AddTaskRow(
                onAdd: (title) => ref.read(taskListProvider.notifier).add(title),
              ),
            ),
          ),

          // Task items
          if (tasks.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 8),
                    Text(
                      'Add a task above to see Riverpod in action',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final task = tasks[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Dismissible(
                    key: ValueKey('riverpod_task_${task.title}_$i'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    ),
                    onDismissed: (_) => ref.read(taskListProvider.notifier).delete(i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: task.done
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(taskListProvider.notifier).toggle(i);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.done ? AppColors.success : Colors.transparent,
                              border: Border.all(
                                color: task.done ? AppColors.success : AppColors.textSecondary,
                                width: 2,
                              ),
                            ),
                            child: task.done
                                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            color: task.done
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            decoration: task.done ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: tasks.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ── Helpers ──

  static Widget _infoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }

  static Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}

/// Inline text field to add a task.
class _AddTaskRow extends StatefulWidget {
  final void Function(String title) onAdd;
  const _AddTaskRow({required this.onAdd});

  @override
  State<_AddTaskRow> createState() => _AddTaskRowState();
}

class _AddTaskRowState extends State<_AddTaskRow> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a task…',
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            onPressed: _submit,
            icon: const Icon(Icons.add_circle_rounded),
            color: AppColors.primary,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}
