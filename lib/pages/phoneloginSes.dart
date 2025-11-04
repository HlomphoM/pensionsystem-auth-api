import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PensionerLoginPage extends StatefulWidget {
  @override
  _PensionerLoginPageState createState() => _PensionerLoginPageState();
}

class _PensionerLoginPageState extends State<PensionerLoginPage> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('pensioners')
          .where('phoneNumber', isEqualTo: _phoneController.text.trim())
          .where('pin', isEqualTo: _pinController.text.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final pensioner = snapshot.docs.first;
        Navigator.pushReplacementNamed(
          context,
          '/userhome',
          arguments: pensioner,
        );
      } else {
        setState(() => _error = 'Invalid phone number or PIN');
      }
    } catch (e) {
      setState(() => _error = 'Login failed: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pensioner Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(labelText: 'PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}