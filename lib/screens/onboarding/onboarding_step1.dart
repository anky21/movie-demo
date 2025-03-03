import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class OnboardingStep1 extends StatelessWidget {
  const OnboardingStep1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      animationPath: 'assets/animations/step1.json',
      title: 'Welcome to Movies App',
      description: 'Discover your next favorite movie with our curated collection of films.',
      onNext: () {
        Navigator.pushNamed(context, '/onboarding/step2');
      },
    );
  }
} 