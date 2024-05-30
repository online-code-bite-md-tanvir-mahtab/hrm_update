import 'dart:convert';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendance.dart';
import 'package:hrm_attendance_application_test/screen/attendancedashboard.dart';
import 'package:hrm_attendance_application_test/screen/attendancedetail.dart';
import 'package:hrm_attendance_application_test/screen/genarateScreen1.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/leavedashboard.dart';
import 'package:hrm_attendance_application_test/screen/testProfile.dart';
import 'package:hrm_attendance_application_test/util/attendaceinfo.dart';
import 'package:hrm_attendance_application_test/util/attendanceitem.dart';
import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Flutter code sample for [AlertDialog].

UrlManager urls = UrlManager();
int _currentIndex = 0;
dynamic attendance_msg = '';
final ColorPicker colorPicker = ColorPicker();
final UrlManager url_manager = UrlManager();

class AttendanceAdminByUser extends StatelessWidget {
  AttendanceAdminByUser(
      {super.key,
      required this.userName,
      required this.token,
      required this.userInfo});
  final String userName;
  final Token token;
  final UserInfo userInfo;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final List<Widget> _screens = [
      Attendance(token, userInfo, userName),
      HomeScreen(token: token, userName: userName),
      SelectDateRange(
        zToken: token,
        zUserName: userName,
        zReportType: 'Attendance',
        dInof: userInfo,
      ),
      AttendanceDetail(
        sToken: token,
        sUserName: userName,
        sUserInfo: userInfo,
      ),
    ];
    int backButtonPressCount = 0;
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
                      builder: (context) => AttendanceDashboard(
                        mToken: token,
                        mUserName: userName,
                        mUserInfo: userInfo,
                      ),
                    ),
                  );
                },
              ),
              title: Text(
                'Admin Attendance Info',
                style: TextStyle(color: colorPicker.footerText),
              ),
              backgroundColor: Color(colorPicker.appbarBackgroudncolor),
              elevation: 0,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
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
                          fontSize: 10.0, color: colorPicker.footerText),
                    )
                  ],
                ),
              ],
            ),
            body: Attendance(token, userInfo, userName),
          ),
        ),
      ),
    );
  }
}

TextEditingController _remarks = TextEditingController();

// BottomButton(token, userName, userInfo),
class Attendance extends StatefulWidget {
  Attendance(this.mToken, this.mUserInfo, this.mUserName);
  final Token mToken;
  final UserInfo mUserInfo;
  final String mUserName;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AttendanceBody(mToken, mUserInfo, mUserName);
  }
}

class _AttendanceBody extends State<Attendance> {
  Token vToken;
  String vUserName;
  UserInfo vUserInfo;
  _AttendanceBody(this.vToken, this.vUserInfo, this.vUserName);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // DialogExample(
          //   mtoken: vToken,
          //   mUserName: vUserName,
          // ),
          BodyData(
            userName: vUserName,
            sToken: vToken,
          ),
        ],
      ),
    );
  }
}

class BodyData extends StatefulWidget {
  const BodyData({super.key, required this.userName, required this.sToken});
  final String userName;
  final Token sToken;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BodyData(userName, sToken);
  }
}

List<AttendanceItem> atten = [];
TextEditingController attendance_from_date = TextEditingController();
TextEditingController attendance_to_date = TextEditingController();

final TextEditingController searchController = TextEditingController();
bool isDone = false;

