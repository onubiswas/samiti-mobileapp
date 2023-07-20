
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../donate/donate.dart';
import '../samiti/samiti.dart';


class HomePage extends StatefulWidget {
  final SharedPreferences prefs;

  HomePage(this.prefs);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final tabs = [
    SamitiTabScreen(),
    ProfileTab(),
    DonateScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: null,
      appBar: AppBar(
        title: Text("SamitiApp"),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await widget.prefs.remove('access_token');
                await widget.prefs.remove('refresh_token');
                Navigator.pushReplacementNamed(context, '/login');
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
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: 'Donate',
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




class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile'));
  }
}
