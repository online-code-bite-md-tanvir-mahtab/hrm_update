import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendancedashboard.dart';
import 'package:hrm_attendance_application_test/screen/fillform.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/leavedashboard.dart';
import 'package:hrm_attendance_application_test/screen/testProfile.dart';
import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/leaveTypeInfo.dart';
import 'package:hrm_attendance_application_test/util/leavebalance.dart';
import 'package:hrm_attendance_application_test/util/leavebalanceItem.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/typeItem.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

List<LeaveBalanceItem> balances = [];
bool isDone = false;
final ColorPicker colorPicker = ColorPicker();
TextEditingController remarks = TextEditingController();

class LeaveBalance extends StatelessWidget {
  const LeaveBalance(
      {super.key,
      required this.mToken,
      required this.dUserName,
      required this.dUserInfo});
  final Token mToken;
  final String dUserName;
  final UserInfo dUserInfo;
  @override
  Widget build(BuildContext context) {
    int backButtonPressCount = 0;
    var screenSize = MediaQuery.of(context).size;
    return MaterialApp(
      home: WillPopScope(
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
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color(colorPicker.appbarBackgroudncolor),
                elevation: 0,
                title: Text(
                  'Leave Balance',
                  style: TextStyle(color: colorPicker.footerText),
                ),
                leading: IconButton(
                  color: colorPicker.footerText,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaveDashboard(
                          mToken: mToken,
                          mUserName: dUserName,
                          mUserInfo: dUserInfo,
                        ),
                      ),
                    );
                  },
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
                                userName: dUserName,
                                token: mToken,
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
                                info: dUserInfo,
                                userName: dUserName,
                                token: mToken,
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
                                  mToken: mToken,
                                  mUserName: dUserName,
                                  mUserInfo: dUserInfo),
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
                                  mToken: mToken,
                                  mUserName: dUserName,
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
              body: InteractiveViewer(
                  child: Leave(mToken, dUserName, dUserInfo))),
        ),
      ),
    );
  }
}

class Leave extends StatefulWidget {
  Leave(this.sToken, this.zUserName, this.zUserInfo);
  final Token sToken;
  final String zUserName;
  final UserInfo zUserInfo;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Leave(sToken, zUserName, zUserInfo);
  }
}

List<TypeItem> listTypes = [];
List<DropdownMenuItem<String>> dropdownItems = [];

String list_type = 'Sick Leave';
int index = 0;

class _Leave extends State<Leave> {
  _Leave(this.dToken, this.sUserName, this.sUserInfo);
  Token dToken;
  bool? isChecked = false;
  bool? isCheckedForpay = false;
  final String sUserName;
  final UserInfo sUserInfo;

  @override
  void dispose() {
    endDateSelected.clear();
    startDateSelected.clear();
    remarks.clear();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dropdownItems.clear();
    getLeaveBalanceInfo(dToken, sUserName, sUserInfo).then((value) {
      setState(() {});
    });

    getTypeLists(dToken, sUserName, sUserInfo).then((value) {
      setState(() {
        print(listTypes.length);
        for (int i = 0; i < listTypes.length; i++) {
          dropdownItems.add(DropdownMenuItem(
            child: Text(
              listTypes[i].leaveType_E,
            ),
            value: listTypes[i].leaveType_E,
          ));
        }
        print(listTypes[0].leaveType_E);
      });
    });
  }

