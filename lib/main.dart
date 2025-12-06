import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panen Lokal',
      theme: ThemeData(
        // 🎨 Color Scheme yang Diperbarui
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          primary: const Color(0xFF2E7D32), // Hijau Lebih Kaya
          onPrimary: Colors.white,
          secondary: const Color(0xFFFBC02D), // Kuning Emas Lembut (Aksen)
          onSecondary: Colors.black87,
          surface: Colors.white,
          onSurface: Colors.black,
          background: const Color(0xFFF9FBE7), // Latar Belakang Krem Sangat Muda
          onBackground: Colors.black87,
          error: Colors.red,
          onError: Colors.white,
        ),
        useMaterial3: true,
        
        // Properti umum untuk tombol (Menggunakan const aman)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            elevation: 8, 
            shadowColor: const Color(0xFF2E7D32).withOpacity(0.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 6,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2E7D32),
            side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2E7D32),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // cardTheme dihapus untuk menghindari error.
        
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white, 
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9FBE7), 
          foregroundColor: Colors.black87,
          elevation: 1, 
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      debugShowCheckedModeBanner: false, 
      home: const SplashScreen(), 
    );
  }
}

