import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/firestore.dart';

class NewComplaintPage extends StatefulWidget {
  const NewComplaintPage({super.key});

  @override
  State<NewComplaintPage> createState() => _NewComplaintPageState();
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController complaintController = TextEditingController();

  String? pensionerName;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPensionerName();
  }

  Future<void> _loadPensionerName() async {
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

      final name = doc['pensionerNames']?.toString() ?? 'Unknown';
      setState(() {
        pensionerName = name;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load pensioner name: ${e.toString()}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));

    return Scaffold(
      appBar: AppBar(title: const Text('New Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('$pensionerName',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: complaintController,
                decoration: const InputDecoration(labelText: 'Enter complaint'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a message' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    firestoreService.addComplaint(
                      pensionerName!,
                      complaintController.text,
                    );
                    complaintController.clear();
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Alert'),
                        content: const Text('Your complaint has been submitted.'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Submit Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}