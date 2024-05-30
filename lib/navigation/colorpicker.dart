import 'package:flutter/material.dart';
import 'package:hrm_attendance_application_test/util/info.dart';

class ColorPicker {
  final footerText = Colors.white;
  final navbarBackgroundcolor = 0xff58bc08;
  final appbarBackgroudncolor = 0xFF79c939;

  Widget testProfielCard(UserInfo userInfo) {
    return Container(
      margin: EdgeInsets.only(top: 6.0),
      child: Hero(
        tag: 'ListTile-Hero',
        child: Card(
          child: ListTile(
            minVerticalPadding: 20.0,
            tileColor: Color.fromARGB(255, 238, 239, 241),
            leading: CircleAvatar(
              // backgroundImage: NetworkImage(
              //   "${urls.token_url}${userInfo.result.photoName}",
              // ),
              backgroundImage: AssetImage(
                'images/assets/profile.png',
              ),
              backgroundColor: Color(0xFFF6F7F9),
            ),
            title: Text(userInfo.result.fullName),
          ),
        ),
      ),
    );
  }
}
