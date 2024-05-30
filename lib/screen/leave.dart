import 'dart:convert';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendancedashboard.dart';
import 'package:hrm_attendance_application_test/screen/genarateScreen1.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/leavedashboard.dart';
import 'package:hrm_attendance_application_test/screen/pdfpreview.dart';
import 'package:hrm_attendance_application_test/screen/testProfile.dart';
import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/leaveinfo.dart';
import 'package:hrm_attendance_application_test/util/leaveitem.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/token.dart';
import 'leavebalance.dart';
import 'package:http/http.dart' as http;

final TextEditingController searchController = TextEditingController();
List<String> sugests = [];
final ColorPicker colorPicker = ColorPicker();

class LeaveDialogExampleapp extends StatelessWidget {
  const LeaveDialogExampleapp({
    super.key,
    required this.mToken,
    required this.mUserName,
    required this.mUserInof,
  });
  final Token mToken;
  final String mUserName;
  final UserInfo mUserInof;
  @override
  Widget build(BuildContext context) {
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
            child: LeaveUi(mToken, mUserName, mUserInof)),
      ),
    );
  }
}

class LeaveUi extends StatefulWidget {
  LeaveUi(this.stoken, this.sUserName, this.sInfo);
  final Token stoken;
  final String sUserName;
  final UserInfo sInfo;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LeaveUi(stoken, sUserName, sInfo);
  }
}

List<LeaveItem> atten = [];
bool isClicked = false;
List<LeaveItem> filteredData = [];
bool isDone = false;

class _LeaveUi extends State<LeaveUi> {
  _LeaveUi(this.mtoken, this.dusername, this.dInfo);
  final Token mtoken;
  final String dusername;
  final UserInfo dInfo;