class _BodyData extends State<BodyData> {
  _BodyData(this.userName, this.mToken);
  final String userName;
  final Token mToken;
  List<AttendanceItem> filteredData = [];
  List<String> sugests = [];
  @override
  void initState() {
    // TODO: implement initState
    getAttendanceInfo(userName, mToken, context).then((value) {
      setState(() {
        DateTime now = DateTime.now();
        DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
        String formattedDateFrom =
            DateFormat('yyyy-MM-dd').format(firstDateOfMonth);
        String formattedDateTo = DateFormat('yyyy-MM-dd').format(now);
        attendance_from_date.text = formattedDateFrom.toString();
        attendance_to_date.text = formattedDateTo.toString();
        print("attendance data curent month :${atten.length}");
        filteredData = atten.where((element) {
          return element.empName.isNotEmpty && element.code.isNotEmpty;
        }).toList();
        for (var d in filteredData) {
          dynamic value = '${d.empName}:${d.code}';
          if (!sugests.contains(value)) {
            sugests.add(value);
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    attendance_from_date.clear();
    attendance_to_date.clear();
    searchController.clear();
    super.dispose();
  }

  List<AttendanceItem> filterAndSortByDate(String sDate, String eDate) {
    try {
      DateTime s_DateTime = DateTime.parse(sDate);
      DateTime e_DateTime = DateTime.parse(eDate);
      String formateStartDate = DateFormat('dd/MM/yyyy').format(s_DateTime);
      String formateEndDate = DateFormat('dd/MM/yyyy').format(e_DateTime);
      // Define the date format
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

      // Define start and end dates
      DateTime startDate = dateFormat.parse(formateStartDate.toString());
      DateTime endDate = dateFormat.parse(formateEndDate.toString());

      setState(() {
        filteredData.clear();

        // filteredData = data;
      });
      getAttendanceInfoAnotherSEarch(
              userName, mToken, context, s_DateTime, e_DateTime)
          .then((value) {
        setState(() {
          if (searchController.toString().contains(':')) {
            print("yes");
            searchController.text =
                searchController.text.toString().split(":").first;
          } else {
            print('no');
          }
          filteredData = atten;
          filteredData = searchController.text.isEmpty
              ? filteredData
              : filteredData
                  .where((element) =>
                      element.code
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()) ||
                      element.empName
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()))
                  .toList();
        });
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalide Date Formate");
    }

    print(filteredData);

    // Print the filtered data
    return filteredData;
  }

  void _onSearchChanged(String text) {
    // empCode:
    setState(() {
      filteredData = text.isEmpty
          ? atten
          : atten
              .where((element) =>
                  element.code.toLowerCase().contains(text.toLowerCase()))
              .toList();
    });
  }

  bool isData() {
    // Simulate an API call or data loading process
    Future.delayed(Duration(seconds: 30), () {
      if (filteredData.isEmpty) {
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
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LiquidPullToRefresh(
        onRefresh: () async {
          getAttendanceInfo(userName, mToken, context).then((value) {
            setState(() {
              print("attendance data curent month :${atten.length}");
              filteredData = atten;
            });
          });
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Card(
                  elevation: 6,
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 10.0, bottom: 20.0),
                    child: Column(
                      children: [
                        const Text(
                          "From",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 254.0,
                          height: 40.0,
                          child: TextField(
                            readOnly: true,
                            controller: attendance_from_date,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(DateTime.now().year),
                                lastDate: DateTime(2050),
                              );
                              if (pickedDate != null) {
                                // print(pickedDate);
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                attendance_from_date.text =
                                    formattedDate.toString();
                              }
                            },
                            // controller: _controller2,
                            decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_month),
                                filled: true,
                                fillColor: Color.fromARGB(217, 217, 217, 217),
                                border: OutlineInputBorder(),
                                hintText: "Enter the Starting date: ",
                                contentPadding: EdgeInsets.only(
                                    top: 1.0, bottom: 1.0, left: 10.0)),
                          ),
                        ),
                        const Text(
                          "To",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 254.0,
                          height: 40.0,
                          child: TextField(
                            readOnly: true,
                            controller: attendance_to_date,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(DateTime.now().year),
                                lastDate: DateTime(2050),
                              );
                              if (pickedDate != null) {
                                // print(pickedDate);
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                attendance_to_date.text =
                                    formattedDate.toString();
                              }
                            },
                            // controller: _controller2,
                            decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_month),
                                filled: true,
                                fillColor: Color.fromARGB(217, 217, 217, 217),
                                border: OutlineInputBorder(),
                                hintText: "Enter the End date: ",
                                contentPadding: EdgeInsets.only(
                                    top: 1.0, bottom: 1.0, left: 10.0)),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        SizedBox(
                          width: 254.0,
                          height: 60.0,
                          child: EasyAutocomplete(
                            controller: searchController,
                            suggestions: sugests,
                            onSubmitted: (value) async {
                              setState(() {
                                searchController.text = value;
                              });
                            },
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color.fromARGB(217, 217, 217, 217),
                              border: OutlineInputBorder(),
                              hintText: "Enter the employee code: ",
                              contentPadding: EdgeInsets.only(
                                  top: 1.0, bottom: 1.0, left: 10.0),
                            ),
                            onChanged: (value) => null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 1.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (attendance_from_date.text.isEmpty) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text("The From date is empty"),
                        ),
                      );
                  } else if (attendance_to_date.text.isEmpty) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('The To date is empty'),
                        ),
                      );
                  } else {
                    setState(() {
                      filteredData = filterAndSortByDate(
                          attendance_from_date.text, attendance_to_date.text);
                    });
                  }
                },
                child: Icon(Icons.search),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0F0F0F),
                    minimumSize: Size(40.0, 30.0)),
              ),
              filteredData.isEmpty
                  ? isData()
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('images/assets/warning.png'),
                              Text(
                                "Your Monthly Attendance hasn't been migrated please wait",
                                style: TextStyle(color: Colors.amber),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.black,
                            size: 100,
                          ),
                        )
                  : InteractiveViewer(
                      // fit: BoxFit.fill,
                      constrained: true,
                      child: FittedBox(
                        child: Container(
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 253, 253),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Emp Id',
                                      style: TextStyle(),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Emp Name',
                                      style: TextStyle(),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Date',
                                      style: TextStyle(),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'In',
                                      style: TextStyle(),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Out',
                                      style: TextStyle(),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Late',
                                      style: TextStyle(),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Status',
                                      style: TextStyle(),
                                    ),
                                  ),
                                ),
                              ],
                              rows: [
                                for (int i = 0; i < filteredData.length; i++)
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(filteredData[i].code)),
                                      DataCell(Text(filteredData[i].empName)),
                                      DataCell(Text(filteredData[i].dailyDate)),
                                      DataCell(
                                        Text(convertTo24HourFormat(
                                            filteredData[i].inTime)),
                                      ),
                                      DataCell(Text(convertTo24HourFormat(
                                          filteredData[i].outTime))),
                                      DataCell(Text(filteredData[i]
                                          .lateInMin
                                          .toString())),
                                      DataCell(
                                          Text(filteredData[i].attnStatus)),
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
      ),
    );
  }
}

