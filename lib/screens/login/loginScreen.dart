import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:samiti/analytics/mxpanel.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  PhoneNumberField({required this.controller, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Enter your phone number',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/1200px-Flag_of_India.svg.png',
            height: 6,  // adjust size as needed
            width: 9,  // adjust size as needed
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final SharedPreferences prefs;

  LoginForm(this.prefs);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
    });
    var url = Uri.parse('http://localhost:8080/v1/auth/login/initiate');
    var response = await http.post(url,
        headers: {
          'accept': 'application/json',
          'Clientsecret': 'xuz',
          'Clientid': 'djls',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'phone': '91' + _phoneController.text}));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('OTP sent')));
    } else {
      _errorMessage = 'Failed to send OTP';
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    var url = Uri.parse('http://localhost:8080/v1/auth/login');
    var response = await http.post(url,
        headers: {
          'accept': 'application/json',
          'Clientsecret': 'fds',
          'Clientid': 'fs',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'phone': '91' + _phoneController.text, 'otp': _otpController.text}));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await widget.prefs.setString('access_token', data['access_token']);
      await widget.prefs.setString('access_token', data['access_token']);
      await widget.prefs.setString('user_id', data['user_id']);
      await widget.prefs.setString('user_name', data['user_name']);
    mxIdentify(data['user_id']);
     mxTrack("login_success", {
        'user_id': data['user_id'],
      });

      Navigator.pushReplacementNamed(context, '/home');
    } else {

      _errorMessage = 'Failed to login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Transform.translate(
                offset: Offset(0, -0.3 * constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Image.network(
                        //   'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg', // replace this with the URL of your image
                        //   height: 50,
                        // ),
                        Text(
                          'Login',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (_otpSent)
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              setState(() {
                                _otpSent = false;
                              });
                            },
                          ),
                        PhoneNumberField(
                          controller: _phoneController,
                          enabled: !_otpSent,
                        ),
                        if (_otpSent)
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Enter your OTP'),
                          ),
                        ElevatedButton(
                          onPressed: _otpSent ? _login : _sendOTP,
                          child: Text(_otpSent ? 'Login' : 'Send OTP'),
                        ),
                        if (_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
