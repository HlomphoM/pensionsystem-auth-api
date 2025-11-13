import 'package:flutter/material.dart';

class Styling extends StatelessWidget {
  final Widget child;

  const Styling({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/onboarding_images/backpic.png'),
            fit: BoxFit.cover,
            )
        ),
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}