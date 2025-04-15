import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUGYM+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Tüm metin temaları için Ubuntu fontunu ayarlama
        textTheme: GoogleFonts.ubuntuTextTheme(Theme.of(context).textTheme),
        // Butonlar vb. için Ubuntu fontunu ayarlama
        primaryTextTheme: GoogleFonts.ubuntuTextTheme(
          Theme.of(context).primaryTextTheme,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/login', // Başlangıç rotası login olarak ayarlandı
      routes: appRoutes,
    );
  }
}
