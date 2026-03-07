import 'package:flutter/material.dart';
import 'package:to_do_list/screens/login_screen.dart';
import 'package:to_do_list/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final shortSide = MediaQuery.of(context).size.shortestSide;
    final iconSize = shortSide * 0.28;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image(
          image: const AssetImage('assets/icon/icon.png'),
          width: iconSize.clamp(80.0, 160.0),
          height: iconSize.clamp(80.0, 160.0),
        ),
      ),
    );
  }
}
