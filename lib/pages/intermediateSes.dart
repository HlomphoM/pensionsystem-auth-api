import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class IntermediateSesotho extends StatelessWidget {
  const IntermediateSesotho({Key? key}) : super(key: key);

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
                  'LUMELA, KHETHA HORE U TSOELA PELE KA EMAIL KAPO NOMORO EA MOHALA',
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
                    Navigator.pushNamed(context, '/loginSesotho');
                  },
                  onLongPress: () async {
                    final flutterTts = FlutterTts();
                    await flutterTts.speak('KENA KA EMAIL');
                  },
                  child: const Text(
                    'KENA KA EMAIL',
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
                    Navigator.pushNamed(context, '/phoneloginSes');
                  },
                  onLongPress: () async {
                    final flutterTts = FlutterTts();
                    await flutterTts.speak('KENA KA NOMORO');
                  },
                  child: const Text(
                    'KENA KA NOMORO',
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