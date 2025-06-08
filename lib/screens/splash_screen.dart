import 'package:flutter/material.dart';
import 'package:khaddemni_app/screens/role_selection_screen.dart'; // تأكد من اسم المشروع

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //  الحصول على الثيم الحالي من الـ context
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold( //  الـ Scaffold سيأخذ لون الخلفية من الثيم العام
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.work_outline, 
              size: 80.0,
              color: theme.colorScheme.primary, //  استخدام اللون الأساسي من الثيم
            ),
            const SizedBox(height: 20),
            Text(
              'خدّمني',
              style: textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              'جاري التحميل...',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}