import 'package:flutter/material.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendancedashboard.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/leavedashboard.dart';
import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';

final TextEditingController _remarks = TextEditingController();
int page_index = 1;
final ColorPicker colorPicker = ColorPicker();

class TestProfile extends StatelessWidget {
  const TestProfile(
      {super.key,
      required this.info,
      required this.userName,
      required this.token});
  final UserInfo info;
  final String userName;
  final Token token;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    // TODO: implement build
    return MaterialApp(
      home: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            return false;
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
                              HomeScreen(token: token, userName: userName)));
                },
              ),
              backgroundColor: Color(colorPicker.appbarBackgroudncolor),
              elevation: 0,
              title: Text(
                "Profile",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: colorPicker.footerText,
                ),
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
                              userName: userName,
                              token: token,
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
                        fontSize: 10.0,
                        color: colorPicker.footerText,
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: page_index == 1
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TestProfile(
                                    info: userInfo,
                                    userName: userName,
                                    token: token,
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
                                mToken: token,
                                mUserName: userName,
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
                                mToken: token,
                                mUserName: userName,
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
            body: InteractiveViewer(child: TestBody(info, userName, token)),
          ),
        ),
      ),
    );
  }
}

class TestBody extends StatefulWidget {
  const TestBody(this.cUserInfo, this.cUserName, this.cToken);

  final UserInfo cUserInfo;
  final String cUserName;
  final Token cToken;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TestBody(cUserInfo, cUserName, cToken);
  }
}

class _TestBody extends State<TestBody> {
  final UserInfo dUserInfo;
  final String dUserName;
  final Token dToken;
  UrlManager urls = UrlManager();

  _TestBody(this.dUserInfo, this.dUserName, this.dToken);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // this container is for profile image
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: CircleAvatar(
              radius: 70.0,
              // backgroundImage: NetworkImage(
              //     "${urls.token_url}${dUserInfo.result.photoName}"),
              backgroundImage: AssetImage('images/assets/profile.png'),
              // child: Image.asset('images/assets/profile.png'),
            ),
          ),
          // this container is for profile info
          Container(
            child: DataTable(
              columnSpacing: 10.0,
              columns: const <DataColumn>[
                DataColumn(
                  label: Expanded(
                    child: Text(''),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(''),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(''),
                  ),
                ),
              ],
              rows: <DataRow>[
                DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Image.asset(
                        'images/assets/name.png',
                        width: 20.0,
                      ),
                    ),
                    DataCell(
                      Text(
                        'Name',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          dUserInfo.result.fullName,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Image.asset(
                        'images/assets/id.png',
                        width: 20.0,
                      ),
                    ),
                    DataCell(
                      Text(
                        'User Id',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          dUserInfo.result.logId,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Image.asset(
                        'images/assets/designation.png',
                        width: 20.0,
                      ),
                    ),
                    DataCell(
                      Text(
                        'Designation',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          dUserInfo.result.designationName,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Image.asset(
                        'images/assets/section.png',
                        width: 20.0,
                      ),
                    ),
                    DataCell(
                      Text(
                        'Section',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          dUserInfo.result.sectionName,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Image.asset(
                        'images/assets/project.png',
                        width: 20.0,
                      ),
                    ),
                    DataCell(
                      Text(
                        'Project',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          dUserInfo.result.projectName,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Image.asset(
                        'images/assets/department.png',
                        width: 20.0,
                      ),
                    ),
                    DataCell(
                      Text(
                        'Department',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          dUserInfo.result.departmentName,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Image.asset(
                        'images/assets/calender.png',
                        width: 20.0,
                      ),
                    ),
                    DataCell(
                      Text(
                        'DOJ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          dUserInfo.result.joinDate,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
