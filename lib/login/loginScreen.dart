import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



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
        body: jsonEncode({'phone': _phoneController.text}));

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
            {'phone': _phoneController.text, 'otp': _otpController.text}));

    setState(() {
      _isLoading = false;
    });

     if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await widget.prefs.setString('access_token', data['access_token']);
      await widget.prefs.setString('refresh_token', data['refresh_token']);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _errorMessage = 'Failed to login';
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg', // replace this with the URL of your image
                      height: 50,
                    ),
                    Text(
                      'Super Samiti',
                      style: Theme.of(context).textTheme.headline5,
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
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_otpSent,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Enter your phone number'),
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
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
