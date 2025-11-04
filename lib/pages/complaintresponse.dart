import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class ComplaintResponsePage extends StatefulWidget {
  const ComplaintResponsePage({super.key});

  @override
  State<ComplaintResponsePage> createState() => _ComplaintResponsePageState();
}

class _ComplaintResponsePageState extends State<ComplaintResponsePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _responseController = TextEditingController();

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('complaints').add({
        'complaintResonse': _responseController.text.trim(),
        'dateResponded': FieldValue.serverTimestamp(),
        
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response Recorded.')),
      );

      _responseController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Respond to Grievance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _responseController,
                decoration: const InputDecoration(labelText: 'Enter response'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a valid response' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Respond'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}