  bool isData() {
    // Simulate an API call or data loading process
    Future.delayed(Duration(seconds: 30), () {
      if (balances.isEmpty) {
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
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Leave Balance",
            ),
            const SizedBox(
              height: 10.0,
            ),
            balances.isEmpty
                ? isData()
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('images/assets/warning.png'),
                            Text(
                              "Admin can\'t apply for leave",
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
                : FittedBox(
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
                                'Total Leave',
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
                                'Enjoyed',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Remaining',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          if (balances.length != 0)
                            for (int i = 0; i < balances.length; i++)
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(balances[i].total)),
                                  DataCell(Text(balances[i].leaveType)),
                                  DataCell(Text(balances[i].used)),
                                  DataCell(Text(balances[i].have)),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(
              height: 30.0,
            ),
            Text(
              "New Leave",
            ),
            SizedBox(
              height: 10.0,
            ),
            FittedBox(
              child: Container(
                padding: EdgeInsets.only(
                  left: 70.0,
                  right: 70.0,
                  top: 10.0,
                  bottom: 10.0,
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 231, 229, 229),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Leave Type: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: 254.0,
                      height: 40.0,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonFormField<String>(
                          items: dropdownItems,
                          onChanged: (String? newValue) {
                            // You can handle the selected value here.
                            print(newValue);
                            setState(() {
                              list_type = newValue.toString();
                            });
                          },
                          value:
                              list_type, // Set the default value, you can change it as per your need
                          decoration: InputDecoration(
                            border: InputBorder
                                .none, // Remove the border from the DropdownButton
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.0), // Add padding
                            // suffixIcon: Icon(Icons
                            //     .arrow_drop_down), // Add the icon to the right
                            suffixIconConstraints: BoxConstraints(
                                minWidth: 0,
                                minHeight:
                                    0), // Add this line to remove the default suffix icon
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    // ActionButton(),
                    const Text(
                      "Start Date",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: 254.0,
                      height: 40.0,
                      child: TextField(
                        controller: startDateSelected,
                        readOnly: true,
                        onTap: () async {
                          // now selecting the current date
                          DateTime currentDate = DateTime.now();
                          var cdate = currentDate.day.toInt();
                          DateTime firstDateOfCurrentMonth = DateTime(
                              currentDate.year, currentDate.month, cdate);
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: firstDateOfCurrentMonth,
                            lastDate: DateTime(2050),
                          );
                          if (pickedDate != null) {
                            // print(pickedDate);
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            startDateSelected.text = formattedDate.toString();
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
                      "End Date",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: 254.0,
                      height: 40.0,
                      child: TextField(
                        controller: endDateSelected,
                        readOnly: true,
                        onTap: () async {
                          // now selecting the current date
                          DateTime currentDate = DateTime.now();
                          var cdate = currentDate.day.toInt();
                          DateTime firstDateOfCurrentMonth = DateTime(
                              currentDate.year, currentDate.month, cdate);
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: firstDateOfCurrentMonth,
                            lastDate: DateTime(2050),
                          );
                          if (pickedDate != null) {
                            // Format the pickedDate to display only the date
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            endDateSelected.text = formattedDate;
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
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: 254.0,
                      height: 40.0,
                      child: TextField(
                        controller: remarks,
                        maxLines: null,
                        // controller: _controller2,
                        decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color.fromARGB(217, 217, 217, 217),
                            border: OutlineInputBorder(),
                            hintText: "Enter Your Remarks ",
                            contentPadding: EdgeInsets.only(
                                top: 1.0, bottom: 1.0, left: 10.0)),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200.0,
                          child: Container(
                            color: Color.fromARGB(255, 231, 229, 229),
                            // margin: EdgeInsets.only(left: 40.0),
                            child: Row(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Half Day",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Checkbox(
                                  activeColor: Colors.red,
                                  value: isChecked,
                                  onChanged: (newBool) {
                                    setState(() {
                                      isChecked = newBool;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200.0,
                          child: Container(
                            color: Color.fromARGB(255, 231, 229, 229),
                            // margin: EdgeInsets.only(left: 40.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Without pay",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Checkbox(
                                  activeColor: Colors.red,
                                  value: isCheckedForpay,
                                  onChanged: (newBool) {
                                    setState(() {
                                      isCheckedForpay = newBool;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print(list_type);
                      print(startDateSelected.text);
                      print(endDateSelected.text);
                      print(isChecked);
                      if (list_type.isEmpty) {
                        print('Leave Type is empty');
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text("Leave Type is empty"),
                            ),
                          );
                      } else if (startDateSelected.text.isEmpty) {
                        print('Start Date is empty');
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text("Start Date is empty"),
                            ),
                          );
                      } else if (endDateSelected.text.isEmpty) {
                        print('End date is empty');
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text("End date is empty"),
                            ),
                          );
                      } else {
                        Dialogs.bottomMaterialDialog(
                          msg:
                              'Are you sure? you want to apply new leave from: ${startDateSelected.text} to ${endDateSelected.text}',
                          title: 'Leave Resquest Save',
                          context: context,
                          actions: [
                            IconsOutlineButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Leave request is been canceld"),
                                    ),
                                  );
                              },
                              text: 'No',
                              iconData: Icons.cancel_outlined,
                              textStyle: TextStyle(color: Colors.grey),
                              iconColor: Colors.grey,
                            ),
                            IconsButton(
                              onPressed: () async {
                                try {
                                  Navigator.pop(context);
                                  DateTime startDateTime =
                                      DateTime.parse(startDateSelected.text);
                                  DateTime endDateTime =
                                      DateTime.parse(endDateSelected.text);
                                  String leave_type = list_type;
                                  String formattedsDate = startDateSelected.text
                                      .replaceAll('-', '');
                                  String formattedeDate =
                                      endDateSelected.text.replaceAll('-', '');
                                  bool isHalfDay =
                                      bool.parse(isChecked.toString());

                                  print('the date: ${formattedeDate}');
                                  print(formattedsDate);
                                  sendCreateNewLiveRequest(
                                    dToken,
                                    sUserName,
                                    leave_type,
                                    formattedsDate,
                                    formattedeDate,
                                    isHalfDay,
                                    sUserInfo,
                                  );
                                  print("The data is saved");
                                  ScaffoldMessenger.of(context)
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Your leave request is saved"),
                                      ),
                                    );
                                } catch (e) {
                                  Fluttertoast.showToast(
                                      msg: "Invalid Date Formate");
                                }
                              },
                              text: 'Yes',
                              iconData: Icons.delete,
                              color: Colors.red,
                              textStyle: TextStyle(color: Colors.white),
                              iconColor: Colors.white,
                            ),
                          ],
                        );
                      }
                    },
                    child: Icon(Icons.save),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        fixedSize: Size(30, 50.0)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        fixedSize: Size(30, 50.0)),
                    onPressed: () {
                      print(list_type);
                      print(startDateSelected.text);
                      print(endDateSelected.text);
                      print(isChecked);
                      if (list_type.isEmpty) {
                        print('Leave Type is empty');
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text("Leave Type is empty"),
                            ),
                          );
                      } else if (startDateSelected.text.isEmpty) {
                        print('Start Date is empty');
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text("Start Date is empty"),
                            ),
                          );
                      } else if (endDateSelected.text.isEmpty) {
                        print('End date is empty');
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text("End date is empty"),
                            ),
                          );
                      } else {
                        Dialogs.bottomMaterialDialog(
                          msg:
                              'Are you sure? you want to send email for new leave?',
                          title: 'Email Sending',
                          context: context,
                          actions: [
                            IconsOutlineButton(
                              onPressed: () {
                                Navigator.pop(context);
                                print("The data is saved");
                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Your mail seding request is cancled"),
                                    ),
                                  );
                              },
                              text: 'No',
                              iconData: Icons.cancel_outlined,
                              textStyle: TextStyle(color: Colors.grey),
                              iconColor: Colors.grey,
                            ),
                            IconsButton(
                              onPressed: () async {
                                try {
                                  Navigator.pop(context);
                                  DateTime startDateTime =
                                      DateTime.parse(startDateSelected.text);
                                  DateTime endDateTime =
                                      DateTime.parse(endDateSelected.text);
                                  String leave_type = list_type;
                                  String formattedsDate = startDateSelected.text
                                      .replaceAll('-', '');
                                  String formattedeDate =
                                      endDateSelected.text.replaceAll('-', '');
                                  bool isHalfDay =
                                      bool.parse(isChecked.toString());
                                  print('the date: ${formattedeDate}');
                                  print(formattedsDate);
                                  String my_remarks = remarks.text;
                                  sendCreateNewLiveRequesttoMail(
                                    dToken,
                                    sUserName,
                                    leave_type,
                                    formattedsDate,
                                    formattedeDate,
                                    my_remarks,
                                    isHalfDay,
                                    sUserInfo,
                                  );

                                  print("The data is saved");
                                  ScaffoldMessenger.of(context)
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Your mail has been send"),
                                      ),
                                    );
                                } catch (e) {
                                  Fluttertoast.showToast(
                                      msg: "Invalide Date Formate");
                                }
                              },
                              text: 'Yes',
                              iconData: Icons.delete,
                              color: Colors.red,
                              textStyle: TextStyle(color: Colors.white),
                              iconColor: Colors.white,
                            ),
                          ],
                        );
                      }
                    },
                    child: Icon(Icons.email),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Text updateTotalDate() {
  var totalDateController;
  if (startDateSelected.text.isNotEmpty && endDateSelected.text.isNotEmpty) {
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startDateSelected.text);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(endDateSelected.text);

    Duration difference = endDate.difference(startDate);
    int totalDays = difference.inDays;

    totalDateController.text = "$totalDays days";
  } else {
    totalDateController.text =
        ""; // Clear the text if any of the dates is empty
  }
  return totalDateController;
}

