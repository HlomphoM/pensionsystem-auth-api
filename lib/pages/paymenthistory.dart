import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  List<Map<String, dynamic>> payouts = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
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

      final pensionerDoc = await FirebaseFirestore.instance
          .collection('pensioners')
          .doc(docId)
          .get();

      if (!pensionerDoc.exists) {
        setState(() {
          error = 'Pensioner record not found.';
          loading = false;
        });
        return;
      }

      final name = pensionerDoc['pensionerNames']?.toString() ?? '';

      final snapshot = await FirebaseFirestore.instance
          .collection('payouthistory')
          .doc('systemBalance') 
          .collection('balance')
          .where('pensionerNames', isEqualTo: name)
          .orderBy('datePaid', descending: true)
          .get();

      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        final amount = (data['payoutAmount'] as num?)?.toDouble() ?? 0.0;
        final date = (data['datePaid'] as Timestamp?)?.toDate();
        return {
          'amount': amount,
          'date': date,
        };
      }).toList();

      setState(() {
        payouts = results;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load payment history: ${e.toString()}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : payouts.isEmpty
                  ? const Center(child: Text('No payments found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: payouts.length,
                      itemBuilder: (context, index) {
                        final payout = payouts[index];
                        final amount = payout['amount'] as double;
                        final date = payout['date'] as DateTime?;
                        final formattedDate = date != null
                            ? '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}'
                            : 'Unknown date';

                        return Card(
                          elevation: 3,
                          child: ListTile(
                            leading: const Icon(Icons.payments, color: Colors.green),
                            title: Text('M${amount.toStringAsFixed(2)}'),
                            subtitle: Text('Paid on $formattedDate'),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
    );
  }
}