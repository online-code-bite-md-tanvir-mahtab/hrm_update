import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendancepdfView.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/sumarrypdfView.dart';
import 'package:hrm_attendance_application_test/util/attendanceitem.dart';
import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/leaveitem.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:intl/intl.dart';

// import '../util/leaveinfo.dart';
import 'downloadpdf.dart';
// import 'package:http/http.dart' as http;

final TextEditingController from_date = TextEditingController();
final TextEditingController to_date = TextEditingController();
final TextEditingController empSearch = TextEditingController();
final ColorPicker colorPicker = ColorPicker();

class SelectDateRange extends StatelessWidget {
  const SelectDateRange(
      {super.key,
      required this.zUserName,
      required this.zToken,
      required this.zReportType,
      required this.dInof});
  final String zUserName;
  final Token zToken;
  final String zReportType;
  final UserInfo dInof;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Select Date',
                  style: TextStyle(color: colorPicker.footerText),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context, 'ok');
                  },
                  color: colorPicker.footerText,
                ),
                backgroundColor: Color(colorPicker.appbarBackgroudncolor),
                elevation: 0,
              ),
              body: InteractiveViewer(
                  child: DatePicker(zUserName, zToken, zReportType, dInof))),
        ),
      ),
    );
  }
}

class DatePicker extends StatelessWidget {
  DatePicker(this.mUserName, this.mToken, this.mReportType, this.uInfo);
  final String mUserName;
  final Token mToken;
  final String mReportType;
  final UserInfo uInfo;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ReportBody(mUserName, mToken, mReportType, uInfo),
    );
  }
}

class ReportBody extends StatefulWidget {
  final String dUserName;
  final Token dToken;
  final String sReportType;
  final UserInfo dUInfo;
  ReportBody(this.dUserName, this.dToken, this.sReportType, this.dUInfo);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ReportBody(dUserName, dToken, sReportType, dUInfo);
  }
}

List<AttendanceItem> atten = [];
List<LeaveItem> atten2 = [];

class _ReportBody extends State<ReportBody> {
  String sUserName;
  Token sToken;
  String reportType;
  UserInfo sUinfo;
  _ReportBody(this.sUserName, this.sToken, this.reportType, this.sUinfo);
  @override
  void dispose() {
    // TODO: implement dispose
    from_date.clear();
    to_date.clear();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    String formattedDateFrom =
        DateFormat('yyyy-MM-dd').format(firstDateOfMonth);
    String formattedDateTo = DateFormat('yyyy-MM-dd').format(now);
    from_date.text = formattedDateFrom.toString();
    to_date.text = formattedDateTo.toString();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
                    height: 10.0,
                  ),
                  SizedBox(
                    width: 254.0,
                    child: TextField(
                      controller: from_date,
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
                          from_date.text = formattedDate.toString();
                        }
                      },
                      // controller: _controller2,
                      decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_month),
                          filled: true,
                          fillColor: Color.fromARGB(217, 217, 217, 217),
                          border: OutlineInputBorder(),
                          hintText: "Enter the Starting date: "),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    "To",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    width: 254.0,
                    child: TextField(
                      controller: to_date,
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
                          to_date.text = formattedDate.toString();
                        }
                      },
                      // controller: _controller2,
                      decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_month),
                          filled: true,
                          fillColor: Color.fromARGB(217, 217, 217, 217),
                          border: OutlineInputBorder(),
                          hintText: "Enter the End date: "),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        colorPicker.testProfielCard(userInfo),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                from_date;
                to_date;
                if (!from_date.text.isEmpty) {
                  if (!to_date.text.isEmpty) {
                    if (reportType == 'Attendance') {
                      if (empSearch.text.toString().isEmpty) {
                        try {
                          DateTime startDateTime =
                              DateTime.parse(from_date.text);
                          DateTime endDateTime = DateTime.parse(to_date.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendancePdfView(
                                sToken: sToken,
                                uId: sUinfo.result.logId,
                                uFrom: from_date.text,
                                uTo: to_date.text,
                              ),
                            ),
                          );
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Invalide Date formate");
                        }
                      } else {
                        try {
                          DateTime startDateTime =
                              DateTime.parse(from_date.text);
                          DateTime endDateTime = DateTime.parse(to_date.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendancePdfView(
                                sToken: sToken,
                                uId: empSearch.text,
                                uFrom: from_date.text,
                                uTo: to_date.text,
                              ),
                            ),
                          );
                        } catch (e) {
                          Fluttertoast.showToast(msg: "INvalide Date Formate");
                        }
                      }
                    } else if (reportType == 'Sumarry') {
                      if (empSearch.text.toString().isEmpty) {
                        try {
                          DateTime startDateTime =
                              DateTime.parse(from_date.text);
                          DateTime endDateTime = DateTime.parse(to_date.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SumarryPdfView(
                                sToken: sToken,
                                uId: sUinfo.result.logId,
                                uFrom: from_date.text,
                                uTo: to_date.text,
                              ),
                            ),
                          );
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Invalide Date formate");
                        }
                      } else {
                        try {
                          DateTime startDateTime =
                              DateTime.parse(from_date.text);
                          DateTime endDateTime = DateTime.parse(to_date.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendancePdfView(
                                sToken: sToken,
                                uId: empSearch.text,
                                uFrom: from_date.text,
                                uTo: to_date.text,
                              ),
                            ),
                          );
                        } catch (e) {
                          Fluttertoast.showToast(msg: "INvalide Date Formate");
                        }
                      }
                    } else {
                      if (empSearch.text.toString().isEmpty) {
                        try {
                          DateTime startDateTime =
                              DateTime.parse(from_date.text);
                          DateTime endDateTime = DateTime.parse(to_date.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfPreviewPage(
                                sToken: sToken,
                                uId: sUinfo.result.employeeId,
                              ),
                            ),
                          );
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Invalide Date Formate");
                        }
                      } else {
                        try {
                          DateTime startDateTime =
                              DateTime.parse(from_date.text);
                          DateTime endDateTime = DateTime.parse(to_date.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfPreviewPage(
                                sToken: sToken,
                                uId: empSearch.text,
                              ),
                            ),
                          );
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Invalide Date formate");
                        }
                      }
                    }
                  } else {
                    print("the to date is empty");
                  }
                } else {
                  print("the date is empty");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6a6a6a),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 20,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.preview,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    "Preview",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
