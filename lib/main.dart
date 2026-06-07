import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/login_screen.dart';
import 'screens/category_screen.dart';
import 'screens/tag_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define custom color palette
  static const Color primaryBlue = Color(0xFF3347C6);
  static const Color creamWhite = Color(0xFFF8F8F6);
  static const Color darkText = Color(0xFF222222);
  static const Color lightGray = Color(0xFFE8E8E8);
  static const Color success = Color(0xFF55B67A);
  static const Color favoriteAccent = Color(0xFFFFB800);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FindCafe Admin',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryBlue,
          onPrimary: Colors.white,
          secondary: success,
          onSecondary: Colors.white,
          surface: creamWhite,
          onSurface: darkText,
          error: Colors.red,
          onError: Colors.white,
          surfaceContainerHighest: lightGray,
        ),
        scaffoldBackgroundColor: creamWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.caveat(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
          displayMedium: GoogleFonts.caveat(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: darkText,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkText,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightGray, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryBlue, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: lightGray, width: 1),
          ),
        ),
      ),

      // halaman pertama
      home: const LoginScreen(),

      // routes aplikasi
      routes: {
        '/categories': (context) => const CategoryScreen(),
        '/tags': (context) => const TagScreen(),
      },
    );
  }
}