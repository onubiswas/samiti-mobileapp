import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:samiti/models/samiti_detail.dart';
import 'package:samiti/screens/samiti/detail/membership_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class SamitiDetailScreen extends StatefulWidget {
  final String samitiName;
  final String samitiId;

  SamitiDetailScreen({required this.samitiName, required this.samitiId});

  @override
  _SamitiDetailScreenState createState() => _SamitiDetailScreenState();
}

class _SamitiDetailScreenState extends State<SamitiDetailScreen> {
  DetailedSamitiApiResponse? apiResponse;
  DetailedSamiti? detailedSamiti;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:8080/v1/samiti/${widget.samitiId}'),
      headers: {'Authorization': accessToken},
    );

    if (response.statusCode == 200) {
      apiResponse = DetailedSamitiApiResponse.fromJson(jsonDecode(response.body));
      detailedSamiti = apiResponse?.item;
      print(apiResponse?.item);
      setState(() {});  // To update UI
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      throw Exception('Failed to load Samiti details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, 
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Activity'),
              Tab(text: 'Details'),
              Tab(text: 'Mutual Funds'),
              Tab(text: 'Borrowings'),
            ],
          ),
          title: Column(
            children: [
              Text(widget.samitiName),
              detailedSamiti != null
                  ? Text('Balance: ${detailedSamiti!.balance}', style: TextStyle(fontSize: 16))
                  : Container()
            ],
          ),
        ),
        body: detailedSamiti == null 
            ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
              ),
            )
            : TabBarView(
                children: [
                  ListView.builder(
                    itemCount: detailedSamiti!.members.values.length,
                    itemBuilder: (context, index) {
                      return MemberCard(member: detailedSamiti!.members.values.toList()[index]);
                    },
                  ),
                  // Add other views here for the other tabs.
                  // As a placeholder, I am using Container().
                  Container(),
                  Container(),
                  Container(),
                  Container(),
                ],
              ),
      ),
    );
  }
}

