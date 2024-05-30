import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

dynamic bytes;

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key, required this.pdfId, required this.token});
  final String pdfId;
  final Token token;
  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState(pdfId, token);
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String pdfPath = '';
  String pdf_id;
  Token sToken;
  _PdfViewerScreenState(this.pdf_id, this.sToken);
  bool isDownloading = false;
  @override
  void initState() {
    super.initState();
    fetchAndDisplayPdf(pdf_id, sToken);
  }

  UrlManager urls = UrlManager();
  Future<void> fetchAndDisplayPdf(String pdfid, Token zToken) async {
    String pdfUrl = '${urls.token_url}/api/Leave/LeaveApplication/${pdfid}';
    String access_type = zToken.token_type.toString();
    String access_token = zToken.access_token.toString();
    String authToken = '${access_type} ${access_token}';
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
      }
    } catch (e) {
      print('Error: $e');
    }
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
        final String downloadPath = '$appDocDir/new_leave_application.pdf';

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

  Future<String> _saveFile(var bytes) async {
    final DefaultCacheManager cacheManager = DefaultCacheManager();
    final fileInfo =
        await cacheManager.putFile('pdf_key', bytes); // Provide a unique key
    return fileInfo.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: pdfPath.isNotEmpty
          ? PDFView(
              filePath: pdfPath,
            )
          : Center(
              child: CircularProgressIndicator(),
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
