import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  DocumentSnapshot? pensioner;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPensioner();
  }

  Future<void> _loadPensioner() async {
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

      setState(() {
        pensioner = doc;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load profile: ${e.toString()}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));

    final p = pensioner!.data() as Map<String, dynamic>;

    final title = p['title']?.toString() ?? '';
    final name = p['pensionerNames']?.toString() ?? '';
    final gender = p['gender']?.toString() ?? '';
    final idNumber = p['idNumber']?.toString() ?? '';
    final dob = (p['dateOfBirth'] as Timestamp?)?.toDate();
    final phone = p['phoneNumber']?.toString() ?? '';
    final location = p['location']?.toString() ?? '';
    final guardianName = p['guardianNames']?.toString() ?? '';
    final guardianRelation = p['guardianRelationship']?.toString() ?? '';
    final guardianPhone = p['guardianNumber']?.toString() ?? '';
    final dateJoined = (p['dateJoined'] as Timestamp?)?.toDate();
    final status = p['status']?.toString() ?? '';
    final balance = (p['balance'] as num?)?.toDouble() ?? 0.0;

    final dobFormatted = dob != null && dob.year > 1970
        ? '${dob.day.toString().padLeft(2, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.year}'
        : '';
    final joinedFormatted = dateJoined != null && dateJoined.year > 1970
        ? '${dateJoined.day.toString().padLeft(2, '0')}-${dateJoined.month.toString().padLeft(2, '0')}-${dateJoined.year}'
        : '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('$title $name',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Gender: $gender'),
            Text('ID Number: $idNumber'),
            if (dobFormatted.isNotEmpty) Text('Date of Birth: $dobFormatted'),
            Text('Phone: $phone'),
            Text('Location: $location'),
            const SizedBox(height: 8),
            Text('Guardian: $guardianName'),
            Text('Relationship: $guardianRelation'),
            Text('Guardian Phone: $guardianPhone'),
            const SizedBox(height: 8),
            Text('Status: $status'),
            if (joinedFormatted.isNotEmpty) Text('Date Joined: $joinedFormatted'),
            const SizedBox(height: 8),
            Text('Balance: M${balance.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}