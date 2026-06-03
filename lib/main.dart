import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'routes/app_router.dart';
import 'services/storage_service.dart';
import 'providers/daily_tracker_provider.dart';
import 'providers/analytics_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StorageService>.value(value: storageService),
        ChangeNotifierProvider(create: (_) => DailyTrackerProvider(storageService)),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider(storageService)),
      ],
      child: const FitTrackApp(),
    ),
  );
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FitTrack Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF), // Cyan/Teal neon color
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A), // Dark slate blue background
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
