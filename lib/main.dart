import 'package:flutter/material.dart';
import 'package:khaddemni_app/screens/splash_screen.dart'; // تأكد أن المسار صحيح
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4D9EF6);
    const Color lightText = Color(0xFF1E1E1E);
    const Color cardBackground = Color(0xFFF7F7F7);
    const Color secondaryTextColor = Color(0xFF666666);

    final TextTheme baseTextTheme = Theme.of(context).textTheme;
    final TextTheme cairoTextTheme = GoogleFonts.cairoTextTheme(baseTextTheme).copyWith(
      bodyLarge: const TextStyle(color: lightText, fontSize: 16, fontFamily: 'Cairo'),
      bodyMedium: const TextStyle(color: secondaryTextColor, fontSize: 14, fontFamily: 'Cairo'),
      titleLarge: const TextStyle(color: lightText, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
      titleMedium: const TextStyle(color: lightText, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
      labelLarge: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
      // يمكنك إضافة المزيد من التخصيصات هنا إذا أردت
    );

    return MaterialApp(
      title: 'Khaddemni App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: Colors.white, //  ⭐  الخلفية العامة بيضاء  ⭐
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
          primary: primaryBlue,
          secondary: primaryBlue, //  يمكن تعديله للون ثانوي آخر
          surface: Colors.white,    //  ⭐  استخدام surface للخلفيات  ⭐
          error: Colors.redAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: lightText,   //  ⭐  استخدام onSurface للنص على الأسطح  ⭐
          onError: Colors.white,
          //  background و onBackground قديمان، نستخدم surface و onSurface بدلاً منهما
        ),

        textTheme: cairoTextTheme,
        
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, //  ⭐  خلفية AppBar بيضاء  ⭐
          foregroundColor: lightText,    //  ⭐  لون العنوان والأيقونات في AppBar  ⭐
          elevation: 0,
          centerTitle: true,
          titleTextStyle: cairoTextTheme.titleMedium, //  استخدام النمط المحدد
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            textStyle: cairoTextTheme.labelLarge, //  استخدام النمط المحدد
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            elevation: 2,
          ),
        ),
        
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryBlue,
          unselectedItemColor: secondaryTextColor,
          selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12), // تعديل حجم الخط
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12), // تعديل حجم الخط
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 2,
        ),

        //  ⭐  التصحيح هنا: استخدام CardThemeData  ⭐
        cardTheme: CardThemeData( 
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: cardBackground,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBackground,
          hintStyle: cairoTextTheme.bodyMedium?.copyWith(color: secondaryTextColor.withOpacity(0.7)), // تعديل الشفافية
          labelStyle: cairoTextTheme.bodyMedium?.copyWith(color: primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: primaryBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          prefixIconColor: primaryBlue,
        ),

        iconTheme: const IconThemeData(
          color: primaryBlue,
          size: 24.0,
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryBlue,
            textStyle: cairoTextTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          )
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}