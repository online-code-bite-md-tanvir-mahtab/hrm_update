import 'dart:convert';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendancedashboard.dart';
import 'package:hrm_attendance_application_test/screen/genarateScreen1.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/leave.dart';
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
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/token.dart';
import 'leavebalance.dart';
import 'package:http/http.dart' as http;

final ColorPicker colorPicker = ColorPicker();

class AdminLeaveInfo extends StatelessWidget {
  const AdminLeaveInfo({
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
    return MaterialApp(
      home: SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              return false;
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

List<LeaveItem> admin_atten = [];

bool isClicked = false;
TextEditingController leave_from_date = TextEditingController();
TextEditingController leave_to_date = TextEditingController();

final TextEditingController searchController = TextEditingController();

class _LeaveUi extends State<LeaveUi> {
  _LeaveUi(this.mtoken, this.dusername, this.dInfo);
  final Token mtoken;
  final String dusername;
  final UserInfo dInfo;

  List<LeaveItem> filterData = [];
  List<String> sugests = [];

  @override
  void initState() {
    getLeaveInfoforadvisor(mtoken, dusername, dInfo).then((value) {
      setState(() {
        DateTime now = DateTime.now();
        DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
        String formattedDateFrom =
            DateFormat('yyyy-MM-dd').format(firstDateOfMonth);
        String formattedDateTo = DateFormat('yyyy-MM-dd').format(now);
        leave_from_date.text = formattedDateFrom.toString();
        leave_to_date.text = formattedDateTo.toString();
        filterData = admin_atten;
        for (var d in filterData) {
          dynamic value = '${d.empName}:${d.empCode}';
          if (!sugests.contains(value)) {
            sugests.add(value);
          }
        }
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    leave_from_date.clear();
    leave_to_date.clear();
    searchController.clear();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    setState(() {
      filterData = text.isEmpty
          ? admin_atten
          : admin_atten
              .where((element) =>
                  element.employeeId
                      .toLowerCase()
                      .contains(text.toLowerCase()) ||
                  element.empName.toLowerCase().contains(text.toLowerCase()) ||
                  element.empCode.toLowerCase().contains(text.toLowerCase()))
              .toList();
    });
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

      // Filter the list based on the date range
      print(data.length);
      filteredData = data.where((item) {
        DateTime itemDate = dateFormat.parse(item.fromDate);
        return (itemDate.isAfter(startDate) && itemDate.isBefore(endDate)) ||
            itemDate.isAtSameMomentAs(startDate) ||
            itemDate.isAtSameMomentAs(endDate);
      }).toList();
      print(filteredData);
      // Print the filtered data
      if (searchController.toString().contains(':')) {
        print("yes");
        searchController.text =
            searchController.text.toString().split(":").first;
      } else {
        print('no');
      }
      setState(() {
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
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalide Date Formate");
    }

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
          'Admin Leave Info',
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
                        info: userInfo,
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
                style: TextStyle(fontSize: 10.0, color: colorPicker.footerText),
              )
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: LiquidPullToRefresh(
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
                          const SizedBox(
                            height: 1.0,
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
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                  leave_from_date.text =
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
                          const SizedBox(
                            height: 1.0,
                          ),
                          const Text(
                            "To",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 1.0,
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
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
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
                          SizedBox(
                            height: 10.0,
                          ),
                          SizedBox(
                            width: 254.0,
                            height: 60.0,
                            child: EasyAutocomplete(
                              // controller: leave_from_date,
                              controller: searchController,
                              suggestions: sugests,
                              onChanged: (value) => null,
                              onSubmitted: (value) async {
                                setState(() {
                                  searchController.text = value;
                                });
                              },

                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(217, 217, 217, 217),
                                border: OutlineInputBorder(),
                                hintText: "Enter the employee name or code: ",
                                contentPadding: EdgeInsets.only(
                                    top: 1.0, bottom: 1.0, left: 10.0),
                              ),
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
                        filterData = filterAndSortByDate(admin_atten,
                            leave_from_date.text, leave_to_date.text);
                      });
                    }
                  },
                  child: Icon(Icons.search),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0F0F0F),
                      minimumSize: Size(40.0, 30.0)),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                filterData.isEmpty
                    ? Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.black,
                          size: 100,
                        ),
                      )
                    : InteractiveViewer(
                        constrained: true,
                        child: FittedBox(
                          fit: BoxFit.cover,
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
                                      'Start Date',
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
                                      'Action',
                                      style: TextStyle(),
                                    ),
                                  ),
                                ),
                              ],
                              rows: dInfo.result.employeeId == '1_0' ||
                                      dInfo.result.isAdmin == "True"
                                  ? [
                                      for (int i = 0;
                                          i < filterData.length;
                                          i++)
                                        DataRow(
                                          cells: <DataCell>[
                                            DataCell(
                                                Text(filterData[i].empCode)),
                                            DataCell(
                                                Text(filterData[i].empName)),
                                            DataCell(
                                                Text(filterData[i].fromDate)),
                                            DataCell(Text(
                                                filterData[i].leaveType_E)),
                                            DataCell(
                                                Text(filterData[i].dayType)),
                                            DataCell(Text(
                                                "${filterData[i].totalLeave}")),
                                            DataCell(
                                                Text(filterData[i].approval)),
                                            DataCell(
                                              Row(
                                                children: [
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                    onPressed: () async {
                                                      // admin_atten.clear();
                                                      if (filterData[i]
                                                              .approval
                                                              .toString()
                                                              .toLowerCase() ==
                                                          'approved') {
                                                        ScaffoldMessenger.of(
                                                            context)
                                                          ..clearSnackBars()
                                                          ..showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  "You Already Made A Action so you can't make another action"),
                                                            ),
                                                          );
                                                      } else if (filterData[i]
                                                              .approval
                                                              .toString()
                                                              .toLowerCase() ==
                                                          'pending') {
                                                        Dialogs
                                                            .bottomMaterialDialog(
                                                          msg:
                                                              'Are you sure ? you want to approve this leave',
                                                          title:
                                                              'Approval Massege',
                                                          context: context,
                                                          actions: [
                                                            IconsOutlineButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              text: 'Cancel',
                                                              iconData: Icons
                                                                  .cancel_outlined,
                                                              textStyle: TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                              iconColor:
                                                                  Colors.grey,
                                                            ),
                                                            IconsButton(
                                                              onPressed: () {
                                                                String id =
                                                                    (filterData[i]
                                                                            .id)
                                                                        .toString();
                                                                setState(() {
                                                                  actionOfTheAdminForApproval(
                                                                      mtoken,
                                                                      true,
                                                                      false,
                                                                      id,
                                                                      dInfo,
                                                                      dusername,
                                                                      context);

                                                                  filterData
                                                                      .clear();
                                                                });
                                                                Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            10),
                                                                    () {
                                                                  getLeaveInfoforadvisor(
                                                                          mtoken,
                                                                          dusername,
                                                                          dInfo)
                                                                      .then(
                                                                          (value) {
                                                                    setState(
                                                                        () {
                                                                      filterData =
                                                                          admin_atten;
                                                                    });
                                                                  });
                                                                });
                                                                Navigator.pop(
                                                                    context);
                                                                ScaffoldMessenger
                                                                    .of(context)
                                                                  ..clearSnackBars()
                                                                  ..showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Text("Your action is done")));
                                                              },
                                                              text: 'Yes',
                                                              iconData:
                                                                  Icons.check,
                                                              color: Colors.red,
                                                              textStyle: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                            context)
                                                          ..clearSnackBars()
                                                          ..showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "The Action Already been completed and You can't make another chocie")));
                                                      }
                                                    },
                                                    child: Icon(Icons.check),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.red),
                                                    onPressed: () async {
                                                      // admin_atten.clear();
                                                      if (filterData[i]
                                                              .approval
                                                              .toString()
                                                              .toLowerCase() ==
                                                          'rejected') {
                                                        ScaffoldMessenger.of(
                                                            context)
                                                          ..clearSnackBars()
                                                          ..showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  "You Already Made A Action so you can't make another action"),
                                                            ),
                                                          );
                                                      } else if (filterData[i]
                                                              .approval
                                                              .toLowerCase()
                                                              .toString() ==
                                                          'pending') {
                                                        Dialogs
                                                            .bottomMaterialDialog(
                                                          msg:
                                                              'Are you sure ? you want to reject this leave',
                                                          title:
                                                              "Rejected Message",
                                                          color: Colors.white,
                                                          context: context,
                                                          actions: [
                                                            IconsOutlineButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              text: 'Cancel',
                                                              iconData: Icons
                                                                  .cancel_outlined,
                                                              textStyle: TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                              iconColor:
                                                                  Colors.grey,
                                                            ),
                                                            IconsButton(
                                                              onPressed: () {
                                                                print(
                                                                    "close clicked");
                                                                String id =
                                                                    (filterData[i]
                                                                            .id)
                                                                        .toString();
                                                                setState(() {
                                                                  actionofAdminRejected(
                                                                      mtoken,
                                                                      dInfo
                                                                          .result
                                                                          .employeeId
                                                                          .toString(),
                                                                      id,
                                                                      dusername,
                                                                      false,
                                                                      true);

                                                                  filterData
                                                                      .clear();
                                                                });
                                                                Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            10),
                                                                    () {
                                                                  getLeaveInfoforadvisor(
                                                                          mtoken,
                                                                          dusername,
                                                                          dInfo)
                                                                      .then(
                                                                          (value) {
                                                                    setState(
                                                                        () {
                                                                      filterData =
                                                                          admin_atten;
                                                                    });
                                                                  });
                                                                });
                                                                Navigator.pop(
                                                                    context);

                                                                ScaffoldMessenger
                                                                    .of(context)
                                                                  ..clearSnackBars()
                                                                  ..showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Text("Your action is done")));
                                                              },
                                                              text: 'Yes',
                                                              iconData:
                                                                  Icons.delete,
                                                              color: Colors.red,
                                                              textStyle: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                            context)
                                                          ..clearSnackBars()
                                                          ..showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "The Action Already been completed and You can't make another chocie")));
                                                      }
                                                    },
                                                    child: Icon(Icons.close),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ]
                                  : isClicked
                                      ? [
                                          for (int j = 0;
                                              j < filterData.length;
                                              j++)
                                            DataRow(
                                              cells: <DataCell>[
                                                DataCell(Text(
                                                    filterData[j].empCode)),
                                                DataCell(Text(
                                                    filterData[j].fromDate)),
                                                DataCell(Text(
                                                    filterData[j].leaveType_E)),
                                                DataCell(Text(
                                                    filterData[j].dayType)),
                                                DataCell(Text(
                                                    "${filterData[j].totalLeave}")),
                                                DataCell(Text(
                                                    filterData[j].approval)),
                                                DataCell(
                                                  Icon(Icons.download),
                                                  onTap: () async {
                                                    String id =
                                                        (filterData[j].id)
                                                            .toString();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PdfViewerScreen(
                                                          pdfId: id,
                                                          token: mtoken,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                        ]
                                      : [
                                          for (int i = 0;
                                              i < filterData.length;
                                              i++)
                                            DataRow(
                                              cells: <DataCell>[
                                                DataCell(Text(
                                                    filterData[i].empCode)),
                                                DataCell(Text(
                                                    filterData[i].fromDate)),
                                                DataCell(Text(
                                                    filterData[i].leaveType_E)),
                                                DataCell(Text(
                                                    filterData[i].dayType)),
                                                DataCell(Text(
                                                    "${filterData[i].totalLeave}")),
                                                DataCell(Text(
                                                    filterData[i].approval)),
                                                DataCell(
                                                  Icon(Icons.download),
                                                  onTap: () async {
                                                    String id =
                                                        (filterData[i].id)
                                                            .toString();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PdfViewerScreen(
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
          ),
          onRefresh: () async {
            getLeaveInfoforadvisor(mtoken, dusername, userInfo).then((value) {
              setState(() {
                filterData = admin_atten;
              });
            });
          },
        ),
      ),
    );
  }
}

Future<void> actionofAdminRejected(Token ztoken, String appBy, String id,
    String upby, bool isapprove, bool isrejected) async {
  final url = Uri.parse('http://103.231.239.122:8018/api/Leave/LeaveApprove');

  final headers = {
    'Authorization': '${ztoken.token_type} ${ztoken.access_token}',
    'Content-Type': 'application/json',
  };
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
  final data = {
    'ApprovedBy': appBy.toString(),
    'Id': id.toString(),
    'LastUpdateAt': formattedDate.toString(),
    'LastUpdateBy': upby.toString(),
    'IsApprove': isapprove.toString(),
    'IsReject': isrejected.toString(),
    'RejectedBy': '',
  };
  print(data);

  try {
    final response =
        await http.post(url, headers: headers, body: json.encode(data));
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
    } else {}
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
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
  print('by:${userName}himself');
  print('which${reId}it is');
  print('empid${sInfo.result.employeeId}i know');
  print('is${isApproved.toString()}aprove');
  print('is${isRejected.toString()}reject');

  try {
    final headers2 = {
      'Authorization': '${token.token_type} ${token.access_token}',
    };
    final bod = {
      "ApprovedBy": sInfo.result.employeeId.toString(),
      "Id": reId.toString(),
      "LastUpdateAt": formattedDate.toString(),
      "LastUpdateBy": userName.toString(),
      "IsApprove": isApproved.toString(),
      "IsReject": isRejected.toString(),
      "RejectedBy": ""
    };
    print(bod);
    final response = await http.post(url, headers: headers2, body: bod);
    print(response.statusCode);
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
    Fluttertoast.showToast(msg: "Server Problem");
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
Future<void> getLeaveInfoforadvisor(
    Token token, String sUserName, UserInfo info) async {
  dynamic url = null;
  if ((info.result.employeeId == '1_0') || (info.result.isAdmin == "True")) {
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
    // print(response.statusCode);
    // print(response.body.length);
    if (response.statusCode == 200) {
      print("going");
      // print(response.body);
      final leaveData = jsonDecode(response.body);
      if (leaveData != null) {
        // print(leaveData);
        LeaveInfo leaveInfo = LeaveInfo.fromJson(leaveData);
        // print(leaveInfo);
        admin_atten = leaveInfo.result;
        print('leve : ${admin_atten.length}');
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
                Navigator.push(
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
