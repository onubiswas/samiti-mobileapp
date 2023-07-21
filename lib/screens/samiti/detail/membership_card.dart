
import 'package:flutter/material.dart';
import 'package:samiti/models/samiti_detail.dart';


class MemberCard extends StatelessWidget {
  final SamitiMember member;

  MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            member.userName.split(' ').map((name) => name[0]).join(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(member.userName),
        subtitle: Text('Permission: ${member.permission}'),
      ),
    );
  }
}

