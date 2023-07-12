import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs;

  MyApp(this.prefs);

  Future<void> _refreshToken(SharedPreferences prefs) async {
    var refreshToken = prefs.getString('refresh_token');

    if (refreshToken != null) {
      var url = Uri.parse('http://localhost:8080/v1/auth/token/refresh');
      var response = await http.post(url,
          headers: {
            'accept': 'application/json',
            'Clientsecret': 'xuz',
            'Clientid': 'djls',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'refresh_token': refreshToken}));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);
      } else {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else {
          final prefs = snapshot.data;
          if (prefs != null) {
            _refreshToken(prefs);
            return MaterialApp(
              home: prefs.getString('refresh_token') != null ? HomePage(prefs) : Scaffold(body: SafeArea(child: LoginForm(prefs))),
            );
          } else {
            // handle the case when prefs is null (this is unlikely but better to be safe)
            return MaterialApp(home: Scaffold(body: Center(child: Text('Failed to get preferences'))));
          }
        }
      },
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(widget.prefs)));
    } else {
      _errorMessage = 'Failed to login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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

class HomePage extends StatelessWidget {
  final SharedPreferences prefs;

  HomePage(this.prefs);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await prefs.remove('access_token');
                await prefs.remove('refresh_token');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginForm(prefs)));
              }),
        ],
      ),
      body: Center(
        child: Text('Home Page Content'),
      ),
    );
  }
}
