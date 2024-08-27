import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:testing/home.dart';

class VerificationPage extends StatefulWidget {
  final String phoneNumber;

  const VerificationPage({required this.phoneNumber});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _codeController = TextEditingController();

  Future<void> _verifyCode() async {
    await dotenv.load(
      fileName: ".env",
    );

    final serviceId = dotenv.env['TWILIO_SERVICE_ID'] ?? '';
    final accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
    final authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';

    final url = Uri.parse(
        'https://verify.twilio.com/v2/Services/$serviceId/VerificationCheck');

    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'To': widget.phoneNumber,
        'Code': _codeController.text,
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'approved') {
        // Código correcto, navegar a la página de inicio.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } else {
        // Código incorrecto
        print('Incorrect code');
      }
    } else {
      // Manejo del error
      print('Error verifying code: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Verification Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Enter verification code',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('Verify Code'),
            ),
          ],
        ),
      ),
    );
  }
}
