import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewPensionerPage extends StatefulWidget {
  const NewPensionerPage({super.key});

  @override
  State<NewPensionerPage> createState() => _NewPensionerPageState();
}

class _NewPensionerPageState extends State<NewPensionerPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController pensionerNamesController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController idNumberController =TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController guardianNamesController = TextEditingController();
  final TextEditingController guardianRelationshipController = TextEditingController();
  final TextEditingController guardianNumberController = TextEditingController();
  String? currentTitle;
  String? currentGender;
  DateTime? dateOfBirth;

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
      appBar: AppBar(title: const Text('New Pensioner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: pensionerNamesController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Full Names'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter pensioner\'s name' : null,
              ),
              TextFormField(
                controller: pinController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Pin'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a pin' : null,
              ),
              const SizedBox(height: 16),
              const Text('Select pensioner\'s marital status', style: TextStyle(fontSize: 24)),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Single'),
                      leading: Radio<String>(
                        value: 'Single',
                        groupValue: currentTitle,
                        onChanged: (value) {
                          setState(() {
                            currentTitle = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      title: const Text('Married'),
                      leading: Radio<String>(
                        value: 'Married',
                        groupValue: currentTitle,
                        onChanged: (value) {
                          setState(() {
                            currentTitle = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Select pensioner\'s gender', style: TextStyle(fontSize: 24)),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Female'),
                      leading: Radio<String>(
                        value: 'Female',
                        groupValue: currentGender,
                        onChanged: (value) {
                          setState(() {
                            currentGender = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      title: const Text('Male'),
                      leading: Radio<String>(
                        value: 'Male',
                        groupValue: currentGender,
                        onChanged: (value) {
                          setState(() {
                            currentGender = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
              controller: idNumberController,
              decoration: const InputDecoration(labelText: 'ID Number'),
              maxLength: 13, 
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pensioner\'s ID Number';
                }
                if (value.length != 13) {
                  return 'ID Number must be exactly 13 digits';
                }
                return null;
              },
            ),
                          const SizedBox(height: 16),
              TextFormField(
                controller: _dateOfBirthController,
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
                      dateOfBirth = selectedDate;
                      _dateOfBirthController.text =
                          '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}';
                    });
                  }
                },
                validator: (value) =>
                    value!.isEmpty ? 'Please select date of birth' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('+266'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: phoneNumberController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.length != 8) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter pensioner\'s location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: guardianNamesController,
                decoration: const InputDecoration(labelText: 'Guardian\'s name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter guardian\'s name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: guardianRelationshipController,
                decoration: const InputDecoration(labelText: 'Guardian\'s relationship'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter guardian\'s relationship with pensioner' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('+266'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: guardianNumberController,
                      decoration: const InputDecoration(labelText: 'Guardian\'s Phone Number'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.length != 8) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      dateOfBirth != null &&
                      currentTitle != null &&
                      currentGender != null) {
                    bool isOldEnough = _checkAge(dateOfBirth!);
                    if (isOldEnough) {
                      firestoreService.addPensioner(
                        pensionerNamesController.text.trim(),
                        pinController.text.trim(),
                        currentTitle!,
                        currentGender!,
                        idNumberController.text.trim(),
                        dateOfBirth!,
                        phoneNumberController.text.trim(),
                        locationController.text.trim(),
                        guardianNamesController.text.trim(),
                        guardianRelationshipController.text.trim(),
                        guardianNumberController.text.trim(),
                      );
                      pensionerNamesController.clear();
                      pinController.clear();
                      currentTitle = null;
                      currentGender = null;
                      idNumberController.clear();
                      _dateOfBirthController.clear();
                      phoneNumberController.clear();
                      locationController.clear();
                      guardianNamesController.clear();
                      guardianRelationshipController.clear();
                      guardianNumberController.clear();

                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Alert'),
                          content: const Text('Pensioner has been registered.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            )
                          ],
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields correctly.')),
                    );
                  }
                },
                child: const Text('Register Pensioner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}