import 'dart:convert';

import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static Future<void> setAuthenticated(bool isAuthenticated) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAuthenticated', isAuthenticated);
  }

  static Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    return isAuthenticated;
  }

  void saveClassesToSharedPreferences(
      String user_name, Token user_token, UserInfo user_info) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('user_name', json.encode(user_name));
    prefs.setString('user_info', json.encode(user_info));
    prefs.setString('user_token', json.encode(user_token));
  }
}
