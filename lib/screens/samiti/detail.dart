import 'package:flutter/material.dart';

class SamitiDetailScreen extends StatelessWidget {
  final String samitiName;
  final String samitiId;

  SamitiDetailScreen({required this.samitiName, required this.samitiId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(samitiName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Center(child: Text('Samiti ID: $samitiId')),
    );
  }
}
