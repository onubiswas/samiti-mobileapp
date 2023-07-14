import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'home/home.dart';
import 'login/loginScreen.dart';
import 'splash/splash.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
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
        '/login': (context) => LoginForm(prefs),
        '/home': (context) => HomePage(prefs),
      },
    );
  }
}
