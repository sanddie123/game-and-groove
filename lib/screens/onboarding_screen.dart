import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Widget _buildGlowingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 50,
            spreadRadius: 10,
          )
        ],
      ),
      child: Icon(icon, size: 120, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      pageColor: Color(0xFF0F0F13),
      titleTextStyle: TextStyle(
        color: Color(0xFF00E5FF),
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      ),
      bodyTextStyle: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
      imagePadding: EdgeInsets.only(top: 60),
    );

    return IntroductionScreen(
      globalBackgroundColor: const Color(0xFF0F0F13),
      pages: [
        PageViewModel(
          title: "DISCOVER",
          body: "Track your favorite titles in your personal database.",
          image: _buildGlowingIcon(Icons.gamepad_outlined, const Color(0xFF00E5FF)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "LISTEN",
          body: "Keep a vault of the best soundtracks.",
          image: _buildGlowingIcon(Icons.headphones_outlined, const Color(0xFFFF0055)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "INITIALIZE",
          body: "Connect to the network and build your ultimate collection.",
          image: _buildGlowingIcon(Icons.hub_outlined, const Color(0xFFB300FF)),
          decoration: pageDecoration,
        ),
      ],
      done: const Text("ACCESS", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
      onDone: () => Navigator.pushReplacementNamed(context, '/login'),
      next: const Icon(Icons.arrow_forward_ios, color: Color(0xFF00E5FF)),
      showSkipButton: true,
      skip: const Text("SKIP", style: TextStyle(color: Colors.grey)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(22.0, 10.0),
        activeColor: const Color(0xFF00E5FF),
        color: Colors.white24,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}