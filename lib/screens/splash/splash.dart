import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> _refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
          body: jsonEncode({'refresh_token': refreshToken, 'type': 'refresh'}));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);

        Navigator.pushReplacementNamed(context, '/home');


      } else {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        Navigator.pushReplacementNamed(context, '/login');
      }
    }

    if (refreshToken == "" || refreshToken == null) {
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshToken();
  }

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
