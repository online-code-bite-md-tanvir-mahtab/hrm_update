import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
// import 'package:hrm_attendance_application_test/screen/loginscreen.dart';
// import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

UrlManager urls = UrlManager();
final TextEditingController _controller = TextEditingController();
final TextEditingController _controller2 = TextEditingController();

// this is widget fucntion that will create input field the in widget
Widget user_name_field(String text_title, String hinttext) {
  return Center(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text_title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          SizedBox(
            width: 254.0,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(217, 217, 217, 217),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    11,
                  ),
                ),
                hintText: hinttext,
                hintStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.man)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class User_Password_Field extends StatefulWidget {
  const User_Password_Field({required this.text_title, required this.hinttext});
  final String text_title;
  final String hinttext;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _User_Password_Field(text_title, hinttext);
  }
}

class _User_Password_Field extends State<User_Password_Field> {
  String title;
  String htext;
  _User_Password_Field(this.title, this.htext);
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // Track whether the password is visible or hidden

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14, // Increase the font size for the label
                fontWeight: FontWeight.bold, // Make the label bold
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(
              width: 254.0,
              child: TextField(
                controller: _controller2,
                obscureText:
                    !isPasswordVisible, // Show/hide the password based on visibility
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(217, 217, 217, 217),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  hintText: htext,
                  hintStyle: TextStyle(
                    fontSize: 12, // Adjust the font size for the hint
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: Padding(
                    child: Icon(
                      Icons.key,
                    ),
                    padding: EdgeInsets.only(
                      right: 10.0,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;

                        print("visible");
                      });
                    },
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons
                              .visibility, // Show different icons based on visibility
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NaveLogin extends StatefulWidget {
  const NaveLogin({super.key});

  @override
  State<NaveLogin> createState() {
    return navto_dashboard_button();
  }
}

class navto_dashboard_button extends State<NaveLogin> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text("login clicked..."),
            ),
          );
        show(context);
      },
      child: Text(
        "Log In",
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            11.0,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 105,
          vertical: 20,
        ),
      ),
    );
  }
}

Future<void> show(BuildContext context) async {
  String user_name = _controller.text;
  String user_password = _controller2.text;
  if (user_name.length == 0) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("Username is required!"),
        ),
      );
  } else if (user_password.length == 0) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("Password is required!"),
        ),
      );
  } else {
    final url = Uri.parse('${urls.token_url}/token');
    final heads = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final bod = {
      'grant_type': 'password',
      'username': user_name,
      'password': user_password,
    };

    try {
      dynamic response = await http
          .post(
            url,
            headers: heads,
            body: bod,
          )
          .timeout(Duration(seconds: 40));
      // response.persistentConnection = false;
      print(response.statusCode);
      if (response.statusCode.toInt() == 200) {
        final data = jsonDecode(response.body);
        Token object = Token.fromJson(data);
        object.expired_time;
        print(object.expired_time);
        // await Future.delayed(Duration(seconds: 2));
        // get_info_user(userId: user_name);
        await ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text("Welcome"),
            ),
          );
        SharedPreferences pref = await SharedPreferences.getInstance();

        await pref.setStringList('token', [
          object.access_token.toString(),
          object.token_type.toString(),
          object.expired_time.toString(),
        ]);

        await pref.setString('name', user_name);
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              token: Token(
                access_token: object.access_token,
                token_type: object.token_type,
                expired_time: object.expired_time,
              ),
              userName: user_name,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text("Username or Password is incorrect!"),
            ),
          );
      }
    } catch (e) {
      print("The login error: " + e.toString());
      // Error handling for exceptions
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.toString() + "Please try again"),
          ),
        );
    }
  }
}