  @override
  void initState() {
    // TODO: implement initState
    getLeaveInfo(mtoken, dusername, dInfo).then((value) {
      setState(() {
        DateTime now = DateTime.now();
        DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
        String formattedDateFrom =
            DateFormat('yyyy-MM-dd').format(firstDateOfMonth);
        String formattedDateTo = DateFormat('yyyy-MM-dd').format(now);
        leave_from_date.text = formattedDateFrom.toString();
        leave_to_date.text = formattedDateTo.toString();
        filteredData = atten;
        for (var d in filteredData) {
          dynamic value = '${d.empName}:${d.empCode}';
          sugests.add(value);
        }
      });
    });
    super.initState();
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
  void dispose() {
    leave_from_date.clear();
    leave_to_date.clear();
    searchController.clear();
    // TODO: implement dispose
    super.dispose();
  }

  List<LeaveItem> filterAndSortByDate(
      List<LeaveItem> data, String sDate, String eDate) {
    try {
      DateTime s_DateTime = DateTime.parse(sDate);
      DateTime e_DateTime = DateTime.parse(eDate);
      String formateStartDate = DateFormat('dd/MM/yyyy').format(s_DateTime);
      String formateEndDate = DateFormat('dd/MM/yyyy').format(e_DateTime);
      // Define the date format
      print(formateEndDate);
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

      // Define start and end dates
      DateTime startDate = dateFormat.parse(formateStartDate.toString());
      DateTime endDate = dateFormat.parse(formateEndDate.toString());
      setState(() {
        filteredData.clear();
      });
      getLeaveInfoSearchByDate(
              mtoken, dusername, userInfo, s_DateTime, e_DateTime)
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
                      element.employeeId
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()) ||
                      element.empName
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()) ||
                      element.empCode
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()))
                  .toList();
        });
      });
      print(filteredData);
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalide Date Formate");
    }

    // Print the filtered data
    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: colorPicker.footerText,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LeaveDashboard(
                    mToken: mtoken, mUserName: dusername, mUserInfo: dInfo),
              ),
            );
          },
        ),
        elevation: 0,
        backgroundColor: Color(colorPicker.appbarBackgroudncolor),
        title: Text(
          'Leave Info',
          style: TextStyle(color: colorPicker.footerText),
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
                style: TextStyle(fontSize: 10.0, color: colorPicker.footerText),
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
                style: TextStyle(fontSize: 10.0, color: colorPicker.footerText),
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
                style: TextStyle(fontSize: 10.0, color: colorPicker.footerText),
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
      body: LiquidPullToRefresh(
        child: getTable(dInfo, mtoken, context, dusername),
        onRefresh: () async {
          getLeaveInfo(mtoken, dusername, userInfo).then((value) {
            setState(() {
              filteredData = atten;
            });
          });
        },
      ),
    );
  }

  TextEditingController leave_from_date = TextEditingController();
  TextEditingController leave_to_date = TextEditingController();

  Widget getTable(
      UserInfo dInfo, Token mtoken, BuildContext context, String userName) {
    var screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          colorPicker.testProfielCard(userInfo),
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
                        controller: leave_from_date,
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
                            leave_from_date.text = formattedDate.toString();
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
                        controller: leave_to_date,
                        readOnly: true,
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
                            leave_to_date.text = formattedDate.toString();
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
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          // SizedBox(
          //   width: 254.0,
          //   height: 60.0,
          //   child: EasyAutocomplete(
          //     controller: searchController,
          //     suggestions: sugests,
          //     onChanged: (value) => null,
          //     onSubmitted: (value) async {
          //       setState(() {
          //         searchController.text = value;
          //       });
          //     },
          //     decoration: const InputDecoration(
          //       filled: true,
          //       fillColor: Color.fromARGB(217, 217, 217, 217),
          //       border: OutlineInputBorder(),
          //       hintText: "Enter the employee code or name: ",
          //       contentPadding:
          //           EdgeInsets.only(top: 1.0, bottom: 0.0, left: 10.0),
          //     ),
          //     // onChanged: _onSearchChanged,
          //   ),
          // ),
          ElevatedButton(
            onPressed: () async {
              if (leave_from_date.text.isEmpty) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text("The From date is empty"),
                    ),
                  );
              } else if (leave_to_date.text.isEmpty) {
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
                      atten, leave_from_date.text, leave_to_date.text);
                });
              }
            },
            child: Icon(Icons.search),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0F0F0F),
                minimumSize: Size(40.0, 30.0)),
          ),
          SizedBox(
            height: 20.0,
          ),
          filteredData.isEmpty
              ? isData()
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('images/assets/warning.png'),
                          Text(
                            "You have no leave requests",
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
                  maxScale: 3.0,
                  constrained: true,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Container(
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 253, 253),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Start Date',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Employee Name',
                                style: TextStyle(),
                              ),
                            ),
                          ),
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
                                'Leave Type',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Day Type',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Total Day',
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
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Report',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          for (int i = 0; i < filteredData.length; i++)
                            DataRow(
                              cells: <DataCell>[
                                DataCell(Text(filteredData[i].fromDate)),
                                DataCell(Text(filteredData[i].empName)),
                                DataCell(Text(filteredData[i].empCode)),
                                DataCell(Text(filteredData[i].leaveType_E)),
                                DataCell(Text(filteredData[i].dayType)),
                                DataCell(Text("${filteredData[i].totalLeave}")),
                                DataCell(Text(filteredData[i].approval)),
                                DataCell(
                                  Icon(Icons.download),
                                  onTap: () async {
                                    String id = (filteredData[i].id).toString();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewerScreen(
                                          pdfId: id,
                                          token: mtoken,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 60.0,
          ),
        ],
      ),
    );
  }
}

Future<void> actionOfTheAdminForApproval(
    Token token,
    bool isApproved,
    bool isRejected,
    String reId,
    UserInfo sInfo,
    String userName,
    BuildContext context) async {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
  final url = Uri.parse('${urls.token_url}/api/Leave/LeaveApprove');
  print(userName);
  print(reId);
  print(sInfo.result.employeeId);
  try {
    final headers2 = {
      'Authorization': '${token.token_type} ${token.access_token}',
    };
    final bod = {
      "ApprovedBy": sInfo.result.employeeId,
      "Id": "${reId}",
      "LastUpdateAt": "${formattedDate}",
      "LastUpdateBy": "${userName}",
      "IsApprove": "${isApproved}",
      "IsReject": "${isRejected}",
      "RejectedBy": ""
    };
    final response = await http.post(url, headers: headers2, body: bod);
    print(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text("The Application made change")));
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text("Something went wrong")));
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text("Server Problem")));
  }
}

