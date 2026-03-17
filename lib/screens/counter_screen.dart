import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:to_do_list/utils/colors.dart';
import 'package:to_do_list/utils/session_manager.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  final _storage = const FlutterSecureStorage();
  String get _key => 'counter_value_${SessionManager().currentEmail ?? 'default'}';

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final valStr = await _storage.read(key: _key);
    setState(() {
      _counter = valStr != null ? int.parse(valStr) : 0;
    });
  }

  Future<void> _saveCounter(int value) async {
    await _storage.write(key: _key, value: value.toString());
  }

  void _increment() {
    setState(() => _counter++);
    _saveCounter(_counter);
  }

  void _decrement() {
    setState(() => _counter--);
    _saveCounter(_counter);
  }

  void _reset() {
    setState(() => _counter = 0);
    _saveCounter(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          if (_counter != 0)
            TextButton(
              onPressed: _reset,
              child: const Text(
                'Reset',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_counter',
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w200,
                color: _counter > 0
                    ? AppColors.success
                    : _counter < 0
                        ? AppColors.error
                        : AppColors.textPrimary,
                height: 1,
              ),
            ),
            
            const SizedBox(height: 56),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(
                  icon: Icons.remove_rounded,
                  onTap: _decrement,
                ),
                const SizedBox(width: 32),
                _buildButton(
                  icon: Icons.add_rounded,
                  onTap: _increment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Icon(icon, color: AppColors.textPrimary, size: 28),
        ),
      ),
    );
  }
}
