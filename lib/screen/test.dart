import 'dart:convert';
import 'dart:io';

// import 'package:intl/intl.dart';
// import 'package:camera/camera.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() async {
  final url = Uri.parse('http://103.231.239.122:8018/token');
  final heads = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  final bod = {
    'grant_type': 'password',
    'username': 'dev-1016',
    'password': '123456',
  };
  try {
    dynamic response = await http
        .post(
          url,
          headers: heads,
          body: bod,
        )
        .timeout(Duration(seconds: 10));
    // response.persistentConnection = false;
    print(response.statusCode);
    if (response.statusCode.toInt() == 200) {
      final data = jsonDecode(response.body);
      Token object = Token.fromJson(data);
      print(object.expired_time);
    } else {}
  } catch (e) {
    print("The login error: " + e.toString());
    // Error handling for exceptions
  }
}

Future<void> getAttendanceInfo(String dUserLogId) async {
  // geting the current day
  DateTime today = DateTime.now();

  String current_month = DateFormat('yyyyMM').format(today);
  final url = Uri.parse(
      "http://103.231.239.122:8018/api/Attendance/CheckInDetails/${dUserLogId.replaceAll(' ', '')}/${current_month}01/${current_month}30");

  final header = {
    'Authorization':
        'bearer kgl5vVQcJjVYkWoKykriG32d4K8p1UAd5h0ell40XEthxwql338HleFEqfD0JMTwm_latX1m8LGBqwB0_cLFDuy1_oYPGVd0MLevibFl0gWjsM9F4DsWhRaRCCWRSPUv2XHZreo1CNb0hkQ5lNajt52CVSiuWebvupFNVem9wZc2GJp8vltrDt5TlNAG4i4D5bJrC7JdNNcCfpL_8W8rBA'
  };
  // use the try catch block to hendle anykind error
  try {
    final response = await http.get(url, headers: header);
    // print(response.body);
    if (response.statusCode == 200) {
      final attendanceData = jsonDecode(response.body);

      print(attendanceData);
    } else {
      print("something is worng");
    }
  } catch (e) {}
}

Future<void> uploadImage(List<int> imageFile) async {
  // print("Image path : ${imageFile.path}");
  // // Replace 'your_api_endpoint' with the actual API endpoint URL
  var formattedDate =
      DateFormat('yyyyMMdd HHmmss').format(DateTime.now()).toString();
  // mtoken.token_type;
  // mtoken.access_token;
  String filenames = "imageFileName";
  final apiUrl = Uri.parse(
      'http://103.231.239.122:8018/api/Attendance/InsertCaptcherImage');

  try {
    var request = http.MultipartRequest('POST', apiUrl);
    request.headers["Authorization"] =
        'bearer 7KJd4SFHCXNTMtftaLh4x_XN3L5UcOklIvuZubieoKVQXx0yPMhv31yadXezkRMA4TGInDlj3i8rP8ABZLvnKZYR1DRSGmvBaDNMuYGwEpNuVVzrJYBturbEvyT-Hh8dCTF9d9RIYsADwi28EKPeB361jsuRmt4fhBm3ORfSxWMdEHrmCZRD2LQrvR1DTu54aoZtBpkDlrLwY6akAu7yYmXV-gRAdHiDEQzkWRL88qA';
    // Send the request
    var response = await http.MultipartFile.fromBytes('picture', imageFile,
        filename: filenames);
    request.files.add(response);
    // print("Image path : ${imageFile.path}");
    var res = await request.send();
    print(res.statusCode);
    // Check the response
    if (res.statusCode == 200) {
      // Fluttertoast.showToast(
      // msg:
      //     'Image uploaded successfully' + await res.stream.bytesToString());
    } else {
      print('Failed to upload image. Status code: ${formattedDate.toString()}');
      // Fluttertoast.showToast(
      // msg:
      //     'Failed to upload image. Status code: ${formattedDate.toString()}');
    }
  } catch (e) {
    // Fluttertoast.showToast(msg: 'Error uploading image: $e');
  }
}