void openPdfLink(String pdfUrl) async {
  if (await canLaunch(pdfUrl)) {
    await launch(pdfUrl);
  } else {
    throw 'Could not launch $pdfUrl';
  }
}

final UrlManager urls = UrlManager();
Future<void> getLeaveInfo(Token token, String sUserName, UserInfo info) async {
  dynamic url = null;
  if (info.result.employeeId == '1_0') {
    url = Uri.parse('${urls.token_url}/api/Leave/LeaveList/admin');
  } else {
    url = Uri.parse(
        '${urls.token_url}/api/Leave/LeaveList/${info.result.employeeId}');
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
    print(response.body.length);
    if (response.statusCode == 200) {
      print("going");
      final leaveData = jsonDecode(response.body);
      if (leaveData != null) {
        print(leaveData);
        LeaveInfo leaveInfo = LeaveInfo.fromJson(leaveData);
        print(leaveInfo);
        atten = leaveInfo.result;
        print('leve : ${atten.length}');
      } else {
        print('JSON data is null');
      }
    } else {
      print('something is wrong');
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Something went wrong');
  }
}

Future<void> getLeaveInfoSearchByDate(Token token, String sUserName,
    UserInfo info, DateTime sDate, DateTime eDate) async {
  String start_date = DateFormat('yyyyMMdd').format(sDate);
  String end_date = DateFormat('yyyyMMdd').format(eDate);
  dynamic url = null;
  if (info.result.employeeId == '1_0') {
    print("hello world");
    url = Uri.parse(
        '${urls.token_url}/api/Leave/LeaveListByDate/admin/${start_date}/${end_date}');
  } else {
    url = Uri.parse(
        '${urls.token_url}/api/Leave/LeaveListByDate/${info.result.employeeId}/${start_date}/${end_date}');
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
    print(response.body.length);
    if (response.statusCode == 200) {
      print("going");
      final leaveData = jsonDecode(response.body);
      if (leaveData != null) {
        print(leaveData);
        LeaveInfo leaveInfo = LeaveInfo.fromJson(leaveData);
        print(leaveInfo);
        atten = leaveInfo.result;
        print('leve : ${atten.length}');
      } else {
        print('JSON data is null');
      }
    } else {
      print('something is wrong');
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Something Went wrong');
  }
}

class ActionButton extends StatelessWidget {
  final String sUserName;
  final Token sToken;
  final UserInfo sInfo;
  ActionButton(this.sUserName, this.sToken, this.sInfo);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.only(left: 60.0, right: 60.0, top: 60.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50.0,
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectDateRange(
                              zUserName: sUserName,
                              zToken: sToken,
                              zReportType: 'Leave',
                              dInof: sInfo,
                            )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00ff29),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.report,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text(
                      "Report",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 1.0,
          ),
        ],
      ),
    );
  }
}

class BottomButtonLeave extends StatefulWidget {
  BottomButtonLeave(this.yToken, this.yUserName, this.yUserInfo);
  final Token yToken;
  final String yUserName;
  final UserInfo yUserInfo;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BottomButton(yToken, yUserName, yUserInfo);
  }
}

