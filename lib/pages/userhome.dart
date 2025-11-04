import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserhomePage extends StatefulWidget {
  const UserhomePage({Key? key}) : super(key: key);

  @override
  State<UserhomePage> createState() => _PensionerDashboardState();
}

class _PensionerDashboardState extends State<UserhomePage> {
  double balance = 0.0;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final docId = prefs.getString('loggedInPensionerId');

      if (docId == null) {
        setState(() {
          error = 'No pensioner is currently logged in.';
          loading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('pensioners')
          .doc(docId)
          .get();

      if (!doc.exists) {
        setState(() {
          error = 'Pensioner record not found.';
          loading = false;
        });
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final fetchedBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;

      setState(() {
        balance = fetchedBalance;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load balance: ${e.toString()}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pensioner Dashboard')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_wallet,
                                  size: 64, color: Colors.deepPurple),
                              const SizedBox(height: 16),
                              const Text('Current Balance',
                                  style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 8),
                              Text(
                                'M${balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 5,
                              color: Colors.yellow,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/paymenthistory');
                                },
                                onLongPress: () async {
                                  final flutterTts = FlutterTts();
                                  await flutterTts.speak('View Payment History');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'View Payment History',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 5,
                              color: Colors.yellow,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/profileoverview');
                                },
                                onLongPress: () async {
                                  final flutterTts = FlutterTts();
                                  await flutterTts.speak('View Your Profile');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'View Your Profile',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Card(
                              elevation: 5,
                              color: Colors.yellow,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/newcomplaint');
                                },
                                onLongPress: () async {
                                  final flutterTts = FlutterTts();
                                  await flutterTts.speak('Lodge Complaint');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Lodge Complaint',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                  const SizedBox(height: 20), 

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 5,
                              color: Colors.yellow,
                              child: InkWell(
                                onTap: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.remove('loggedInPensionerId'); 
                                  Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false); 
                                },
                                onLongPress: () async {
                                  final flutterTts = FlutterTts();
                                  await flutterTts.speak('Log Out');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Log Out',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}