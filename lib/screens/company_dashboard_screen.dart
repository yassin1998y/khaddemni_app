import 'package:flutter/material.dart';

class CompanyDashboardScreen extends StatelessWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم الشركة"),
        backgroundColor: Colors.purple, // لون مختلف لهذه الصفحة
      ),
      body: const Center(
        child: Text(
          "مرحباً بك في لوحة تحكم شركتك!\nهنا ستكون الإحصائيات، إدارة العروض، البحث عن مواهب، إلخ.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
      // سنضيف شريط التنقل السفلي هنا لاحقاً (إذا لزم الأمر للشركات)
    );
  }
}