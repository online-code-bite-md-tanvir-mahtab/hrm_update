import 'dart:convert';
import 'dart:io';
// import 'dart:js_interop';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendancedashboard.dart';
import 'package:hrm_attendance_application_test/screen/leavedashboard.dart';
import 'package:hrm_attendance_application_test/util/attendancepolicyinfo.dart';
import 'package:hrm_attendance_application_test/util/policyItem.dart';
import 'package:hrm_attendance_application_test/util/result.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hrm_attendance_application_test/screen/attendance.dart';
import 'package:hrm_attendance_application_test/screen/leave.dart';
import 'package:hrm_attendance_application_test/screen/loginscreen.dart';
import 'package:hrm_attendance_application_test/screen/testProfile.dart';
import 'package:hrm_attendance_application_test/util/info.dart';

import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';
import 'package:internet_popup/internet_popup.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> paths = [
  "images/dummy-profile-pic-300x300.jpg",
  "images/ben-o-bro-C5XyLljkMrY-unsplash.jpg",
  "images/brooke-cagle-k9XZPpPHDho-unsplash.jpg"
];

final ColorPicker colorPicker = ColorPicker();
int page_index = 0;
late dynamic userInfo = UserInfo(
    success: true,
    code: 200,
    result: Result(
        fullName: "",
        logId: "",
        employeeId: "",
        designationName: "",
        sectionName: "",
        departmentName: "",
        joinDate: "",
        projectName: "",
        photoName: "",
        isAdmin: ""));

class HomeScreen extends StatefulWidget {
  // const HomeScreen({super.key});
  const HomeScreen({super.key, required this.token, required this.userName});
  final Token token;
  final String userName;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // print(userInfo.isNull);
    return _HomeBody(token, userName);
  }
}

class _HomeNoBody extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.black,
        size: 100,
      ),
    );
  }
}

List<PolicyItem> policyes = [];
bool isDone = false;

