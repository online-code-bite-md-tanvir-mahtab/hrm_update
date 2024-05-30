import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/adminleaveinfo.dart';
import 'package:hrm_attendance_application_test/screen/attendancedashboard.dart';
import 'package:hrm_attendance_application_test/screen/genarateScreen1.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/leave.dart';
import 'package:hrm_attendance_application_test/screen/leavebalance.dart';
import 'package:hrm_attendance_application_test/screen/supervisorleave.dart';
import 'package:hrm_attendance_application_test/screen/testProfile.dart';
import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/leaveinfo.dart';
import 'package:hrm_attendance_application_test/util/leaveitem.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';

import 'package:http/http.dart' as http;

int page_index = 3;
List<LeaveItem> admin_atten = [];
final ColorPicker colorPicker = ColorPicker();

class LeaveDashboard extends StatelessWidget {
  LeaveDashboard(
      {super.key,
      required this.mToken,
      required this.mUserName,
      required this.mUserInfo});
  final Token mToken;
  final String mUserName;
  final UserInfo mUserInfo;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DashboardBody(mToken, mUserName, mUserInfo);
  }
}

class DashboardBody extends StatefulWidget {
  DashboardBody(this.stoken, this.susername, this.sInfo);
  final Token stoken;
  final String susername;
  final UserInfo sInfo;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DashboardBody(stoken, susername, sInfo);
  }
}

String logId = '';

class _DashboardBody extends State<DashboardBody> {
  _DashboardBody(this.mtoken, this.dusername, this.dInfo);
  final Token mtoken;
  final String dusername;
  final UserInfo dInfo;

  List<LeaveItem> filterdata = [];
  List<LeaveItem> filterdata2 = [];
  @override
  void initState() {
    logId = dInfo.result.logId.replaceAll(' ', '');
    getSuperInfoForLeave(mtoken, dusername, dInfo).then((value) {
      setState(() {
        // isClicked = false;
        // DateTime now = DateTime.now();
        // String formattedDate = DateFormat('yyyy-MM-dd').format(now);
        // leave_from_date.text = formattedDate.toString();
        // leave_to_date.text = formattedDate.toString();
        filterdata = super_atten;
      });
    });

    getAdminInfoForLeave(mtoken, dusername, dInfo).then((value) {
      setState(() {
        filterdata2 = admin_atten;
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    int backButtonPressCount = 0;
    // TODO: implement build
    return MaterialApp(
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
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: colorPicker.footerText,
                ),
                color: Color(colorPicker.appbarBackgroudncolor),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(token: mtoken, userName: dusername),
                    ),
                  );
                },
              ),
              elevation: 0,
              backgroundColor: Color(colorPicker.appbarBackgroudncolor),
              title: Text(
                'Leave Dashboard',
                style: TextStyle(
                  color: colorPicker.footerText,
                ),
              ),
            ),
            body: Container(
              margin: EdgeInsets.only(left: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 0,
                    child: Container(
                      margin: EdgeInsets.only(top: screenSize.height / 100),
                      child: Visibility(
                        visible: userInfo.result.isAdmin == "True" ||
                            logId != "Admin",
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 10.0,
                          child: Container(
                            width: screenSize.width / 1.2,
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(77, 238, 234, 234),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: IconButton(
                                        icon: Image.asset(
                                            "images/assets/new-leave.png"),
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LeaveBalance(
                                                      mToken: mtoken,
                                                      dUserName: dusername,
                                                      dUserInfo: dInfo),
                                            ),
                                          );
                                        },
                                        iconSize: 50.0,
                                      ),
                                    ),
                                    Text(
                                      "New Leave",
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
                                        color:
                                            Color.fromARGB(77, 238, 234, 234),
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
                                                  LeaveDialogExampleapp(
                                                      mToken: mtoken,
                                                      mUserName: dusername,
                                                      mUserInof: dInfo),
                                            ),
                                          );
                                        },
                                        iconSize: 50.0,
                                      ),
                                    ),
                                    Text(
                                      "Leave Info",
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // this is for report menue
                  Visibility(
                    visible:
                        userInfo.result.isAdmin == "True" || logId != "Admin",
                    child: Expanded(
                      flex: 0,
                      child: Container(
                        // margin: EdgeInsets.only(top: screenSize.height / 4),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 10,
                          child: Container(
                            width: screenSize.width / 1.2,
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(77, 238, 234, 234),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: IconButton(
                                        icon: Image.asset(
                                            "images/assets/report.png"),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SelectDateRange(
                                                      zUserName: dusername,
                                                      zToken: mtoken,
                                                      zReportType: 'Leave',
                                                      dInof: dInfo),
                                            ),
                                          );
                                        },
                                        iconSize: 50.0,
                                      ),
                                    ),
                                    Text(
                                      "Report",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Container(
                      margin: EdgeInsets.only(top: screenSize.height / 15),
                      // TODO: this is where i need to modify the work
                      child: Visibility(
                        visible: userInfo.result.isAdmin == "True" &&
                            logId != "Admin",
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            width: screenSize.width / 1.2,
                            // height: 300,
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible: userInfo.result.isAdmin == "True" &&
                                      logId != "Admin",
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(77, 238, 234, 234),
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                              "images/assets/supervisor.png"),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SuperVisorLeave(
                                                        mToken: mtoken,
                                                        mUserName: dusername,
                                                        mUserInof: dInfo),
                                              ),
                                            );
                                          },
                                          iconSize: 50.0,
                                        ),
                                      ),
                                      Text(
                                        "Supervisor",
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Visibility(
                                  visible: userInfo.result.isAdmin == "True" ||
                                      logId == "Admin",
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(77, 238, 234, 234),
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                              "images/assets/admin.png"),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AdminLeaveInfo(
                                                        mToken: mtoken,
                                                        mUserName: dusername,
                                                        mUserInof: dInfo),
                                              ),
                                            );
                                          },
                                          iconSize: 50.0,
                                        ),
                                      ),
                                      Text(
                                        "Admin",
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: NavigationBar(
              backgroundColor: Color(colorPicker.navbarBackgroundcolor),
              height: 64,
              destinations: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              userName: dusername,
                              token: mtoken,
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
                              info: dInfo,
                              userName: dusername,
                              token: mtoken,
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
                                mToken: mtoken,
                                mUserName: dusername,
                                mUserInfo: dInfo),
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
                          fontSize: 10.0, color: colorPicker.footerText),
                    )
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: page_index == 3
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeaveDashboard(
                                      mToken: mtoken,
                                      mUserName: dusername,
                                      mUserInfo: userInfo),
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

