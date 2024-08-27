import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing/verify_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(
    fileName: ".env",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale("en"),
        Locale("es"),
        // Add other locales if needed
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: PhonePage(),
    );
  }
}

class PhonePage extends StatefulWidget {
  @override
  _PhonePageState createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+'; // Default to US

  Future<void> _sendVerificationCode() async {
    final serviceId = dotenv.env['TWILIO_SERVICE_ID'] ?? '';
    final accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
    final authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';

    final url = Uri.parse(
        'https://verify.twilio.com/v2/Services/$serviceId/Verifications');

    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'To': '$_selectedCountryCode${_phoneController.text}',
        'Channel': 'sms',
      },
    );

    if (response.statusCode == 201) {
      // Código de verificación enviado, navegar a la página de código.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationPage(
            phoneNumber: '$_selectedCountryCode${_phoneController.text}',
          ),
        ),
      );
    } else {
      print('Error sending verification code: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CountryCodePicker(
              onChanged: (code) {
                setState(() {
                  _selectedCountryCode = code.dialCode!;
                });
              },
              initialSelection: 'BO',
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              showFlag: true,
              alignLeft: true,
              showFlagDialog: false,
              padding: EdgeInsets.zero,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Enter your phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendVerificationCode,
              child: const Text('Send Verification Code'),
            ),
          ],
        ),
      ),
    );
  }
}
