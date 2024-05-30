import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendance.dart';
import 'package:hrm_attendance_application_test/screen/attendancebyadmin.dart';
import 'package:hrm_attendance_application_test/screen/attendancebysupervisor.dart';
import 'package:hrm_attendance_application_test/screen/attendancedetail.dart';
import 'package:hrm_attendance_application_test/screen/checkin.dart';
import 'package:hrm_attendance_application_test/screen/genarateScreen1.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/leavedashboard.dart';
import 'package:hrm_attendance_application_test/screen/testProfile.dart';
import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/token.dart';

final ColorPicker colorPicker = ColorPicker();

class AttendanceDashboard extends StatelessWidget {
  AttendanceDashboard(
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

int page_index = 2;

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
  @override
  void initState() {
    logId = dInfo.result.logId.replaceAll(' ', '');
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    print(userInfo.result.logId + "Admin");
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
                icon: Icon(Icons.arrow_back),
                color: colorPicker.footerText,
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
                'Attendance Dashboard',
                style: TextStyle(color: colorPicker.footerText),
              ),
            ),
            body: Container(
              margin: EdgeInsets.only(left: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible:
                        userInfo.result.isAdmin == "True" || logId != "Admin",
                    child: Expanded(
                      flex: 0,
                      child: Container(
                        margin: EdgeInsets.only(top: screenSize.height / 100),
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
                                            "images/assets/check-in.png"),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CheckIn(
                                                  userName: dusername,
                                                  token: mtoken,
                                                  userInfo: userInfo),
                                            ),
                                          );
                                        },
                                        iconSize: 50.0,
                                      ),
                                    ),
                                    Text(
                                      "Check In",
                                    ),
                                  ],
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
                                              "images/assets/attendance.png"),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AlertDialogExampleApp(
                                                        userName: dusername,
                                                        token: mtoken,
                                                        userInfo: dInfo),
                                              ),
                                            );
                                          },
                                          iconSize: 50.0,
                                        ),
                                      ),
                                      Text(
                                        "Attendance Details",
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
                                            "images/assets/report.png"),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SelectDateRange(
                                                      zUserName: dusername,
                                                      zToken: mtoken,
                                                      zReportType: 'Attendance',
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
                                            "images/assets/locationdetail.png"),
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AttendanceDetail(
                                                      sToken: mtoken,
                                                      sUserName: dusername,
                                                      sUserInfo: dInfo),
                                            ),
                                          );
                                        },
                                        iconSize: 50.0,
                                      ),
                                    ),
                                    Text(
                                      "Attendance Info",
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
                      margin: EdgeInsets.only(top: screenSize.height / 10),
                      child: Visibility(
                        visible:
                            dInfo.result.isAdmin == "True" || logId == 'Admin',
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
                                Visibility(
                                  visible: dInfo.result.isAdmin == "True" &&
                                      logId != 'Admin',
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
                                                    AttendanceSuperVisorByUser(
                                                        userName: dusername,
                                                        token: mtoken,
                                                        userInfo: dInfo),
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
                                  visible: dInfo.result.isAdmin == "True" ||
                                      logId == 'Admin',
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
                                                    AttendanceAdminByUser(
                                                        userName: dusername,
                                                        token: mtoken,
                                                        userInfo: dInfo),
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
                  )
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
                      onTap: page_index == 2
                          ? null
                          : () {
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
                      onTap: () {
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
                        fontSize: 10.0,
                        color: colorPicker.footerText,
                      ),
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
