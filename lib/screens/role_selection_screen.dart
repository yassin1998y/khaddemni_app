import 'package:flutter/material.dart';
import 'package:khaddemni_app/screens/auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _navigateToAuth(BuildContext context, String role) {
    print('RoleSelectionScreen: Navigating to AuthScreen with role: $role');
    if (!context.mounted) {
      print('RoleSelectionScreen: Context not mounted, cannot navigate.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen(userRole: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    print('RoleSelectionScreen build method called.');

    return Scaffold(
      appBar: AppBar(
        title: const Text("اختر دورك في خدّمني"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "من أنت؟",
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 50),
              ElevatedButton( //  سيأخذ تصميمه من الثيم
                onPressed: () {
                  _navigateToAuth(context, "باحث عن عمل");
                },
                child: const Text("أنا باحث عن عمل"),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                //  يمكننا تخصيص لونه إذا أردنا تمييزه
                // style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent), 
                onPressed: () {
                  _navigateToAuth(context, "شركة");
                },
                child: const Text("أنا شركة / مشغّل"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}