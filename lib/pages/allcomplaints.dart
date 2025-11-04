import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllComplaintsPage extends StatefulWidget {
  const AllComplaintsPage({super.key});

  @override
  State<AllComplaintsPage> createState() => _AllComplaintsPageState();
}

class _AllComplaintsPageState extends State<AllComplaintsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> complaints = [];

  @override
  void initState() {
    super.initState();
    getComplaints();
  }

  Future<void> getComplaints() async {
    try {
      await db.collection("complaints").get().then((querySnapshot) {
        complaints = querySnapshot.docs.map((doc) => doc.data()).toList();
        setState(() {});
      });
    } catch (e) {
      print('Error fetching complaints: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Complaints"),
        backgroundColor: Colors.deepPurple,
      ),
      body: complaints.isNotEmpty
          ? ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          complaint['message'] ?? 'No Message',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          complaint['createdAt'] != null
                              ? complaint['createdAt'].toDate().toString()
                              : 'No Date',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text("No complaints found")),
    );
  }
}