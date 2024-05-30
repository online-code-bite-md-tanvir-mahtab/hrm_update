import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/location.dart';
import 'package:hrm_attendance_application_test/screen/loginscreen.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:location/location.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // creating the build method
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Splash Screen",
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<Splash> {
  bool animate = false;

  @override
  void initState() {
    super.initState();
    checklocationstatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shampan HRM",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Give Your\nAttendance Here",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Image(
                  image: AssetImage('images/symphony-logo-small.jpg'),
                ),
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }

/** this is my design  so i will use if after creating new one */
  Widget myDesign() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 208, 208, 208),
                Color.fromARGB(255, 255, 255, 255),
              ]),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  "Welcome To Attendance System",
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
                Text(
                  "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Future checklocationstatus() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String>? token_data = pref.getStringList('token');
    String? name = pref.getString('name');
    await Future.delayed(Duration(milliseconds: 500));
    setState(() => animate = true);
    await Future.delayed(Duration(seconds: 2)); // Updated duration to seconds
    // Rest of your code remains the same...
    bool serviceEnabled;
    var location = Location();
    PermissionStatus permissionGranted;
    serviceEnabled = await location.serviceEnabled();
    // LocationData loc =await location.getLocation();
    permissionGranted = await location.hasPermission();
    // try {
    //   print(serviceEnabled);
    //   print(await location.hasPermission());
    //   permissionGranted = await location.requestPermission();
    //   print(permissionGranted);
    // } catch (e) {
    //   print(e);
    // }
    print("from page 1 ${permissionGranted}");
    if ((permissionGranted == PermissionStatus.deniedForever) ||
        (permissionGranted == PermissionStatus.denied)) {
      // print(location.getLocation());
      Timer(
        const Duration(seconds: 1),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyLocation(),
          ),
        ),
      );
    } else {
      if (serviceEnabled) {
        serviceEnabled = await location.serviceEnabled();
        // LocationData loc =await location.getLocation();
        permissionGranted = await location.hasPermission();
        if ((permissionGranted == PermissionStatus.deniedForever) ||
            (permissionGranted == PermissionStatus.denied)) {
          // print(location.getLocation());
          Timer(
            const Duration(seconds: 1),
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MyLocation(),
              ),
            ),
          );
        } else {
          if (token_data == null) {
            print(token_data?.length);
            Timer(
              const Duration(seconds: 1),
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),
                ),
              ),
            );
          } else {
            print(token_data.length);
            Token token = Token(
                access_token: token_data[0],
                token_type: token_data[1],
                expired_time: 123434);

            Timer(
              const Duration(seconds: 1),
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(token: token, userName: name.toString()),
                ),
              ),
            );
          }
        }
        ;
      } else {
        Dialogs.materialDialog(
          msg: 'Your Location will be accessed for better performance',
          title: "Location Message",
          color: Colors.white,
          context: context,
          actions: [
            IconsOutlineButton(
              onPressed: () {
                exit(0);
              },
              text: 'Cancel',
              iconData: Icons.cancel_outlined,
              textStyle: TextStyle(color: Colors.grey),
              iconColor: Colors.grey,
            ),
            IconsButton(
              onPressed: () async {
                serviceEnabled = await location.serviceEnabled();
                bool serviceStatus = await location.requestService();
                permissionGranted = await location.hasPermission();
                if (((permissionGranted == PermissionStatus.deniedForever) ||
                        (permissionGranted == PermissionStatus.denied)) &&
                    (serviceStatus == false)) {
                  // print(location.getLocation());
                  Timer(
                    const Duration(seconds: 1),
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyLocation(),
                      ),
                    ),
                  );
                } else {
                  if (token_data == null) {
                    print(token_data?.length);
                    Timer(
                      const Duration(seconds: 1),
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Home(),
                        ),
                      ),
                    );
                  } else {
                    print(token_data.length);
                    Token token = Token(
                        access_token: token_data[0],
                        token_type: token_data[1],
                        expired_time: 123434);

                    Timer(
                      const Duration(seconds: 1),
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                              token: token, userName: name.toString()),
                        ),
                      ),
                    );
                  }
                }
                ;
              },
              text: 'Yes',
              iconData: Icons.skip_next,
              color: Colors.red,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ],
        );
      }
    }
  }
}
