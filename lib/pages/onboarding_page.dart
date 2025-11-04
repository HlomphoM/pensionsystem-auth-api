import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final docId = prefs.getString('loggedInPensionerId');

    if (docId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('pensioners')
          .doc(docId)
          .get();

      if (doc.exists) {
        Navigator.pushReplacementNamed(
          context,
          '/userhome',
          arguments: doc,
        );
      } else {
        await prefs.remove('loggedInPensionerId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/onboarding_images/296658.jpg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 32),
                const Text(
                  'WELCOME, SELECT LANGUAGE OF PREFERENCE.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'LUMELA, PENYA PUO EO U TSOELANG PELE KA EONA.',
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
                    Navigator.pushNamed(context, '/intermediate');
                  },
                  onLongPress: () async {
                    await flutterTts.speak('Continue in English');
                  },
                  child: const Text(
                    'ENGLISH',
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
                    Navigator.pushNamed(context, '/intermediateSes');
                  },
                  onLongPress: () async {
                    await flutterTts.speak('Tsoela pele ka Sesotho');
                  },
                  child: const Text(
                    'SESOTHO',
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