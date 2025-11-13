import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/styling.dart';

class PensionerLoginPage extends StatefulWidget {
  @override
  _PensionerLoginPageState createState() => _PensionerLoginPageState();
}

class _PensionerLoginPageState extends State<PensionerLoginPage> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _otpController = TextEditingController();

  bool _loading = false;
  bool _otpSent = false;
  String? _error;
  String? _phoneNumber;
  String? _userId;

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
      setState(() {
        _otpSent = true;
        _phoneNumber = _phoneController.text.trim();
        _userId = responseData['id'];
      });
      
    } else {
      setState(() => _error = responseData['message'] ?? 'Login failed');
    }
  } catch (e) {
    setState(() => _error = 'Login failed: ${e.toString()}');
  } finally {
    setState(() => _loading = false);
  }
}

Future<void> _verifyOtp(String otp) async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final response = await http.post(
      Uri.parse('https://pensionsystem-auth-api.onrender.com/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': _phoneNumber,
        'code': otp,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loggedInPensionerId', _userId!);

      Navigator.pushReplacementNamed(context, '/userhome');
    } else {
      setState(() => _error = responseData['message'] ?? 'OTP verification failed');
    }
  } catch (e) {
    setState(() => _error = 'OTP verification failed: ${e.toString()}');
  } finally {
    setState(() => _loading = false);
  }
} 

  @override
Widget build(BuildContext context) {
  return Styling(
    child: Column(
      children: [
        AppBar(title: const Text('Pensioner Login')), 
        Expanded(
          child: Padding(
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
                if (_otpSent) ...[
                    Text('OTP sent to $_phoneNumber',
                        style: const TextStyle(color: Colors.green)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otpController,
                      decoration: const InputDecoration(labelText: 'Enter OTP'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
  onPressed: _loading
      ? null
      : () => _verifyOtp(_otpController.text.trim()),
  child: const Text('Verify OTP'),
)

                  ] else ...[
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: const Text('Login'),
                    ),
                  ],
                if (_loading) const CircularProgressIndicator(),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}