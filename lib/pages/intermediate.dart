import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Intermediate extends StatelessWidget {
  const Intermediate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WELCOME, SELECT EMAIL OR PHONE NUMBER LOGIN.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  onLongPress: () async {
                    final flutterTts = FlutterTts();
                    await flutterTts.speak('Login with email');
                  },
                  child: const Text(
                    'LOGIN WITH EMAIL',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/phonelogin');
                  },
                  onLongPress: () async {
                    final flutterTts = FlutterTts();
                    await flutterTts.speak('Login with phone number');
                  },
                  child: const Text(
                    'LOGIN WITH PHONE NUMBER',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}