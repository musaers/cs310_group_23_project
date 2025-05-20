import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'routes.dart';
import 'services/service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase Analytics'i başlat
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  runApp(ServiceProvider(child: MyApp(analytics: analytics)));
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics;

  const MyApp({Key? key, required this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Analytics Observer oluştur
    FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
      analytics: analytics,
    );

    return MaterialApp(
      title: 'SUGYM+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.ubuntuTextTheme(Theme.of(context).textTheme),
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
      initialRoute: '/',
      routes: appRoutes,
      navigatorObservers: [observer],
    );
  }
}
