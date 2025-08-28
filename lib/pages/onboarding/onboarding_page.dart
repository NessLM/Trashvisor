import 'package:flutter/material.dart';
import 'package:trashvisor/pages/loginandregister/first_loginandregister.dart';
import 'package:trashvisor/pages/onboarding/onboarding_template.dart';
import 'package:trashvisor/pages/onboarding/onboarding_page2.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      illustrationAsset: 'assets/images/onboarding/onboarding1.png',
      title: 'Selamat Datang di Trashvisor',
      description: 'Teman pintar yang siap membantumu memilah, membuang, dan mengelola sampah secara cerdas, praktis, serta ramah lingkungan.',
      nextButtonAsset: 'assets/images/onboarding/next_onboarding1.png',
      indicatorIndex: 0,
      indicatorCount: 4, // misal total 4 slide
      onSkip: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginRegisterPage())); // Skip to LoginRegisterPage
      },
      onNext: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnBoardingPage2()));
      },
    );
  }
}
