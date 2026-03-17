import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:to_do_list/screens/counter_screen.dart';
import 'package:to_do_list/screens/login_screen.dart';
import 'package:to_do_list/utils/colors.dart';
import 'package:to_do_list/utils/notification_service.dart';
import 'package:to_do_list/utils/page_transitions.dart';
import 'package:to_do_list/utils/session_manager.dart';

enum _TaskFilter { all, pending, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<_Task> _tasks = [];
  late final AnimationController _emptyAnimController;
  late final Animation<double> _emptyPulse;
  late final Animation<Offset> _emptySlide;

  // Search & filter
  _TaskFilter _filter = _TaskFilter.all;
  String _searchQuery = '';
  bool _isSearchOpen = false;
  final _searchController = TextEditingController();

  // Onboarding
  bool _onboardingShown = false;

  String get _tasksKey => 'tasks_${SessionManager().currentEmail ?? 'default'}';
  String get _onboardingKey => 'onboarding_shown_${SessionManager().currentEmail ?? 'default'}';
  final _storage = const FlutterSecureStorage();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening 🌙';
  }

  @override
  void initState() {
    super.initState();
    NotificationService().init();
    _loadTasks();
    _checkOnboarding();

    _emptyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _emptyPulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _emptyAnimController, curve: Curves.easeInOut),
    );

    _emptySlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _emptyAnimController,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _emptyAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkOnboarding() async {
    final shownStr = await _storage.read(key: _onboardingKey);
    _onboardingShown = shownStr == 'true';
  }

  Future<void> _maybeShowOnboarding() async {
    if (!_onboardingShown && _tasks.length == 1) {
      _onboardingShown = true;
      await _storage.write(key: _onboardingKey, value: 'true');
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _showOnboarding();
      });
    }
  }

  void _showOnboarding() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swipe_rounded, size: 44, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                'Swipe Gestures',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Swipe right to complete',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Swipe left to delete',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Got it!', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _loadTasks() async {
    final raw = await _storage.read(key: _tasksKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw) as List;
      setState(() {
        _tasks = decoded
            .map((e) => _Task.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    await _storage.write(
      key: _tasksKey,
      value: jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
  }

  // ── Task operations ────────────────────────────────────────────────────────

  void _addTask(String title, DateTime? dueDate, {String category = 'none'}) {
    final task = _Task(title: title.trim(), dueDate: dueDate, category: category);
    setState(() {
      _tasks.add(task);
    });
    _saveTasks();
    _maybeShowOnboarding();

    // Schedule notification if due date is set and in the future
    if (dueDate != null && dueDate.isAfter(DateTime.now())) {
      NotificationService().scheduleTaskReminder(
        id: task.hashCode,
        title: task.title,
        scheduledDate: dueDate,
      );
    }
  }

  void _toggleTask(int index) {
    HapticFeedback.lightImpact();
    final task = _tasks[index];
    final nowDone = !task.done;
    setState(() {
      _tasks[index] = task.copyWith(done: nowDone);
    });
    _saveTasks();

    // Cancel notification when completed
    if (nowDone) {
      NotificationService().cancel(task.hashCode);
    } else if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
      NotificationService().scheduleTaskReminder(
        id: task.hashCode,
        title: task.title,
        scheduledDate: task.dueDate!,
      );
    }
  }

  void _deleteTask(int index) {
    HapticFeedback.mediumImpact();
    final removed = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
    NotificationService().cancel(removed.hashCode);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task deleted', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.accent,
          onPressed: () {
            setState(() {
              _tasks.insert(index, removed);
            });
            _saveTasks();
            if (removed.dueDate != null &&
                removed.dueDate!.isAfter(DateTime.now()) &&
                !removed.done) {
              NotificationService().scheduleTaskReminder(
                id: removed.hashCode,
                title: removed.title,
                scheduledDate: removed.dueDate!,
              );
            }
          },
        ),
      ),
    );
  }

  // ── Add-task bottom sheet ──────────────────────────────────────────────────

  void _showAddTaskSheet() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDate;
    String selectedCategory = 'none';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'New Task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Task name can\'t be empty'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // Due date picker row
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate ?? now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 2),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: AppColors.primary,
                                surface: AppColors.card,
                                onSurface: AppColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          // After picking a date, show time picker
                          if (!ctx.mounted) return;
                          final time = await showTimePicker(
                            context: ctx,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppColors.primary,
                                  surface: AppColors.card,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          setSheetState(() {
                            if (time != null) {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                time.hour,
                                time.minute,
                              );
                            } else {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                9,
                                0,
                              );
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 20,
                              color: selectedDate != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedDate != null
                                    ? DateFormat('EEE, MMM d · h:mm a')
                                        .format(selectedDate!)
                                    : 'Add due date (optional)',
                                style: TextStyle(
                                  color: selectedDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (selectedDate != null)
                              GestureDetector(
                                onTap: () => setSheetState(() => selectedDate = null),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category picker
                    Wrap(
                      spacing: 8,
                      children: AppColors.categoryLabels.entries.map((e) {
                        final isSelected = selectedCategory == e.key;
                        final catColor = AppColors.categoryColors[e.key];
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedCategory = e.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (catColor ?? AppColors.textSecondary).withValues(alpha: 0.15)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? (catColor ?? AppColors.textSecondary)
                                    : AppColors.textSecondary.withValues(alpha: 0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (catColor != null) ...[
                                  Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      color: catColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  e.value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected
                                        ? (catColor ?? AppColors.textPrimary)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          _addTask(controller.text, selectedDate, category: selectedCategory);
                          Navigator.of(ctx).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add Task',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Apply search + filter
    var allPending = _tasks.where((t) => !t.done).toList();
    var allCompleted = _tasks.where((t) => t.done).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      allPending = allPending.where((t) => t.title.toLowerCase().contains(q)).toList();
      allCompleted = allCompleted.where((t) => t.title.toLowerCase().contains(q)).toList();
    }

    final showPending = _filter != _TaskFilter.completed;
    final showCompleted = _filter != _TaskFilter.pending;
    final pending = showPending ? allPending : <_Task>[];
    final completed = showCompleted ? allCompleted : <_Task>[];

    final total = _tasks.length;
    final doneCount = _tasks.where((t) => t.done).length;
    final progress = total == 0 ? 0.0 : doneCount / total;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Text(
                _greeting,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_isSearchOpen ? Icons.close_rounded : Icons.search_rounded, size: 22),
            tooltip: _isSearchOpen ? 'Close search' : 'Search',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                FadeSlideRoute(page: const CounterScreen()),
              );
            },
            icon: const Icon(Icons.speed_rounded, size: 22),
            tooltip: 'Counter',
          ),
          IconButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              await SessionManager().clearSession();
              nav.pushReplacement(
                FadeSlideRoute(page: const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout_rounded, size: 22),
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: total == 0
          ? _buildEmptyState()
          : (pending.isEmpty && completed.isEmpty && _searchQuery.isNotEmpty)
              ? _buildNoResultsState()
              : CustomScrollView(
              slivers: [
                // Progress card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _ProgressCard(
                      done: doneCount,
                      total: total,
                      progress: progress,
                    ),
                  ),
                ),

                // Filter chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: _TaskFilter.values.map((f) {
                        final isSelected = _filter == f;
                        final label = f == _TaskFilter.all
                            ? 'All'
                            : f == _TaskFilter.pending
                                ? 'Pending'
                                : 'Completed';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _filter = f),
                            selectedColor: AppColors.primary.withValues(alpha: 0.2),
                            backgroundColor: AppColors.card,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : Colors.transparent,
                              ),
                            ),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Pending section header
                if (pending.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                      child: Text(
                        'PENDING  ·  ${pending.length}',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                // Pending tasks
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final realIndex = _tasks.indexOf(pending[i]);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Dismissible(
                          key: ValueKey('task_${pending[i].title}_$realIndex'),
                          direction: DismissDirection.horizontal,
                          // Swipe right → complete
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                            ),
                          ),
                          // Swipe left → delete
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              _toggleTask(realIndex);
                              return false; // don't remove, just toggle
                            }
                            return true; // allow delete
                          },
                          onDismissed: (_) => _deleteTask(realIndex),
                          child: _TaskTile(
                            task: pending[i],
                            onToggle: () => _toggleTask(realIndex),
                            onDelete: () => _deleteTask(realIndex),
                          ),
                        ),
                      );
                    },
                    childCount: pending.length,
                  ),
                ),

                // Completed section header
                if (completed.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                      child: Text(
                        'COMPLETED  ·  ${completed.length}',
                        style: TextStyle(
                          color: AppColors.success.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                // Completed tasks
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final realIndex = _tasks.indexOf(completed[i]);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Dismissible(
                          key: ValueKey('task_done_${completed[i].title}_$realIndex'),
                          direction: DismissDirection.horizontal,
                          // Swipe right → uncomplete
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.replay_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          // Swipe left → delete
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              _toggleTask(realIndex);
                              return false;
                            }
                            return true;
                          },
                          onDismissed: (_) => _deleteTask(realIndex),
                          child: _TaskTile(
                            task: completed[i],
                            onToggle: () => _toggleTask(realIndex),
                            onDelete: () => _deleteTask(realIndex),
                          ),
                        ),
                      );
                    },
                    childCount: completed.length,
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _emptyPulse,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  size: 56,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SlideTransition(
              position: _emptySlide,
              child: Column(
                children: [
                  const Text(
                    'All clear!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap  +  to add your first task',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Progress card ────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final int done;
  final int total;
  final double progress;

  const _ProgressCard({
    required this.done,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.textSecondary.withValues(alpha: 0.15),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.success),
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$done of $total completed',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  done == total
                      ? 'All done — great work!'
                      : '${total - done} remaining',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task model ───────────────────────────────────────────────────────────────

class _Task {
  final String title;
  final bool done;
  final DateTime? dueDate;
  final String category;

  const _Task({
    required this.title,
    this.done = false,
    this.dueDate,
    this.category = 'none',
  });

  _Task copyWith({String? title, bool? done, DateTime? dueDate, String? category}) => _Task(
        title: title ?? this.title,
        done: done ?? this.done,
        dueDate: dueDate ?? this.dueDate,
        category: category ?? this.category,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'done': done,
        'dueDate': dueDate?.toIso8601String(),
        'category': category,
      };

  factory _Task.fromJson(Map<String, dynamic> json) => _Task(
        title: json['title'] as String,
        done: json['done'] as bool,
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : null,
        category: (json['category'] as String?) ?? 'none',
      );
}

// ── Task tile widget ─────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  final _Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  String _dueDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);
    final diff = taskDay.difference(today).inDays;

    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Today · ${DateFormat.jm().format(date)}';
    if (diff == 1) return 'Tomorrow · ${DateFormat.jm().format(date)}';
    return DateFormat('MMM d · h:mm a').format(date);
  }

  Color _dueDateColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);
    final diff = taskDay.difference(today).inDays;

    if (diff < 0) return AppColors.error;
    if (diff == 0) return const Color(0xFFF59E0B); // amber
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final isDone = task.done;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.card.withValues(alpha: 0.6)
            : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: isDone
            ? null
            : (task.dueDate != null &&
                    task.dueDate!.isBefore(DateTime.now()) &&
                    !task.done)
                ? Border.all(
                    color: AppColors.error.withValues(alpha: 0.3), width: 1)
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Category dot + Checkbox
                if (task.category != 'none') ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.categoryColors[task.category],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: isDone ? AppColors.success : Colors.transparent,
                    border: Border.all(
                      color: isDone
                          ? AppColors.success
                          : AppColors.textSecondary.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                // Title + due date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isDone
                              ? AppColors.textSecondary.withValues(alpha: 0.5)
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: isDone
                                  ? AppColors.textSecondary.withValues(alpha: 0.5)
                                  : _dueDateColor(task.dueDate!),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isDone
                                  ? DateFormat('MMM d').format(task.dueDate!)
                                  : _dueDateLabel(task.dueDate!),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDone
                                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                                    : _dueDateColor(task.dueDate!),
                                fontWeight: isDone
                                    ? FontWeight.w400
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Completed badge or delete icon
                if (isDone)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