class BottomButton extends StatefulWidget {
  BottomButton(this.yToken, this.yUserName, this.yUserInfo);
  final Token yToken;
  final String yUserName;
  final UserInfo yUserInfo;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BottomButton(yToken, yUserName, yUserInfo);
  }
}

class _BottomButton extends State<BottomButton> {
  var _currentIndex = 0;
  Token zToken;
  String zUserName;
  UserInfo zUserInfo;
  _BottomButton(this.zToken, this.zUserName, this.zUserInfo);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AnimatedBottomNavigationBar(
          icons: [
            Icons.lock_clock,
            Icons.door_back_door,
            Icons.report,
            Icons.location_history,
          ],
          activeIndex: _currentIndex,
          gapLocation: GapLocation.none,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (_currentIndex == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertDialogExampleApp(
                      userName: zUserName, token: zToken, userInfo: zUserInfo),
                ),
              );
            }
            if (_currentIndex == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceDashboard(
                      mToken: zToken,
                      mUserName: zUserName,
                      mUserInfo: zUserInfo),
                ),
              );
            } else if (_currentIndex == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectDateRange(
                      zUserName: zUserName,
                      zToken: zToken,
                      zReportType: 'Attendance',
                      dInof: zUserInfo),
                ),
              );
            } else if (_currentIndex == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceDetail(
                      sToken: zToken,
                      sUserName: zUserName,
                      sUserInfo: zUserInfo),
                ),
              );
            }
          },
          activeColor: Colors.black,
          inactiveColor: Colors.grey,
          backgroundColor: Colors.white, // Set the background color
        ),
      ],
    );
  }
}

String convertTo24HourFormat(String time) {
  final inputFormat = DateFormat("hh:mm a");
  final outputFormat = DateFormat("HH:mm");

  final dateTime = inputFormat.parse(time);
  final formattedTime = outputFormat.format(dateTime);

  return formattedTime;
}

String formatTime(String time) {
  if (time.length != 4) {
    return '';
  }
  final hours = time.substring(0, 2);
  final minutes = time.substring(2, 4);
  return '$hours:$minutes';
}

Future<void> getAttendanceInfo(
    String userName, Token token, BuildContext context) async {
  // geting the current day
  DateTime today = DateTime.now();

  String current_month = DateFormat('yyyyMM').format(today);
  print(userName);
  // now i am going to parse the uri
  // http://192.168.15.205/api/Attendance/AttendanceByUser
  final url = Uri.parse(
    "${urls.token_url}/api/Attendance/AttendanceByUser/admin/${current_month}01/${current_month}30",
  );

  final header = {'Authorization': '${token.token_type} ${token.access_token}'};

  // use the try catch block to hendle anykind error
  try {
    final response = await http.get(url, headers: header);
    // print(response.body);
    if (response.statusCode == 200) {
      final attendanceData = jsonDecode(response.body);
      AttendanceInfo attendanceInfo = AttendanceInfo.fromJson(attendanceData);
      atten = attendanceInfo.result;
      print(atten.length);
    } else {
      print("something is worng");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "The server error");
  }
}

Future<void> getAttendanceInfoAnotherSEarch(String userName, Token token,
    BuildContext context, DateTime sDate, DateTime eDate) async {
  // now i am going to parse the uri
  // http://192.168.15.205/api/Attendance/AttendanceByUser
  print('DAte is selected :${sDate.toString()}');
  String start_date = DateFormat('yyyyMMdd').format(sDate);
  String end_date = DateFormat('yyyyMMdd').format(eDate);
  final url = Uri.parse(
    "${urls.token_url}/api/Attendance/AttendanceByUser/admin/${start_date}/${end_date}",
  );

  final header = {'Authorization': '${token.token_type} ${token.access_token}'};

  // use the try catch block to hendle anykind error
  try {
    final response = await http.get(url, headers: header);
    // print(response.body);
    if (response.statusCode == 200) {
      final attendanceData = jsonDecode(response.body);
      AttendanceInfo attendanceInfo = AttendanceInfo.fromJson(attendanceData);
      atten = attendanceInfo.result;
      print(atten.length);
    } else {
      print("something is worng");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "The server error");
  }
}