class _HomeBody extends State<HomeScreen> {
  Token htoken;
  UrlManager urls = UrlManager();
  String huserName;
  _HomeBody(this.htoken, this.huserName);

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    isConnected().then((value) {
      showInternetStatusToast(value);
    });
    getuserinfo(context, htoken.token_type, htoken.access_token, huserName)
        .then((value) {
      setState(() {
        userInfo = value;
        print("the result : ${userInfo.success}");
      });
    });
    getPolicy(huserName, htoken).then((value) {
      setState(() {});
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

  bool isData() {
    // Simulate an API call or data loading process
    Future.delayed(Duration(seconds: 2), () {
      if (userInfo.result.fullName.isEmpty) {
        setState(() {
          isDone = true;
        });
      } else {
        setState(() {
          isDone = false;
        });
      }
    });
    // Wait for 2 seconds

    return isDone;
  }

  @override
  Widget build(BuildContext context) {
    int backButtonPressCount = 0;
    // var screenSize = MediaQuery.of(context).size.height
    // Random random = Random();
    // int randomIndex = random.nextInt(paths.length);
    // String selectedPath = paths[randomIndex];
    final screenSize = MediaQuery.of(context).size;

    return userInfo.result.logId.isEmpty
        ? isData()
            ? Container(
                color: Colors.white,
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.black,
                    size: 100,
                  ),
                ),
              )
            : Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.black,
                  size: 100,
                ),
              )
        : MaterialApp(
            home: SafeArea(
              child: WillPopScope(
                onWillPop: () async {
                  if (backButtonPressCount < 2) {
                    // Display a toast message on the first press
                    Fluttertoast.showToast(msg: "Press Again To Exit");
                    backButtonPressCount++;
                    return false; // Prevent app from exiting
                  } else {
                    // Handle exit on the second press
                    return true; // Allow app to exit
                  }
                },
                child: Scaffold(
                  body: Container(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 60.0),
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
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TestProfile(
                                          info: userInfo,
                                          userName: huserName,
                                          token: htoken),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Container(
                            margin: EdgeInsets.only(top: screenSize.height / 4),
                            child: Card(
                              elevation: 10,
                              shadowColor: Colors.black,
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: screenSize.width / 1.2,
                                padding:
                                    EdgeInsets.only(top: 30.0, bottom: 30.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                77, 238, 234, 234),
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                          ),
                                          child: IconButton(
                                            icon: Image.asset(
                                                "images/assets/attendance.png"),
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AttendanceDashboard(
                                                          mToken: htoken,
                                                          mUserName: huserName,
                                                          mUserInfo: userInfo),
                                                ),
                                              );
                                            },
                                            iconSize: 50.0,
                                          ),
                                        ),
                                        Text(
                                          "Attendance",
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                77, 238, 234, 234),
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                          ),
                                          child: IconButton(
                                            icon: Image.asset(
                                                "images/assets/leave.png"),
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LeaveDashboard(
                                                          mToken: htoken,
                                                          mUserName: huserName,
                                                          mUserInfo: userInfo),
                                                ),
                                              );
                                            },
                                            iconSize: 50.0,
                                          ),
                                        ),
                                        Text(
                                          "Leave",
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    backgroundColor: Color(colorPicker.appbarBackgroudncolor),
                    elevation: 0,
                    leading: InkWell(
                      onTap: () {
                        print("The profile page");
                      },
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          child: Image.asset(
                            url_manager.image_path,
                            width: 30,
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    centerTitle: true,
                    title: Text(
                      "Dashboard",
                      style: TextStyle(
                        color: colorPicker.footerText,
                      ),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.remove('token');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        },
                        child: Image(
                          image: AssetImage(
                            'images/assets/log-out.png',
                          ),
                          width: 30.0,
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: NavigationBar(
                    backgroundColor: Color(colorPicker.navbarBackgroundcolor),
                    height: 64,
                    destinations: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: page_index == 0
                                ? null
                                : () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(
                                          userName: huserName,
                                          token: htoken,
                                        ),
                                      ),
                                    );
                                  },
                            child: Image.asset(
                              'images/assets/home.png',
                              width: screenSize.width / 7.9,
                            ),
                          ),
                          Text(
                            'Home',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10.0, color: colorPicker.footerText),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TestProfile(
                                    info: userInfo,
                                    userName: huserName,
                                    token: htoken,
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(
                              'images/assets/profile.png',
                              width: screenSize.width / 7.9,
                            ),
                          ),
                          Text(
                            'Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10.0, color: colorPicker.footerText),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceDashboard(
                                      mToken: htoken,
                                      mUserName: huserName,
                                      mUserInfo: userInfo),
                                ),
                              );
                            },
                            child: Image.asset(
                              'images/assets/attendance.png',
                              width: screenSize.width / 7.9,
                            ),
                          ),
                          Text(
                            'Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.0,
                              color: colorPicker.footerText,
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeaveDashboard(
                                    mToken: htoken,
                                    mUserName: huserName,
                                    mUserInfo: userInfo,
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(
                              'images/assets/leave.png',
                              width: screenSize.width / 7.9,
                            ),
                          ),
                          Text(
                            'Leave',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10.0, color: colorPicker.footerText),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

UrlManager urls = UrlManager();

Future<dynamic> getuserinfo(
    BuildContext context, token_type, access_token, user_name) async {
  // user_name = '6';
  final url2 = Uri.parse('${urls.token_url}/api/User/UserInfo/${user_name}');
  final headers2 = {
    'Authorization': '${token_type} ${access_token}',
  };
  try {
    final response2 = await http.post(url2, headers: headers2);
    print(response2);
    if (response2.statusCode == 200) {
      final jsonData = await jsonDecode(response2.body);
      UserInfo info = await UserInfo.fromJson(jsonData);
      print(info.result.fullName);
      dynamic uinfo = await UserInfo(
        success: info.success,
        code: info.code,
        result: info.result,
      );
      return uinfo;
    } else {
      Fluttertoast.showToast(msg: "Server problem");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}

class ActionButton extends StatelessWidget {
  ActionButton(this.name, this.dToken, this.dUserInfo);
  final String name;
  final Token dToken;
  final UserInfo dUserInfo;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final String u_n_2 = name;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceDashboard(
                      mToken: dToken, mUserName: name, mUserInfo: dUserInfo),
                ),
              );
            },
            child: Text("Attendance"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaveDialogExampleapp(
                    mToken: dToken,
                    mUserName: name,
                    mUserInof: dUserInfo,
                  ),
                ),
              );
            },
            child: Text("Leave"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 1.0,
        ),
      ],
    );
  }
}

Future<void> getPolicy(String sUserId, Token sToken) async {
  final url = Uri.parse(
      '${url_manager.token_url}/api/Attendance/GetTimePolicy/${sUserId}');
  try {
    final header = {
      "Authorization": "${sToken.token_type} ${sToken.access_token}",
    };
    final response = await http.get(
      url,
      headers: header,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      AttendancePolicyInfo info = AttendancePolicyInfo.fromJson(json);
      policyes = info.result;
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}
