import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
    final response = await http.post(
      Uri.parse('https://pensionsystem-auth-api.onrender.com/phonelogin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': _phoneController.text.trim(),
        'pin': _pinController.text.trim(),
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loggedInPensionerId', responseData['id']);

      Navigator.pushReplacementNamed(
        context,
        '/userhome',
        arguments: responseData,
      );
    } else {
      setState(() => _error = responseData['message'] ?? 'Login failed');
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
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
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