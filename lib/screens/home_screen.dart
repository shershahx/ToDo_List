import 'package:flutter/material.dart';
import 'package:to_do_list/utils/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.babyBlue.withValues(alpha: 0.3),
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: AppColors.lavender,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to your To-Do List!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.peach,
                foregroundColor: AppColors.darkLavender,
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
