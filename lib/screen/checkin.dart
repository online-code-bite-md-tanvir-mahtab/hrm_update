import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:html';

// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:camera/camera.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hrm_attendance_application_test/navigation/colorpicker.dart';
import 'package:hrm_attendance_application_test/screen/attendancedashboard.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/screen/imagepreview.dart';
import 'package:hrm_attendance_application_test/util/ResponseItem.dart';
import 'package:hrm_attendance_application_test/util/attendancepolicyinfo.dart';
import 'package:hrm_attendance_application_test/util/info.dart';
import 'package:hrm_attendance_application_test/util/policyItem.dart';
import 'package:hrm_attendance_application_test/util/reasonlist.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

final TextEditingController _remarks = TextEditingController();
List<PolicyItem> policy_items = [];
final ColorPicker colorPicker = ColorPicker();
List<ResponseItem> sugests = [];
List<String> items = [];

class CheckIn extends StatelessWidget {
  const CheckIn(
      {super.key,
      required this.userName,
      required this.token,
      required this.userInfo});
  final String userName;
  final Token token;
  final UserInfo userInfo;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: MyBody(token, userName),
      ),
    );
  }
}

bool isProcess = false;
bool isDone = false;

class MyBody extends StatefulWidget {
  MyBody(this.zToken, this.zUserName);
  final Token zToken;
  final String zUserName;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyBody(zToken, zUserName);
  }
}

bool full = false;
bool showWidget = false;
var imageFileName = "";

class _MyBody extends State<MyBody> {
  final Token mtoken;
  final String mUserName;
  late String directory;
  bool isDownloading = false;
  _MyBody(this.mtoken, this.mUserName);
  late CameraController _controller;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getPolicy(mUserName, mtoken).then((value) {
      setState(() {
        print(policy_items.first.inGraceMin);
      });
    });

    getReasonList(mtoken).then((value) {
      setState(() {
        print("Autotext genarating");
      });
    });

    initCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<CameraDescription> cameras = [];
  Future<void> initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[1], ResolutionPreset.high);
    try {
      await _controller.initialize().then((_) {
        setState(() {});
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Camera Issue");
    }
  }

  Future<String> chooseDownloadFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null && result.toString().isNotEmpty) {
      return result;
    } else {
      return "";
    }
  }

  Future<void> _downloadPdf(XFile imageFile) async {
    List<int> bytes = await imageFile.readAsBytes();
    try {
      uploadImage(bytes);
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Error downloading PDF: ${e}"),
          ),
        );
    }

    setState(() {
      isDownloading = false;
    });
  }

  Future<void> capturePicture() async {
    if (!_controller.value.isInitialized) {
      setState(() {
        initCamera();
      });
    }
    if (_controller.value.isTakingPicture) {
      return null;
    }
    try {
      XFile pathtoimage = await _controller.takePicture();
      directory = "user_data/";
      Future.delayed(Duration(milliseconds: 3));
      _downloadPdf(pathtoimage);
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(
                "Faccing problem while taking photo or you need to enable microphone permssion and come agin to this page")));

      Navigator.pop(context);
    }
  }

  UrlManager urlVariable = UrlManager();

  final TextEditingController searchController = TextEditingController();
  bool isData() {
    // Simulate an API call or data loading process
    Future.delayed(Duration(seconds: 2), () {
      if (policy_items.isEmpty) {
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

  bool isDelayed() {
    bool isBetween9to1 = false;
    bool isAfterTargetTime = false;
    try {
      // Get the current time
      DateTime currentTime = DateTime.now();

      // // Splitting inTime string to get the time part
      dynamic time = policy_items.first.inTime.split("AM")[0].split(":");

      // Getting lunchTimeMin
      dynamic time2 = policy_items.first.inGraceMin;

      // Parsing lunchTimeMin with a custom format
      // DateFormat customFormat = DateFormat('hh:mm');
      // DateTime parsedTime = customFormat.parse(time2);
      // print("the time: ${parsedTime}");
      // Get the current time

// Extracting hour and minute components from the time variable
      int hour = int.parse(time[0]);
      int minute = int.parse(time2);

// Extracting the grace minutes
      int graceMinutes = int.parse(time2);

      DateTime targetTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        hour, // 9 AM
        minute, // 15 minutes
      ).add(Duration(minutes: graceMinutes));

// Check if the current time is before the target time
      isAfterTargetTime = currentTime.isAfter(targetTime);
      print(isAfterTargetTime);
      print(hour);
      print(minute);

      print(
          'Is the current time before 9:15 plus grace minutes? $isAfterTargetTime');
    } catch (e) {
      print("the error: ${e}");
    }
    return isAfterTargetTime;
  }

  bool isAfterOnePM() {
    bool isAfterOnePM = false;
    try {
      // Get the current time
      DateTime currentTime = DateTime.now();

      // Define the target time as 1:00 PM
      DateTime targetTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        13, // 1 PM (24-hour format)
        0, // 00 minutes
      );

      // Check if the current time is after the target time
      isAfterOnePM = currentTime.isAfter(targetTime);
      print('Is the current time after 1:00 PM? $isAfterOnePM');
    } catch (e) {
      print("Error: ${e}");
    }
    return isAfterOnePM;
  }

  @override
  Widget build(BuildContext context) {
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
                    builder: (context) => AttendanceDashboard(
                        mToken: mtoken,
                        mUserName: mUserName,
                        mUserInfo: userInfo)));
          },
        ),
        title: Text(
          'Check In',
          style: TextStyle(color: colorPicker.footerText),
        ),
        backgroundColor: Color(colorPicker.appbarBackgroudncolor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Visibility(
              visible: showWidget,
              child: Center(
                child: ProgressBarAnimation(
                  duration: const Duration(seconds: 2),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.purple,
                    ],
                  ),
                  backgroundColor: Colors.grey.withOpacity(0.4),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: policy_items.isEmpty
                  ? isData()
                      ? Column(
                          children: [
                            Image.asset('images/assets/warning.png'),
                            Text(
                              "Your Time Policy hasn't been assigned!",
                              style: TextStyle(color: Colors.amber),
                            ),
                          ],
                        )
                      : Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.black,
                            size: 100,
                          ),
                        )
                  : DataTable(
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
                              Icon(
                                FontAwesomeIcons.userClock,
                                size: 18,
                                color: Colors.blueAccent, //Color Of Icon
                              ),
                            ),
                            DataCell(
                              Text(
                                'In Time',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                margin: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  policy_items.first.inTime,
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Icon(FontAwesomeIcons.userClock,
                                  size: 18,
                                  color: Colors.blueAccent //Color Of Icon
                                  ),
                            ),
                            DataCell(
                              Text(
                                'Out Time',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                margin: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  policy_items.first.outTime,
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Icon(FontAwesomeIcons.clock,
                                  size: 18,
                                  color: Colors.blueAccent //Color Of Icon
                                  ),
                            ),
                            DataCell(
                              Text(
                                'In Grace',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                margin: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  policy_items.first.inGraceMin,
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Icon(FontAwesomeIcons.clock,
                                  size: 18,
                                  color: Colors.blueAccent //Color Of Icon
                                  ),
                            ),
                            DataCell(
                              Text(
                                'Lunch Time',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                margin: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  policy_items.first.lunchTimeMin,
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Icon(Icons.rice_bowl,
                                  size: 18,
                                  color: Colors.blueAccent //Color Of Icon
                                  ),
                            ),
                            DataCell(
                              Text(
                                'Lunch Break',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                margin: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  policy_items.first.lunchBreakMin,
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 8,
              ),
              child: !isDelayed() || isAfterOnePM()
                  ? Container(
                      child: Text(""),
                    )
                  : SizedBox(
                      width: 254.0,
                      height: 60.0,
                      child: EasyAutocomplete(
                        keyboardType: TextInputType.none,
                        controller: searchController,
                        suggestions: items,
                        onChanged: (value) => null,
                        onSubmitted: (value) async {
                          setState(() {
                            _remarks.text = value;
                          });
                        },
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(217, 217, 217, 217),
                          border: OutlineInputBorder(),
                          hintText: "Select Remark's or type you reason",
                          contentPadding: EdgeInsets.only(
                              top: 1.0, bottom: 0.0, left: 10.0),
                        ),
                        // onChanged: _onSearchChanged,
                      ),
                    ),
            ),
            Card(
              elevation: 10,
              shadowColor: Colors.black,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // TODO: I need to add the auto completion message
              child: TextButton(
                onPressed: () {
                  Dialogs.bottomMaterialDialog(
                    msg:
                        'Are you sure? you want to check in now? And be aware that your location and picture will be taken',
                    title: 'Check In',
                    context: context,
                    actions: [
                      IconsOutlineButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text("Attendance is Cancled"),
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
                          Navigator.pop(context);

                          if (await Permission.camera.isGranted &&
                              await Permission.location.isGranted &&
                              await Permission.microphone.isGranted) {
                            setState(() {
                              showWidget = true;
                            });
                            DateTime currentTime = DateTime.now();
                            var time = policy_items.first.inTime
                                .split("AM")[0]
                                .split(":");
                            // Create a DateTime object for "9:00 AM" today
                            DateTime targetTime = DateTime(
                              currentTime.year,
                              currentTime.month,
                              currentTime.day,
                              int.parse(time[0]),
                              int.parse(time[1]),
                            );

                            // Add an additional duration, for example, 30 minutes
                            Duration additionalDuration = Duration(
                                minutes:
                                    int.parse(policy_items.first.inGraceMin));
                            DateTime adjustedTargetTime =
                                targetTime.add(additionalDuration);

                            // Check if the current time is equal to or after the adjusted target time
                            bool isAfterOrEqual =
                                currentTime.isAfter(adjustedTargetTime);
                            if (isDelayed()) {
                              if (_remarks.text.isEmpty) {
                                showWidget = false;
                                Fluttertoast.showToast(
                                    msg: "Please select the remarks or type");
                              } else {
                                await getCurrentLocation();
                                await getCameraPermission();
                                await isAttendanceDone(
                                    userInfo.result.employeeId,
                                    mtoken,
                                    mUserName,
                                    _remarks.text,
                                    lng,
                                    lat);

                                Future.delayed(Duration(seconds: 2), () {
                                  setState(() {
                                    showWidget = false;
                                  });
                                  // TODO: this should be the place for camera
                                  capturePicture();
                                  ScaffoldMessenger.of(context)
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text("Attendance is Success"),
                                      ),
                                    );
                                });
                              }
                            } else {
                              await getCurrentLocation();
                              await getCameraPermission();
                              await isAttendanceDone(userInfo.result.employeeId,
                                  mtoken, mUserName, _remarks.text, lng, lat);

                              Future.delayed(Duration(seconds: 2), () {
                                setState(() {
                                  showWidget = false;
                                });
                                // TODO: this should be the place for camera
                                capturePicture();
                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text("Attendance is Success"),
                                    ),
                                  );
                              });
                            }
                          } else {
                            try {
                              if (await Permission.camera.isDenied ||
                                  await Permission.camera.isPermanentlyDenied) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Please Enable the permission of the Camera");
                                await getCameraPermission();
                                await Permission.camera.request();
                              }
                            } catch (e) {
                              Fluttertoast.showToast(
                                  msg:
                                      "There is no gps function in you system");
                            }
                            try {
                              if (await Permission.location.isDenied ||
                                  await Permission.location.isDenied) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Please Enable the permission of the Location");
                                await getCurrentLocation();
                              }
                            } catch (e) {
                              Fluttertoast.showToast(
                                  msg:
                                      "There is no camera function in your system");
                            }
                          }

                          // Navigator.pop(context);
                        },
                        text: 'Yes',
                        iconData: Icons.check,
                        color: Colors.red,
                        textStyle: TextStyle(color: Colors.white),
                        iconColor: Colors.white,
                      ),
                    ],
                  );

                  // Close the progress dialog when the task is complete
                },
                child: const Icon(
                  Icons.fingerprint,
                  size: 70.0,
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size(20, 20),
                  // Increase the icon size
                  primary: Colors.blue, // Optional, set the icon color
                  textStyle: TextStyle(fontSize: 60), // Adjust the font size
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                "Tap To Attendance",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> uploadImage(List<int> imageFile) async {
    // print("Image path : ${imageFile.path}");
    // // Replace 'your_api_endpoint' with the actual API endpoint URL
    var formattedDate =
        DateFormat('yyyyMMdd HHmmss').format(DateTime.now()).toString();
    mtoken.token_type;
    mtoken.access_token;
    String filenames = imageFileName;
    final apiUrl = Uri.parse(
        '${urlVariable.token_url}/api/Attendance/InsertCaptcherImage');

    try {
      var request = http.MultipartRequest('POST', apiUrl);
      request.headers["Authorization"] =
          '${mtoken.token_type} ${mtoken.access_token}';
      // Send the request
      var response = await http.MultipartFile.fromBytes('File', imageFile,
          filename: filenames);
      request.files.add(response);
      // print("Image path : ${imageFile.path}");
      var res = await request.send();
      print(res.statusCode);
      // Check the response
      if (res.statusCode == 200) {
        // Fluttertoast.showToast(
        // msg: 'Image uploaded successfully' +
        //     await res.stream.bytesToString());
      } else {
        print(
            'Failed to upload image. Status code: ${formattedDate.toString()}');
        // Fluttertoast.showToast(
        //     msg:
        //         'Failed to upload image. Status code: ${formattedDate.toString()}');
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: 'Error uploading image: $e');
    }
  }

  Future<void> isAttendanceDone(String empCode, Token token, String userName,
      String userRemarks, double? long, double? lati) async {
    print(lati);
    var formattedDate =
        DateFormat('yyyyMMdd HHmmss').format(DateTime.now()).toString();
    print("the employee code for checkin :${empCode}");
    setState(() {
      imageFileName = "${empCode}${formattedDate.toString()}.jpg";
    });
    // final url = Uri.parse(
    //     '${urls.token_url}/api/Attendance/AttendanceEntry/${userName}/${userRemarks}');
    final url = Uri.parse('${urls.token_url}/api/Attendance/PunchTime');
    try {
      final headers2 = {
        'Authorization': '${token.token_type} ${token.access_token}',
      };
      final bodys = {
        "UserID": "${userName}",
        "Latitude": "${lati}",
        "Longtitide": "${long}",
        "locationImage": "${imageFileName}",
        "Remarks": "${userRemarks}",
      };
      final response = await http.post(
        url,
        headers: headers2,
        body: bodys,
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        print(response.body);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  void showProgressDialog(BuildContext context) async {
    // final ProgressDialog progressDialog = ProgressDialog(context: context);
    // progressDialog.show(
    //   max: 100, // Maximum value for the progress indicator
    //   msg: "Loading...", // Message to display
    //   progressBgColor: Colors.transparent, // Background color of the dialog
    //   cancel: Cancel(
    //     cancelClicked: () {
    //       // Handle cancel button click
    //       progressDialog.close();
    //     },
    //   ),
    // );

    // // Simulate a task
    // for (int i = 0; i <= 100; i++) {
    //   progressDialog.update(value: i); // Update progress value
    //   await Future.delayed(Duration(milliseconds: 100));
    // }

    // progressDialog.close(); // Close the progress dialog when the task is done
  }
}

double? lng = 0.0;
double? lat = 0.0;
bool isCancled = false;

final UrlManager urls = UrlManager();

Future<void> getPolicy(String sUserId, Token sToken) async {
  final url =
      Uri.parse('${urls.token_url}/api/Attendance/GetTimePolicy/${sUserId}');
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
      policy_items = info.result;
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Something is wrong");
  }
}

Future<void> getCurrentLocation() async {
  Location loc = Location();
  try {
    LocationData locationdata = await loc.getLocation();
    lat = locationdata.latitude;
    lng = locationdata.longitude;
    print(lat);
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}

Future<void> getCameraPermission() async {
  // TODO: this is where it will check weather i have camera permission
  var status = await Permission.camera.status;
  var status2 = await Permission.microphone.status;
  if ((status.isDenied || status.isPermanentlyDenied) &&
      (status2.isDenied || status2.isPermanentlyDenied)) {
    await Permission.camera.request();
    await Permission.microphone.request();
  }
}

Future<void> getReasonList(Token token) async {
  // final url = Uri.parse(
  //     '${urls.token_url}/api/Attendance/AttendanceEntry/${userName}/${userRemarks}');
  final url = Uri.parse('${urls.token_url}/api/Attendance/LateReason');
  try {
    final headers2 = {
      'Authorization': '${token.token_type} ${token.access_token}',
    };
    final response = await http.get(url, headers: headers2);
    final resonData = await jsonDecode(response.body);

    if (response.statusCode == 200) {
      ReasonList reasonList = await ReasonList.fromJson(resonData);
      sugests = reasonList.result;
      sugests[0].resonName;
      DateTime currentTime = DateTime.now();

      // Create a DateTime object for "9:00 AM" today
      DateTime targetTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        9,
        0,
      );

      // Add an additional duration, for example, 30 minutes
      Duration additionalDuration = Duration(minutes: 30);
      DateTime adjustedTargetTime = targetTime.add(additionalDuration);

      // Check if the current time is equal to or after the adjusted target time
      bool isAfterOrEqual = currentTime.isAfter(adjustedTargetTime);
      if (isAfterOrEqual) {
        for (var i = 0; i < sugests.length; i++) {
          items.add(sugests[i].resonName);
        }
      } else {
        Fluttertoast.showToast(msg: "Your In Right Time");
      }
    } else {
      Fluttertoast.showToast(msg: "There is problem in the server");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}
