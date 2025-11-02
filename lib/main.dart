import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _initApp() async {
  await Future.delayed(const Duration(milliseconds: 600));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        filled: true,
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    );


    return MaterialApp.router(
      title: 'Flutter RTC Demo',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}