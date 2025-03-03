import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class OnboardingStep3 extends StatelessWidget {
  const OnboardingStep3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      animationPath: 'assets/animations/step3.json',
      title: 'Ready to Start?',
      description: 'Begin your movie journey now and discover amazing stories waiting for you.',
      isLastStep: true,
      onNext: () {
        Navigator.pushReplacementNamed(context, '/welcome');
      },
    );
  }
} 