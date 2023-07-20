import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:samiti/models/samiti_list_response.dart';
import 'package:samiti/screens/samiti/detail.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SamitiTabScreen extends StatefulWidget {
  @override
  _SamitiTabScreenState createState() => _SamitiTabScreenState();
}

class _SamitiTabScreenState extends State<SamitiTabScreen> {
  SamitiListResponse? samitiList;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSamitiList();
  }

  Future<void> fetchSamitiList() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    try {
      http.Response response = await http.get(
        Uri.parse('http://localhost:8080/v1/samiti/'),
        headers: {
          "authorization": "$accessToken",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          samitiList = SamitiListResponse.fromJson(jsonDecode(response.body));
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user_id');
        await prefs.remove('user_name');
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/login', (Route<dynamic> route) => false);
      } else {
        throw Exception('Failed to load samiti');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchSamitiList,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: samitiList?.items.length ?? 0,
                itemBuilder: (context, index) {
                  final item = samitiList!.items[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SamitiDetailScreen(id: item.id),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.id),
                        leading: Icon(Icons.person, color: Colors.teal),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: samitiList == null || samitiList!.items.isEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/create-samiti');
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}
