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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<SharedPreferences>(
        future: _prefs,
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          } else {
            final prefs = snapshot.data;
            if (prefs != null) {
              _refreshToken(prefs);
              return prefs.getString('refresh_token') != null ? HomePage(prefs) : LoginForm(prefs);
            } else {
              return Scaffold(body: Center(child: Text('Failed to get preferences')));
            }
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text('Loading...'),
            ),
          ],
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

class HomePage extends StatefulWidget {
  final SharedPreferences prefs;

  HomePage(this.prefs);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final tabs = [
    Center(child: Text('Home')),
    Center(child: Text('Search')),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await widget.prefs.remove('access_token');
                await widget.prefs.remove('refresh_token');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginForm(widget.prefs)));
              }),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
