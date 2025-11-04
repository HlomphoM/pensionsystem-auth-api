import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/services/firestore.dart';

class NewPensionerSesothoPage extends StatefulWidget {
  const NewPensionerSesothoPage({super.key});

  @override
  State<NewPensionerSesothoPage> createState() => _NewPensionerPageState();
}

class _NewPensionerPageState extends State<NewPensionerSesothoPage> {
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
          content: const Text('Lilemo tsa mokholi oa penshene ha li boemong ba mokholo, netefatsa hore mokholi o lilemo li mashome a supileng ho ea holimo (70+)'),
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
      appBar: AppBar(title: const Text('Ngolisa mokholi e mocha')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: pensionerNamesController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Mabitso a felletseng'),
                validator: (value) =>
                    value!.isEmpty ? 'Kenya mabitso a mokholi a felletseng' : null,
              ),
              TextFormField(
                controller: pinController,
                decoration: const InputDecoration(labelText: 'Fa mokholi a ingolle nomoro ea lekunutu'),
                validator: (value) =>
                    value!.isEmpty ? 'Kenya nomoro ea lekunutu' : null,
              ),
              const SizedBox(height: 16),
              const Text('Khetha bohlomphehi', style: TextStyle(fontSize: 24)),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Ms.'),
                      leading: Radio<String>(
                        value: 'Ms.',
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
                      title: const Text('Mr.'),
                      leading: Radio<String>(
                        value: 'Mr.',
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
                      title: const Text('Mrs.'),
                      leading: Radio<String>(
                        value: 'Mrs.',
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
              const Text('Khetha bong', style: TextStyle(fontSize: 24)),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Bots\'ehali'),
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
                      title: const Text('Botona'),
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
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Nomoro ea boitsebiso (ID)'),
                validator: (value) =>
                    value!.isEmpty ? 'Kenya nomoro ea boitsebiso' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateOfBirthController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Khetha tlhaho ea mokholi'),
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
                    value!.isEmpty ? 'Khetha tlhaho ea mokholi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('+266'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: phoneNumberController,
                      decoration: const InputDecoration(labelText: 'Nomoro ea mohala'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.length != 8) {
                          return 'Kenya nomoro e nepahetseng';
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
                decoration: const InputDecoration(labelText: 'Bolulo'),
                validator: (value) =>
                    value!.isEmpty ? 'Kenya sebaka sa bolulo' : null,
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