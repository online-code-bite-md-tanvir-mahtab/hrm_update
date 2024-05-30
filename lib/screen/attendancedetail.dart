import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:emerge_alert_dialog/emerge_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendancedashboard.dart';
import 'package:hrm_attendance_application_test/screen/genarateScreen1.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/leavedashboard.dart';
import 'package:hrm_attendance_application_test/screen/testProfile.dart';
import 'package:hrm_attendance_application_test/util/detailinfo.dart';
import 'package:hrm_attendance_application_test/util/detailitem.dart';
import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maps_launcher/maps_launcher.dart';

TextEditingController _remarks = TextEditingController();
final ColorPicker colorPicker = ColorPicker();

class AttendanceDetail extends StatelessWidget {
  const AttendanceDetail({
    super.key,
    required this.sToken,
    required this.sUserName,
    required this.sUserInfo,
  });

  final String sUserName;
  final Token sToken;
  final UserInfo sUserInfo;
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
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectDateRange(
                              zUserName: sUserName,
                              zToken: sToken,
                              zReportType: 'Sumarry',
                              dInof: sUserInfo),
                        ),
                      );
                    },
                    icon: Icon(Icons.summarize))
              ],
              elevation: 0,
              backgroundColor: Color(colorPicker.appbarBackgroudncolor),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: colorPicker.footerText,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceDashboard(
                        mToken: sToken,
                        mUserName: sUserName,
                        mUserInfo: sUserInfo,
                      ),
                    ),
                  );
                },
              ),
              title: Text(
                'Attendance Sumarry',
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
                              userName: sUserName,
                              token: sToken,
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
                              info: sUserInfo,
                              userName: sUserName,
                              token: sToken,
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
                                mToken: sToken,
                                mUserName: sUserName,
                                mUserInfo: sUserInfo),
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
                                mToken: sToken,
                                mUserName: sUserName,
                                mUserInfo: sUserInfo),
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
            body: DetailBody(sUserName, sToken),
          ),
        ),
      ),
    );
  }
}

class DetailBody extends StatefulWidget {
  const DetailBody(this.duserName, this.dToken);
  final String duserName;
  final Token dToken;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailBody(duserName, dToken);
  }
}

List<DetailItem> atten = [];
late Uint8List imageBytes;
TextEditingController detail_from_date = TextEditingController();
TextEditingController detail_to_date = TextEditingController();
bool isDone = false;
List<String> sugests = [];
final TextEditingController searchController = TextEditingController();

class _DetailBody extends State<DetailBody> {
  String mUserName;
  Token mToken;
  List<DetailItem> filteredData = [];
  _DetailBody(this.mUserName, this.mToken);

