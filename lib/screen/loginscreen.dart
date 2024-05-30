import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrm_attendance_application_test/navigation/navlogin.dart';
import 'package:hrm_attendance_application_test/screen/splash.dart';
import 'package:internet_popup/internet_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (isLogedIn() == false) {
      print("there is data");
      return SplashScreen();
    } else {
      print("there is no data");
      return MaterialApp(
        home: SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Container(
                color: Colors.white,
                width: double.infinity,
                child: HomeBody(),
              ),
            ),
          ),
        ),
      );
    }
  }
}

Future<bool> isLogedIn() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  List<String>? stringlist = pref.getStringList('token');

  if (stringlist == null || stringlist.isEmpty) {
    return true;
  } else {
    return false;
  }
}

class HomeBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeBody();
  }
}

class _HomeBody extends State<HomeBody> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isConnected().then((value) {
      showInternetStatusToast(value);
    });
  }

  Future<bool> isConnected() async {
    return InternetPopup().checkInternet();
  }

  void showInternetStatusToast(bool isConnected) {
    String message = isConnected
        ? "Internet is available"
        : "No internet connection, Please Connect to the Internet before using the app";

    if (!isConnected) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: isConnected ? Colors.green : Colors.red,
        textColor: Colors.white,
      );
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          exit(0);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center, // Align "Login" to the center
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 1.0,
            bottom: 20.0,
          ),
          child: const Center(
            child: Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 1.0,
            bottom: 20.0,
          ),
          child: const Center(
            child: Text(
              'Shampan HRM',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent),
            ),
          ),
        ),

        // Add some spacing between "Login" and "Email"
        user_name_field("Username", "Enter your Employee Code:"),
        User_Password_Field(
            text_title: "Password", hinttext: "Enter your password:"),
        const SizedBox(
          height: 20.0,
        ),
        const Center(
          child: NaveLogin(),
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 30.0,
            bottom: 20.0,
          ),
          child: const Center(
            child: Text(
              'Powerd By : Symphony Softtech ltd',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent),
            ),
          ),
        ),
      ],
    );
  }
}
