import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class OnboardingStep2 extends StatelessWidget {
  const OnboardingStep2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      animationPath: 'assets/animations/step2.json',
      title: 'Browse Categories',
      description: 'Explore movies by genre, year, or rating to find exactly what you\'re looking for.',
      onNext: () {
        Navigator.pushNamed(context, '/onboarding/step3');
      },
    );
  }
} 