final UrlManager urls = UrlManager();

Future<void> getSuperInfoForLeave(
    Token token, String sUserName, UserInfo info) async {
  dynamic url = null;
  print(' current id is :${info.result.employeeId}');
  // if (info.result.employeeId == '1_0') {
  //   url = await Uri.parse('${urls.token_url}/api/Leave/LeaveList/admin');
  // } else {
  //   print("the user: ${info.result.employeeId}");

  // }

  url = await Uri.parse(
      '${urls.token_url}/api/Leave/LeaveListSupervisor/${info.result.employeeId}');

  try {
    final headers2 = {
      'Authorization': '${token.token_type} ${token.access_token}',
    };
    final response = await http.get(
      url,
      headers: headers2,
    );
    print(response.statusCode);
    // print(response.body.length);
    if (response.statusCode == 200) {
      print("going");
      // print(response.body);
      final leaveData = await jsonDecode(response.body);
      if (leaveData != null) {
        // print(leaveData);

        LeaveInfo leaveInfo = await LeaveInfo.fromJson(leaveData);
        // print(leaveInfo);
        super_atten = leaveInfo.result;
        if ((super_atten.length == 0) & (response.statusCode == 200)) {
          isSuperVisor = false;
        } else if ((super_atten.length != 0) & (response.statusCode == 200)) {
          isSuperVisor = true;
        }
        print('leve super : ${super_atten.length}');
      } else {
        print('JSON data is null');
      }
    } else {}
  } catch (e) {
    Fluttertoast.showToast(msg: 'Server Problem');
  }
}

Future<void> getAdminInfoForLeave(
    Token token, String sUserName, UserInfo info) async {
  dynamic url = null;
  print("the current user in admin : ${sUserName}");
  if (userInfo.result.isAdmin == "True") {
    url = await Uri.parse('${urls.token_url}/api/Leave/LeaveList/admin');
  } else {
    url = await Uri.parse('${urls.token_url}/api/Leave/LeaveList/${sUserName}');
  }

  try {
    final headers2 = {
      'Authorization': '${token.token_type} ${token.access_token}',
    };
    final response = await http.get(
      url,
      headers: headers2,
    );
    print(response.statusCode);
    // print(response.body.length);
    if (response.statusCode == 200) {
      print("going");
      // print(response.body);
      final leaveData = await jsonDecode(response.body);
      if (leaveData != null) {
        // print(leaveData);

        LeaveInfo leaveInfo = await LeaveInfo.fromJson(leaveData);
        // print(leaveInfo);
        admin_atten = leaveInfo.result;
        if ((super_atten.length == 0) & (response.statusCode == 200)) {
          isSuperVisor = false;
        } else if ((super_atten.length != 0) & (response.statusCode == 200)) {
          isSuperVisor = true;
        }
        print('leve amdin : ${admin_atten.length}');
      } else {
        print('JSON data is null');
      }
    } else {}
  } catch (e) {
    Fluttertoast.showToast(msg: 'error: ${e.toString()}');
  }
}