  @override
  void initState() {
    getAttendanceDetail(mUserName, mToken).then((value) {
      if (mounted) {
        setState(() {
          DateTime now = DateTime.now();
          DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
          String formattedDateFrom =
              DateFormat('yyyy-MM-dd').format(firstDateOfMonth);
          String formattedDateTo = DateFormat('yyyy-MM-dd').format(now);
          detail_from_date.text = formattedDateFrom.toString();
          detail_to_date.text = formattedDateTo.toString();
          filteredData = atten;
          for (var d in filteredData) {
            dynamic value = '${d.code}';
            sugests.add(value);
          }
        });
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    detail_from_date.clear();
    detail_to_date.clear();
    searchController.clear();
    // TODO: implement dispose
    super.dispose();
  }

  List<DetailItem> filterAndSortByDate(String startDate, String endDate) {
    try {
      DateTime startDateTime = DateTime.parse(startDate);
      DateTime endDateTime = DateTime.parse(endDate);
      if (mounted) {
        setState(() {
          filteredData.clear();
        });
      }
      getAttendanceDetailByDateSearch(userInfo.result.logId.toString(), mToken,
              startDateTime, endDateTime)
          .then((value) {
        if (mounted) {
          setState(() {
            filteredData = atten;
            filteredData = searchController.text.isEmpty
                ? filteredData
                : filteredData
                    .where(
                      (element) => element.code.toLowerCase().contains(
                            searchController.text.toLowerCase(),
                          ),
                    )
                    .toList();
          });
        }
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalide Date formate");
    }

    return filteredData;
  }

  bool isData() {
    // Simulate an API call or data loading process
    Future.delayed(Duration(seconds: 30), () {
      if (filteredData.isEmpty) {
        if (mounted) {
          setState(() {
            isDone = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isDone = false;
          });
        }
      }
    });
    // Wait for 2 seconds

    return isDone;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return LiquidPullToRefresh(
      onRefresh: () async {
        getAttendanceDetail(mUserName, mToken).then((value) {
          if (mounted) {
            setState(() {
              filteredData = atten;
            });
          }
        });
      },
      child: SingleChildScrollView(
        child: Column(
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
                          controller: detail_from_date,
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
                              detail_from_date.text = formattedDate.toString();
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
                          controller: detail_to_date,
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
                              detail_to_date.text = formattedDate.toString();
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
                  if (mounted) {
                    setState(() {
                      searchController.text = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(217, 217, 217, 217),
                  border: OutlineInputBorder(),
                  hintText: "Enter the employee code: ",
                  contentPadding:
                      EdgeInsets.only(top: 1.0, bottom: 1.0, left: 10.0),
                ),
                onChanged: (value) => null,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (detail_from_date.text.isEmpty) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(
                        content: Text("The From date is empty"),
                      ),
                    );
                } else if (detail_to_date.text.isEmpty) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('The To date is empty'),
                      ),
                    );
                } else {
                  if (mounted) {
                    setState(() {
                      filteredData = filterAndSortByDate(
                          detail_from_date.text, detail_to_date.text);
                    });
                  }
                }
              },
              child: Icon(Icons.search),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F0F0F),
                  minimumSize: Size(40.0, 30.0)),
            ),
            colorPicker.testProfielCard(userInfo),
            filteredData.isEmpty
                ? isData()
                    ? Center(
                        child: LiquidPullToRefresh(
                          onRefresh: () async {
                            if (mounted) {
                              setState(() {
                                filteredData.clear();
                              });
                            }
                            getAttendanceDetail(mUserName, mToken)
                                .then((value) {
                              if (mounted) {
                                setState(() {
                                  filteredData = atten;
                                });
                              }
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/assets/cloud.png',
                                width: 60,
                                height: 60,
                              ),
                              Text(
                                "There is no attendance data in your profile! please refreash the page",
                                style: TextStyle(color: Colors.amber),
                              ),
                              IconButton(
                                onPressed: () async {
                                  if (mounted) {
                                    setState(() {
                                      filteredData.clear();
                                    });
                                  }
                                  LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.black,
                                    size: 100,
                                  );
                                  getAttendanceDetail(mUserName, mToken)
                                      .then((value) {
                                    if (mounted) {
                                      setState(() {
                                        filteredData = atten;
                                      });
                                    }
                                  });
                                },
                                icon: Icon(Icons.refresh),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.black,
                          size: 100,
                        ),
                      )
                : InteractiveViewer(
                    constrained: true,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: DataTable(
                        sortAscending: false,
                        columns: const <DataColumn>[
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
                                'Emp Code',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Time',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Remarks',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Location',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Image',
                                style: TextStyle(),
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          for (int i = 0; i < filteredData.length; i++)
                            DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  Text(DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(filteredData[i].date))),
                                ),
                                DataCell(
                                  Text(filteredData[i].code),
                                ),
                                DataCell(
                                  Text(filteredData[i].time),
                                ),
                                DataCell(
                                  Text(filteredData[i].remarks),
                                ),
                                DataCell(
                                  GestureDetector(
                                    child: Image.asset(
                                        'images/assets/location.png'),
                                    onTap: () async {
                                      if (filteredData[i].latitude.isNotEmpty &&
                                          filteredData[i]
                                              .longtitide
                                              .isNotEmpty) {
                                        var latitude = double.parse(
                                            filteredData[i].latitude);
                                        var longitude = double.parse(
                                            filteredData[i].longtitide);
                                        MapsLauncher.launchCoordinates(latitude,
                                            longitude, 'Location Coordinates');
                                      } else {
                                        print('Latitude or longitude is empty');
                                        _showMyDialog(context);

                                        // Handle the case where latitude or longitude is empty
                                      }
                                    },
                                  ),
                                ),
                                DataCell(
                                  GestureDetector(
                                    child: Icon(
                                      Icons.preview,
                                    ),
                                    onTap: () async {
                                      if (filteredData[i]
                                          .locationImage
                                          .isNotEmpty) {
                                        ;
                                        _loadImage(
                                            filteredData[i].locationImage,
                                            mToken);
                                        _showImagePopup(
                                            context,
                                            "${urls.token_url}/api/Attendance/GetImage/" +
                                                filteredData[i]
                                                    .locationImage
                                                    .replaceAll(".jpg", ''));
                                        print(
                                            "${urls.token_url}/api/Attendance/GetImage/" +
                                                filteredData[i]
                                                    .locationImage
                                                    .replaceAll(".jpg", ''));
                                      } else {
                                        print('Latitude or longitude is empty');
                                        _showMyDialog2(context);

                                        // Handle the case where latitude or longitude is empty
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

void _showImagePopup(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          width: 200.0, // Adjust the height as needed
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl), // Replace with your image asset
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

Future<void> _loadImage(String imageName, Token token) async {
  try {
    final response = await http.get(
      Uri.parse("${urls.token_url}/api/Attendance/GetImage/${imageName}"),
      headers: {
        'Authorization': '${token.token_type} ${token.access_token}'
      }, // Add your authorization header
    );
    if (response.statusCode == 200) {
      imageBytes = response.bodyBytes;
    } else {
      print('Failed to load image. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error loading image: $error');
  }
}

Future<void> _showMyDialog2(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return EmergeAlertDialog(
        alignment: Alignment.bottomCenter,
        emergeAlertDialogOptions: EmergeAlertDialogOptions(
            title: const Text(
              "Image",
            ),
            content: const Text(
              "Couldn't found your image",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "ok",
                ),
              )
            ]),
      );
    },
  );
}

Future<void> _showMyDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return EmergeAlertDialog(
        alignment: Alignment.bottomCenter,
        emergeAlertDialogOptions: EmergeAlertDialogOptions(
            title: const Text(
              "Location",
            ),
            content: const Text(
              "Couldn't found your location",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "ok",
                ),
              )
            ]),
      );
    },
  );
}

final UrlManager urls = UrlManager();

Future<void> getAttendanceDetail(String dUserLogId, Token token) async {
  DateTime today = DateTime.now();
  print(dUserLogId);
  String current_month = DateFormat('yyyyMM').format(today);
  final url = Uri.parse(
      "${urls.token_url}/api/Attendance/CheckInDetails/${dUserLogId.replaceAll(' ', '')}/${current_month}01/${current_month}30");
  print("urls is parsed");

  // use the try catch block to hendle anykind error
  try {
    final header = {
      'Authorization': '${token.token_type} ${token.access_token}'
    };
    print("helo world");
    final response = await http.get(url, headers: header);
    print(response.body);
    if (response.statusCode == 200) {
      final attendanceData = await jsonDecode(response.body);
      DetailInfo detailInfo = await DetailInfo.fromJson(attendanceData);
      atten = detailInfo.result;
      print(atten.length);
    } else {
      print("something is worng");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}

Future<void> getAttendanceDetailByDateSearch(
    String dUserLogId, Token token, DateTime sDate, DateTime eDate) async {
  String start_date = DateFormat('yyyyMMdd').format(sDate);
  String end_date = DateFormat('yyyyMMdd').format(eDate);
  print(start_date);
  print(end_date);
  final url = await Uri.parse(
      "${urls.token_url}/api/Attendance/CheckInDetails/${dUserLogId.replaceAll(' ', '')}/${start_date}/${end_date}");

  final header = {'Authorization': '${token.token_type} ${token.access_token}'};
  // use the try catch block to hendle anykind error
  try {
    final response = await http.get(url, headers: header);
    // print(response.body);
    if (response.statusCode == 200) {
      final attendanceData = await jsonDecode(response.body);
      DetailInfo detailInfo = await DetailInfo.fromJson(attendanceData);
      atten = detailInfo.result;
      print(atten.length);
    } else {
      print("something is worng");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}
