import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserhomePage extends StatefulWidget {
  const UserhomePage({Key? key}) : super(key: key);

  @override
  State<UserhomePage> createState() => _PensionerDashboardState();
}

class _PensionerDashboardState extends State<UserhomePage> {
  double balance = 0.0;
  final LocalAuthentication auth =LocalAuthentication();
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

  Future<bool> _authenticateUser() async {
  try {
    final isAvailable = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();

    if (isAvailable && isSupported) {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to continue',

      );
      return didAuthenticate;
    }
    return false;
  } catch (e) {
    print('Biometric error: $e');
    return false;
  }
}

  Future<void> _handleNavigation() async {
    final isAuthenticated = await _authenticateUser();
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed')),
      );
      return;
    }
    final confirmation = await showDialog<String>(
        context: context,
                        builder: (BuildContext context) => AlertDialog(
           title: const Text('Confrim Transfer'),
             content: const Text('You are about to transfer your pension, click ok to proceed or cancel to cancel.'),
            actions: <Widget>[
             TextButton(
               onPressed: () => Navigator.pop(context, 'OK'),
                 child: const Text('OK'),
                    ),
                      TextButton(
                       onPressed: () => Navigator.pop(context, 'CANCEL'),
                          child: const Text('CANCEL'),
                            ),
                          ],
                        ),
                      );
    if (confirmation != 'OK') return;

    try{
      final prefs = await SharedPreferences.getInstance();
      final docId = prefs.getString('loggedInPensionerId');
       
       final doc = await FirebaseFirestore.instance
          .collection('pensioners')
          .doc(docId)
          .get();

        final data = doc.data()!;
        final pensionerNames = data['pensionerNames'];
        final phoneNumber = data['phoneNumber'];
        final balance = data['balance'];

        if (balance == 0.00) {
          showDialog<String>(
        context: context,
         builder: (BuildContext context) => AlertDialog(
           title: const Text('Insufficient Funds'),
             content: const Text('You do not have any funds to transfer.'),
            actions: <Widget>[
             TextButton(
               onPressed: () => Navigator.pop(context, 'OK'),
                 child: const Text('OK'),
                    ),
                      TextButton(
                       onPressed: () => Navigator.pop(context, 'CANCEL'),
                          child: const Text('CANCEL'),
                            ),
                          ],
                        ),
                      );
                      return;
        }
            final withdrawalRef = FirebaseFirestore.instance.collection('pensionerwithdrawals').doc();
    await withdrawalRef.set({
      'id':withdrawalRef.id,
      'pensionerNames': pensionerNames,
      'phoneNumber': phoneNumber,
      'balance': balance,
      'transferredOn': Timestamp.now(),
    });

    await doc.reference.update({'balance': 0.0});
    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Withdrawal Successful'),
                          content: const Text('All your pension has been withdrawn to the number you have registered with.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            )
                          ],
                        ),
                      );
    }
                      catch (e) {
                        print('Withdrawal error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );

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
                                  size: 64, color: Colors.green),
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
                              color: Colors.green,
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
                          const SizedBox(width: 20),
                          Expanded(
                            child: Card(
                              elevation: 5,
                              color: Colors.green,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/mywithdrawals');
                                },
                                onLongPress: () async {
                                  final flutterTts = FlutterTts();
                                  await flutterTts.speak('View Your Withdrawal History');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'View Your Withdrawals',
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
                              color: Colors.green,
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
                              color: Colors.green,
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
                              color: Colors.green,
                              child: InkWell(
                                onTap: () => _handleNavigation(),
                                onLongPress: () async {
                                  final flutterTts = FlutterTts();
                                  await flutterTts.speak('Send to Mpesa/Ecocash');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Transfer to Mpesa/Ecocash',
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
                              color: Colors.green,
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