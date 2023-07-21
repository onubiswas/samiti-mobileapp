import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:samiti/models/samiti_list_response.dart';
import 'package:samiti/screens/samiti/detail/samiti.dart';
import 'package:samiti/screens/samiti/widget/samiti_list_card.dart';
import 'package:samiti/screens/samiti/widget/find_samiti_modal.dart';
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

  void _navigateToCreateSamiti() {
    Navigator.of(context).pushNamed('/create-samiti');
  }

  void _openFindSamitiModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return FindSamitiModal();
        });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: EdgeInsets.only(top: 16.0),  // padding at the top
      child: RefreshIndicator(
        onRefresh: fetchSamitiList,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // reduced vertical padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Samiti List',
                          style: TextStyle(
                            fontSize: 28.0, // large text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/create-samiti');
                              },
                              child: Text('Create Samiti', style: TextStyle(color: Colors.blue)),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(width: 16.0),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(child: FindSamitiModal()),
                                );
                              },
                              child: Text('Find Samiti', style: TextStyle(color: Colors.blue)),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: samitiList != null && samitiList!.items.isNotEmpty
                        ? ListView.builder(
                            itemCount: samitiList!.items.length,
                            itemBuilder: (context, index) {
                              final item = samitiList!.items[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SamitiDetailScreen(samitiId: item.id, samitiName: item.name,),
                                    ),
                                  );
                                },
                                child: SamitiListCard(item: item),
                              );
                            },
                          )
                        : Center(
                            child: Text('No Samiti Found'), // displayed when list is empty
                          ),
                  ),
                ],
              ),
      ),
    ),
  );
}

}
