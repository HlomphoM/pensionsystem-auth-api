import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPaymentHistoryPage extends StatefulWidget {
  const AdminPaymentHistoryPage({Key? key}) : super(key: key);

  @override
  State<AdminPaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<AdminPaymentHistoryPage> {
  List<Map<String, dynamic>> payouts = [];
  double currentBalance = 0.0;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAllPaymentHistory();
  }

  Future<void> _loadAllPaymentHistory() async {
    try {
      final balanceDoc = await FirebaseFirestore.instance
          .collection('payouthistory')
          .doc('systemBalance')
          .get();

      final balanceValue = (balanceDoc.data()?['currentbalance'] as num?)?.toDouble() ?? 0.0;

      final snapshot = await FirebaseFirestore.instance
          .collection('payouthistory')
          .doc('systemBalance')
          .collection('balance')
          .orderBy('datePaid', descending: true)
          .get();

      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        final amount = (data['payoutAmount'] as num?)?.toDouble() ?? 0.0;
        final date = (data['datePaid'] as Timestamp?)?.toDate();
        final name = data['pensionerNames']?.toString() ?? 'Unknown';

        return {
          'amount': amount,
          'date': date,
          'name': name,
        };
      }).toList();

      setState(() {
        currentBalance = balanceValue;
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
      appBar: AppBar(title: const Text('All Payment History')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.amber[200],
                      child: Text(
                        'Chelete e setseng hajoale: M${currentBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: payouts.length,
                        itemBuilder: (context, index) {
                          final payout = payouts[index];
                          final amount = payout['amount'] as double;
                          final date = payout['date'] as DateTime?;
                          final name = payout['name'] as String;
                          final formattedDate = date != null
                              ? '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}'
                              : 'Unknown date';

                          return Card(
                            elevation: 3,
                            child: ListTile(
                              leading: const Icon(Icons.payments, color: Colors.green),
                              title: Text('M${amount.toStringAsFixed(2)}'),
                              subtitle: Text('$name • E patetsoe ka $formattedDate'),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(),
                      ),
                    ),
                  ],
                ),
    );
  }
}