Future<void> getLeaveBalanceInfo(
    Token token, String mUserName, UserInfo info) async {
  // parsing the uri
  final url = Uri.parse(
      '${urls.token_url}/api/Leave/LeaveBalance/${info.result.employeeId}');
  try {
    final header = {
      'Authorization': '${token.token_type} ${token.access_token}',
    };

    final response = await http.get(
      url,
      headers: header,
    );
    print('the data');
    print(response.body);
    if (response.statusCode == 200) {
      final balncedata = jsonDecode(response.body);
      LeaveBalanceInfo balanceinfo = LeaveBalanceInfo.fromJson(balncedata);
      balances = balanceinfo.result;
      print(balances.length);
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}

final UrlManager urls = UrlManager();
Future<void> getTypeLists(Token token, String dUserName, UserInfo info) async {
  final url = Uri.parse(
      '${urls.token_url}/api/Leave/LeaveType/${info.result.employeeId}');

  try {
    final headers2 = {
      'Authorization': '${token.token_type} ${token.access_token}',
    };
    final response = await http.get(
      url,
      headers: headers2,
    );
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      var leaveInfo = LeaveTypeInfo.fromJson(data);
      listTypes = leaveInfo.result;
    }
    print(response.body);
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}

// final UrlManager urls = UrlManager();

Future<void> sendCreateNewLiveRequest(
  Token token,
  String mUserName,
  String mleaveType,
  String mStartDate,
  String mEndDate,
  bool isHalf,
  UserInfo info,
) async {
  print('$mEndDate and $mStartDate');
  final url = Uri.parse(
      '${urls.token_url}/api/Leave/CrateLeave/${info.result.employeeId}');
  final url2 = Uri.parse(
      '${urls.token_url}/api/Leave/CrateLeaveSchedule/${info.result.employeeId}');
  try {
    final headers2 = {
      'Authorization': '${token.token_type} ${token.access_token}',
    };
    print("the rquest send date: ${mStartDate} and ${mEndDate}");
    final bodys = {
      "EmployeeId": "${info.result.employeeId}",
      "LeaveType_E": "${mleaveType}",
      "LeaveYear": "${DateTime.now().year}",
      "IsHalfDay": isHalf ? '1' : '0',
      "IsLWP": "0",
      "FromDate": "${mStartDate}",
      "ToDate": "${mEndDate}",
    };
    final response = await http.post(
      url,
      headers: headers2,
      body: bodys,
    );
    final response2 = await http.post(
      url2,
      headers: headers2,
      body: bodys,
    );
    print(response.statusCode);
    print(response.body);
    print(response2.body);
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}

Future<void> sendCreateNewLiveRequesttoMail(
  Token token,
  String mUserName,
  String mleaveType,
  String mStartDate,
  String mEndDate,
  String mRemarks,
  bool isHalf,
  UserInfo info,
) async {
  print('$mEndDate and $mStartDate');
  final url = Uri.parse(
      '${urls.token_url}/api/Leave/CrateLeaveWithEmail/${info.result.employeeId}');
  try {
    final headers2 = {
      'Authorization': '${token.token_type} ${token.access_token}',
    };
    print("the rquest send date: ${mStartDate} and ${mEndDate}");
    final bodys = {
      "EmployeeId": "${info.result.employeeId}",
      "LeaveType_E": "${mleaveType}",
      "LeaveYear": "${DateTime.now().year}",
      "IsHalfDay": isHalf ? '1' : '0',
      "IsLWP": "0",
      "FromDate": "${mStartDate}",
      "ToDate": "${mEndDate}",
      "SaveType": "email",
      "Remarks": "${mRemarks}"
    };
    final response = await http.post(
      url,
      headers: headers2,
      body: bodys,
    );
    print(response.statusCode);
    print(response.body);
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}
