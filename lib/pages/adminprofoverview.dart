import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore.dart';

class AdminProfile extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MINISTRY OF SOCIAL DEVELOPMENT')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.viewBlance(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final payouthistory = snapshot.data;
          if (payouthistory == null || payouthistory.isEmpty) {
            return const Center(child: Text('No balance found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payouthistory.length,
            itemBuilder: (context, index) {
              final payouthist = payouthistory[index];
              final currentbalance = (payouthist['currentbalance'] as num?)?.toDouble() ?? 0.0;

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[100 * ((index % 8) + 1)],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PENSION ADMIN', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text(
                          'Current Balance: M${currentbalance.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Colors.yellow,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/adminpaymenthistory');
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'View Payment History',
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
                  const SizedBox(height: 20),
                ],
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),
    );
  }
}