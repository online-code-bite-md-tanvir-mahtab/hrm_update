import 'package:flutter/material.dart';
import 'package:hrm_attendance_application_test/screen/loginscreen.dart';
import 'package:hrm_attendance_application_test/screen/splash.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Location Screen Enable",
      home: LocationSplash(),
    );
  }
}

class LocationSplash extends StatefulWidget {
  @override
  LocationSplashState createState() => LocationSplashState();
}

class LocationSplashState extends State<LocationSplash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: InteractiveViewer(
          child: Container(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      "Enable Location",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 68, 66, 66),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Image.asset("images/location.jpg"),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () async {
                      var location = Location();
                      var permission = await location.requestPermission();
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      List<String>? token_data = pref.getStringList('token');
                      String? name = pref.getString('name');
                      while (permission != PermissionStatus.granted) {
                        var permission = await location.requestPermission();
                        if (permission == PermissionStatus.granted) {
                          print(token_data?.length);
                          if (token_data == null || token_data.isEmpty) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SplashScreen(),
                              ),
                            );
                          }

                          break;
                        } else if (permission ==
                            PermissionStatus.deniedForever) {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "You need to enable the location",
                                ),
                              ),
                            );
                          break;
                        } else {
                          continue;
                        }
                      }
                      // var permission = await location.requestPermission();
                      if (permission == PermissionStatus.granted) {
                        if (token_data == null || token_data.isEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplashScreen(),
                            ),
                          );
                        }
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => Home()),
                        // );
                      }
                    },
                    child: const Text("Enable"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
