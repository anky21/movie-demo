import 'package:flutter/material.dart';
import 'screens/onboarding/onboarding_step1.dart';
import 'screens/onboarding/onboarding_step2.dart';
import 'screens/onboarding/onboarding_step3.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding/step1',
      routes: {
        '/onboarding/step1': (context) => const OnboardingStep1(),
        '/onboarding/step2': (context) => const OnboardingStep2(),
        '/onboarding/step3': (context) => const OnboardingStep3(),
        '/welcome': (context) => const WelcomeScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
