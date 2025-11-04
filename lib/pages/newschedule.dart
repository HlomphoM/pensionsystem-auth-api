import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/services/firestore.dart';

class NewComplaintPage extends StatefulWidget {
  const NewComplaintPage({super.key});

  @override
  State<NewComplaintPage> createState() => _NewComplaintPageState();
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController messagerController = TextEditingController();
  final TextEditingController _dateOfPaymentController = TextEditingController();

  DateTime? dateOfPayment;

    bool _checkAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    if (age < 70) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Alert'),
          content: const Text('The age of the pensioner does not meet the age requirement, please verify the user is 70+.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            )
          ],
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Pension Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: messagerController,
                decoration: const InputDecoration(labelText: 'Message'),
                validator: (value) =>
                    value!.isEmpty ? 'Please add a description' : null,
              ),
              TextFormField(
                controller: _dateOfPaymentController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Choose date of birth'),
                onTap: () async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      dateOfPayment = selectedDate;
                      _dateOfPaymentController.text =
                          '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}';
                    });
                  }
                },
                validator: (value) =>
                    value!.isEmpty ? 'Please select date of payment/announcement' : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  firestoreService.addComplaint(messagerController.text, _dateOfPaymentController.text);
                  messagerController.clear();
                  _dateOfPaymentController.clear();
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Alert'),
                      content: const Text('Schedule Posted.'),
                      actions: <Widget>[
                        ElevatedButton(onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),)
                      ],
                    )
                  );
                },
                child: const Text('Schedule Posted'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}