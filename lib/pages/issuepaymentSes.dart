import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/firestore.dart';

class IssuePaymentSesPage extends StatefulWidget {
  @override
  _IssuePaymentPageState createState() => _IssuePaymentPageState();
}

class _IssuePaymentPageState extends State<IssuePaymentSesPage> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Netefatsa mekholo')),

      floatingActionButton: StreamBuilder<List<DocumentSnapshot>>(
        stream: firestoreService.approvedPensionerDocs(),
        builder: (context, snapshot) {
          final pensioners = snapshot.data ?? [];

          return FloatingActionButton.extended(
            onPressed: pensioners.isEmpty
                ? null
                : () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing bulk payment... please wait.')),
                    );

                    try {
                      final result = await firestoreService.processPayments(pensioners);
                      await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Mokholiso oa penshele o atlehile'),
                          content: Text(result),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Mokholo oa penshele hlolehile.'),
                          content: Text('Error: $e'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
            label: const Text('Qalella ho kholisa.'),
            
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: firestoreService.approvedPensionerDocs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pensioners = snapshot.data;
          if (pensioners == null || pensioners.isEmpty) {
            return const Center(child: Text('Hahona baholoane ba kholisoang penshele.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: pensioners.length,
            itemBuilder: (context, index) {
              final data = pensioners[index].data() as Map<String, dynamic>;

              final docId = pensioners[index].id;
              final title = data['title']?.toString() ?? '';
              final pensionerNames = data['pensionerNames']?.toString() ?? '';
              final gender = data['gender']?.toString() ?? '';
              final idNumber = data['idNumber']?.toString() ?? '';
              final phoneNumber = data['phoneNumber']?.toString() ?? '';
              final location = data['location']?.toString() ?? '';
              final guardianNames = data['guardianNames']?.toString() ?? '';
              final guardianRelationship = data['guardianRelationship']?.toString() ?? '';
              final guardianNumber = data['guardianNumber']?.toString() ?? '';
              final status = data['status']?.toString() ?? '';

              DateTime? dateOfBirth;
              final rawDate = data['dateOfBirth'];
              if (rawDate is Timestamp) {
                dateOfBirth = rawDate.toDate();
              } else if (rawDate is DateTime) {
                dateOfBirth = rawDate;
              } else if (rawDate is String) {
                dateOfBirth = DateTime.tryParse(rawDate);
              }
              
              DateTime? dateJoined;
              final rawDateJoined = data['dateJoined'];
              if (rawDateJoined is Timestamp) {
                dateJoined = rawDateJoined.toDate();
              } else if (rawDateJoined is DateTime) {
                dateJoined = rawDateJoined;
              } else if (rawDateJoined is String) {
                dateJoined = DateTime.tryParse(rawDateJoined);
              }

              final dateBConverter = dateOfBirth != null && dateOfBirth.year > 1970
                  ? '${dateOfBirth.day.toString().padLeft(2, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.year}'
                  : '';
              final dateConverter = dateJoined != null && dateJoined.year > 1970
                  ? '${dateJoined.day.toString().padLeft(2, '0')}-${dateJoined.month.toString().padLeft(2, '0')}-${dateJoined.year}'
                  : '';

              return Container(
                padding: const EdgeInsets.all(12),
                color: Colors.amber[100 * ((index % 8) + 1)],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(docId, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pensionerNames, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(gender, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(idNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (dateBConverter.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(dateBConverter, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                    const SizedBox(height: 6),
                    Text(phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(location, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(guardianNames, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(guardianRelationship, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(guardianNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (dateConverter.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(dateConverter, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ), 
    );
  }
}