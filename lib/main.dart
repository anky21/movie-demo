import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'package:movies/services/ads_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdsService.initialize();
  
  // Get the launch count
  final prefs = await SharedPreferences.getInstance();
  final launchCount = prefs.getInt('launch_count') ?? 0;
  
  // Increment and save the launch count
  await prefs.setInt('launch_count', launchCount + 1);
  
  runApp(MyApp(showWelcome: launchCount < 3));
}

class MyApp extends StatelessWidget {
  final bool showWelcome;

  const MyApp({
    Key? key,
    required this.showWelcome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movies App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: showWelcome ? const WelcomeScreen() : const HomeScreen(),
    );
  }
}