class _BottomButton extends State<BottomButtonLeave> {
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
            Icons.outbox,
            Icons.home,
            Icons.report,
            Icons.flight,
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
                  builder: (context) => LeaveDialogExampleapp(
                      mUserName: zUserName,
                      mToken: zToken,
                      mUserInof: zUserInfo),
                ),
              );
            }
            if (_currentIndex == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(token: zToken, userName: zUserName),
                ),
              );
            } else if (_currentIndex == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectDateRange(
                      zUserName: zUserName,
                      zToken: zToken,
                      zReportType: 'Leave',
                      dInof: zUserInfo),
                ),
              );
            } else if (_currentIndex == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaveBalance(
                      mToken: zToken,
                      dUserName: zUserName,
                      dUserInfo: zUserInfo),
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

// Widget getTable(
//     UserInfo dInfo, Token mtoken, BuildContext context, String userName) {
//   return atten.isEmpty
//       ? Center(
//           child: LoadingAnimationWidget.staggeredDotsWave(
//             color: Colors.black,
//             size: 100,
//           ),
//         )
//       : SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               const SizedBox(
//                 height: 40.0,
//               ),
//               const SizedBox(
//                 height: 20.0,
//               ),
//               FittedBox(
//                 child: Container(
//                   margin: EdgeInsets.only(left: 10.0, right: 10.0),
//                   decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 255, 253, 253),
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(10.0),
//                     ),
//                   ),
//                   child: DataTable(
//                     columns: const <DataColumn>[
//                       DataColumn(
//                         label: Expanded(
//                           child: Text(
//                             'Start Date',
//                             style: TextStyle(),
//                           ),
//                         ),
//                       ),
//                       DataColumn(
//                         label: Expanded(
//                           child: Text(
//                             'Leave Type',
//                             style: TextStyle(),
//                           ),
//                         ),
//                       ),
//                       DataColumn(
//                         label: Expanded(
//                           child: Text(
//                             'Day Type',
//                             style: TextStyle(),
//                           ),
//                         ),
//                       ),
//                       DataColumn(
//                         label: Expanded(
//                           child: Text(
//                             'Total Day',
//                             style: TextStyle(),
//                           ),
//                         ),
//                       ),
//                       DataColumn(
//                         label: Expanded(
//                           child: Text(
//                             'Status',
//                             style: TextStyle(),
//                           ),
//                         ),
//                       ),
//                       DataColumn(
//                         label: Expanded(
//                           child: Text(
//                             'Report',
//                             style: TextStyle(),
//                           ),
//                         ),
//                       ),
//                     ],
//                     rows: dInfo.result.employeeId == '1_0'
//                         ? [
//                             for (int i = 0; i < atten.length; i++)
//                               DataRow(
//                                 cells: <DataCell>[
//                                   DataCell(Text(atten[i].fromDate)),
//                                   DataCell(Text(atten[i].leaveType_E)),
//                                   DataCell(Text(atten[i].dayType)),
//                                   DataCell(Text("${atten[i].totalLeave}")),
//                                   DataCell(Text(atten[i].approval)),
//                                   DataCell(
//                                     Row(
//                                       children: [
//                                         IconButton(
//                                           onPressed: () async {
//                                             String id =
//                                                 (atten[i].id).toString();
//                                             actionOfTheAdminForApproval(
//                                                 mtoken,
//                                                 true,
//                                                 false,
//                                                 id,
//                                                 dInfo,
//                                                 userName,
//                                                 context);
//                                           },
//                                           icon: Icon(Icons.check),
//                                         ),
//                                         IconButton(
//                                           onPressed: () {
//                                             String id =
//                                                 (atten[i].id).toString();
//                                             actionOfTheAdminForApproval(
//                                                 mtoken,
//                                                 false,
//                                                 true,
//                                                 id,
//                                                 dInfo,
//                                                 userName,
//                                                 context);
//                                           },
//                                           icon: Icon(Icons.close),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                           ]
//                         : isClicked
//                             ? [
//                                 for (int j = 0; j < super_atten.length; j++)
//                                   DataRow(
//                                     cells: <DataCell>[
//                                       DataCell(Text(atten[j].fromDate)),
//                                       DataCell(Text(atten[j].leaveType_E)),
//                                       DataCell(Text(atten[j].dayType)),
//                                       DataCell(Text("${atten[j].totalLeave}")),
//                                       DataCell(Text(atten[j].approval)),
//                                       DataCell(
//                                         Icon(Icons.download),
//                                         onTap: () async {
//                                           String id = (atten[j].id).toString();
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   PdfViewerScreen(
//                                                 pdfId: id,
//                                                 token: mtoken,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                               ]
//                             : [
//                                 for (int i = 0; i < atten.length; i++)
//                                   DataRow(
//                                     cells: <DataCell>[
//                                       DataCell(Text(atten[i].fromDate)),
//                                       DataCell(Text(atten[i].leaveType_E)),
//                                       DataCell(Text(atten[i].dayType)),
//                                       DataCell(Text("${atten[i].totalLeave}")),
//                                       DataCell(Text(atten[i].approval)),
//                                       DataCell(
//                                         Icon(Icons.download),
//                                         onTap: () async {
//                                           String id = (atten[i].id).toString();
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   PdfViewerScreen(
//                                                 pdfId: id,
//                                                 token: mtoken,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                               ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 60.0,
//               ),
//             ],
//           ),
//         );
// }
