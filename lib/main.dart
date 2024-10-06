import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photofindapp/screens/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Explorer',
      theme: ThemeData(
        primaryColor: const Color(0xFF87CEFA),
        secondaryHeaderColor: const Color(0xFFFFDAB9),
        scaffoldBackgroundColor: const Color(0xFFE6E6FA),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF4A460),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFF4A460),
            side: const BorderSide(
              color: Color(0xFFF4A460),
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF98FF98),
          primary: const Color(0xFF87CEFA),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.raleway(
            color: const Color(0xFF87CEFA),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: GoogleFonts.raleway(
            color: const Color(0xFF000000),
            fontSize: 16,
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
