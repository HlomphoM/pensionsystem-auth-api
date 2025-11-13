import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore.dart';

class AllPensionersPage extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bakholi ba penshele kaofela')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.allPensioners(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pensioners = snapshot.data;
          if (pensioners == null || pensioners.isEmpty) {
            return const Center(child: Text('Hahona bakholi ba ngolisitsoeng hajoale.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: pensioners.length,
            itemBuilder: (context, index) { 
              final pensioner = pensioners[index];
              final title = pensioner['title']?.toString() ?? '';
              final pensionerNames = pensioner['pensionerNames']?.toString() ?? '';
              final gender = pensioner['gender'] ?.toString() ?? '';
              final idNumber = pensioner['idNumber']?.toString()  ?? '';
              final dateOfBirth = pensioner['dateOfBirth'] as DateTime?;
              final phoneNumber = pensioner['phoneNumber']?.toString()  ?? '';
              final location = pensioner['location']?.toString() ?? '';
              final guardianNames = pensioner['guardianNames']?.toString()  ?? '';
              final guardianRelationship = pensioner['guardianRelationship']?.toString()  ?? '';
              final guardianNumber = pensioner['guardianNumber']?.toString()  ?? '';
              final dateJoined = pensioner['dateJoined'] as DateTime?;
              final status = pensioner['status']?.toString()  ?? '';

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
                    Text(pensioner['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pensioner['pensionerNames'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pensioner['gender'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pensioner['idNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (dateBConverter.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(dateBConverter, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                   
                    ],
                    const SizedBox(height: 6),  
                    Text(pensioner['phoneNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pensioner['location'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pensioner['guardianNames'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pensioner['guardianRelationship'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pensioner['guardianNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pensioner['status'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (dateConverter.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(dateConverter, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                   const SizedBox(height: 12),  
                    ],
                     Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final idNumber = pensioner['idNumber']?.toString() ?? '';
                            if (idNumber.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mokholi oa nomoro ea boitsebiso eno ha a fumanehe hajoale.')));
                              return;
                            }
                            try {
                              await firestoreService.updateStatus(idNumber, 'Active');
                              await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Tsebiso'),
                                  content: const Text('Mokholi o kibollotsoe.'),
                                  actions: <Widget>[
                                    TextButton(onPressed: () => Navigator.pop(context, 'OK'), child: const Text('OK')),
                                  ],
                                ),
                              );
                            }  catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                            }
                          },
                          child: const Text('Kibolla'),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: () async {
                            final idNumber = pensioner['idNumber']?.toString() ?? '';
                            if (idNumber.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mokholi oa nomoro ea boitsebiso eno ha a fumanehe hajoale.')));
                              return;
                            }
                            try {
                              await firestoreService.updateStatus(idNumber, 'Deactivated');
                              await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Tsebiso'),
                                  content: const Text('Mokholi o kibuoe.'),
                                  actions: <Widget>[
                                    TextButton(onPressed: () => Navigator.pop(context, 'OK'), child: const Text('OK')),
                                  ],
                                ),
                              );
                            }  catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                            }
                          },
                          child: const Text('Kiba'),
                        ),
                      ], 
                      ),
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
