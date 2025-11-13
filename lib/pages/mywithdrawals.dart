import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Withdrawals extends StatefulWidget {
  const Withdrawals({Key? key}) : super(key: key);

  @override
  State<Withdrawals> createState() => _MyProfileState();
}

class _MyProfileState extends State<Withdrawals> {
  DocumentSnapshot? withdrawal;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
  }

  Future<void> _loadWithdrawals() async {
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

      final pensionerN = doc['pensionerNames'];

      final snapshot = await FirebaseFirestore.instance
          .collection('pensionerwithdrawals')
          .where('pensionerNames', isEqualTo: pensionerN)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          error = 'Withdrawal history not found.';
          loading = false;
        });
        return;
      }

      setState(() {
        withdrawal = doc;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load withdrawal history: ${e.toString()}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));

    final p = withdrawal!.data() as Map<String, dynamic>;

    final name = p['pensionerNames']?.toString() ?? '';
    final phone = p['phoneNumber']?.toString() ?? '';
    final balance = (p['balance'] as num?)?.toDouble() ?? 0.0;
    
    DateTime? td;
    final rawDate = p['transferredOn'];
    if (rawDate is Timestamp) {
      td = rawDate.toDate();
    } else if (rawDate is String) {
      td = DateTime.tryParse(rawDate);
    }
    
  final joinedFormatted = td != null && td.year > 1970
       ? '${td.day.toString().padLeft(2, '0')}-${td.month.toString().padLeft(2, '0')}-${td.year}'
     : '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Withdrawals')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('$name',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Phone: $phone'),
            if (joinedFormatted.isNotEmpty) Text('Transferred On: $joinedFormatted'),
            const SizedBox(height: 8),
            Text('Balance: M${balance.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}