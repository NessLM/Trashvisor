import 'package:flutter/material.dart';
import 'package:trashvisor/pages/onboarding/onboarding_template.dart';
import 'package:trashvisor/pages/onboarding/onboarding_page3.dart';


class OnBoardingPage2 extends StatelessWidget {
  const OnBoardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      illustrationAsset: 'assets/images/onboarding2.png', // ganti gambar
      title: 'Foto, Kenali, dan Kelola',                 // ganti teks
      description: 'Gunakan kamera ponsel untuk mengenali jenis sampah dengan mudah. Dapatkan saran penanganan serta lihat dampaknya bagi masa depan bumi',
      nextButtonAsset: 'assets/images/next_onboarding2.png', // ganti gambar
      indicatorIndex: 1,
      indicatorCount: 4,
      onSkip: () {/* TODO: ke Home */},
      onNext: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnBoardingPage3()));
      },
    );
  }
}
