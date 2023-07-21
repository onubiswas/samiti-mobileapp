import 'package:flutter/material.dart';
import 'package:samiti/models/samiti_list_response.dart';

class SamitiListCard extends StatelessWidget {
  final SamitiListItem item;

  SamitiListCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      height: screenHeight * 0.11, // Increased height by using 15% of screen height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0), // round corners
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 40.0, // larger icon
              ),
              SizedBox(width: 16.0), // Space between icon and text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(fontSize: 24.0), // larger text
                  ),
                  Text(
                    item.id,
                  ),
                ],
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios), // arrow on the right
        ],
      ),
    );
  }
}
