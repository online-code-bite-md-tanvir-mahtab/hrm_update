import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hrm_attendance_application_test/screen/homescreen.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:io';

final TextEditingController _my_id = TextEditingController();
dynamic bytes;

class SumarryPdfView extends StatefulWidget {
  const SumarryPdfView(
      {super.key,
      required this.uId,
      required this.sToken,
      required this.uFrom,
      required this.uTo});
  final String uId;
  final Token sToken;
  final String uFrom;
  final String uTo;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SumarryPdfView(uId, sToken, uFrom, uTo);
  }
}

class _SumarryPdfView extends State<SumarryPdfView> {
  String mUId;
  Token mToken;
  String mFromDate;
  String mToDate;
  _SumarryPdfView(this.mUId, this.mToken, this.mFromDate, this.mToDate);
  String pdfPath = '';
  bool isDownloading = false;
  String pdfUrl = '';
  @override
  void initState() {
    super.initState();
    fetchAndDisplayPdf(mUId, mToken, mFromDate, mToDate);
  }

  UrlManager urls = UrlManager();
  Future<void> fetchAndDisplayPdf(
      String user_id, Token token, String from_date, String to_date) async {
    String _id = 'dev-1016';
    user_id = user_id.replaceAll(' ', '');
    print(user_id.toString().toLowerCase());
    from_date = from_date.replaceAll('-', '');
    to_date = to_date.replaceAll('-', '');
    if (userInfo.result.isAdmin == "True") {
      setState(() {
        pdfUrl =
            '${urls.token_url}/api/Attendance/ReportAttendanceSummeryAll/${from_date}/${to_date}';
      });
    } else {
      setState(() {
        pdfUrl =
            '${urls.token_url}/api/Attendance/ReportAttendanceSummeryByEmployee/${user_id}/${from_date}/${to_date}';
      });
    }

    String authToken = '${token.token_type} ${token.access_token}';

    try {
      http.Response response = await http.get(
        Uri.parse(pdfUrl),
        headers: {'Authorization': authToken},
      );

      if (response.statusCode == 200) {
        // Save the PDF content to a temporary file
        pdfPath = await _saveFile(response.bodyBytes);

        setState(() {
          bytes = response.bodyBytes;
        });
      } else {
        print('API request failed with status ${response.statusCode}');
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('${response.statusCode}')));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> _saveFile(var bytes) async {
    final DefaultCacheManager cacheManager = DefaultCacheManager();
    final fileInfo =
        await cacheManager.putFile('pdf_key', bytes); // Provide a unique key
    return fileInfo.path;
  }

  Future<String?> chooseDownloadFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null && result.toString().isNotEmpty) {
      return result;
    } else {
      return null;
    }
  }

  Future<void> _downloadPdf() async {
    setState(() {
      isDownloading = true;
    });

    try {
      String? appDocDir = await chooseDownloadFolder();
      if (appDocDir != null) {
        final String downloadPath = '$appDocDir/downloaded.pdf';

        File file = File(downloadPath);
        if (bytes != null) {
          file.writeAsBytes(bytes);

          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("File is Downloaded in $downloadPath")),
            );
        } else {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("No Data")),
            );
        }
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text("Download folder not selected")),
          );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Pdf Report'),
      ),
      body: pdfPath.isNotEmpty
          ? PDFView(
              filePath: pdfPath,
            )
          : Center(
              child: Container(
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.black,
                    size: 100,
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: isDownloading ? null : _downloadPdf,
        child: isDownloading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Icon(Icons.download),
      ),
    );
  }
}
