import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore.dart';

class AllPensionersComplaintsPage extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Complaints')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.allComplaints(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final complaints = snapshot.data;
          if (complaints == null || complaints.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              final id = complaint['id'] as String? ?? '';
              final pensionerNames = complaint['pensionerNames']?.toString() ?? '';
              final complaintBody = complaint['complaintBody']?.toString() ?? '';
              final dateOfPost = complaint['datePublished'] as DateTime?;
              final dateConverter = dateOfPost != null && dateOfPost.year > 1970
                  ? '${dateOfPost.day.toString().padLeft(2, '0')}-${dateOfPost.month.toString().padLeft(2, '0')}-${dateOfPost.year}'
                  : '';
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/expandedComplaint',
                    arguments: {
                      'id': id,
                      'pensionerNames': pensionerNames,
                      'complaintBody': complaintBody,
                      'datePublished': dateOfPost,
                    },
                  );
                },
              
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.amber[100 * ((index % 8) + 1)],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(complaint['pensionerNames'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (dateConverter.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(dateConverter, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                   const SizedBox(height: 12), 
                    ],
                    Text(complaintBody, maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ),
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
