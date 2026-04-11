import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/providers/counter_provider.dart';
import 'package:to_do_list/utils/colors.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CounterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          if (provider.counter != 0)
            TextButton(
              onPressed: provider.reset,
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
              '${provider.counter}',
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w200,
                color: provider.counter > 0
                    ? AppColors.success
                    : provider.counter < 0
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
                  onTap: provider.decrement,
                ),
                const SizedBox(width: 32),
                _buildButton(
                  icon: Icons.add_rounded,
                  onTap: provider.increment,
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
