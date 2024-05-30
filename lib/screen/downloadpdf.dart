import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hrm_attendance_application_test/util/token.dart';
import 'package:hrm_attendance_application_test/util/url_variable.dart';

import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

dynamic bytes;

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({super.key, required this.uId, required this.sToken});
  final String uId;
  final Token sToken;

  @override
  _PdfPreviewPageState createState() => _PdfPreviewPageState(uId, sToken);
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  String mUId;
  Token mToken;
  _PdfPreviewPageState(this.mUId, this.mToken);
  String pdfPath = '';
  bool isDownloading = false;
  @override
  void initState() {
    super.initState();
    fetchAndDisplayPdf(mUId, mToken);
  }

  UrlManager urls = UrlManager();
  Future<void> fetchAndDisplayPdf(String id, Token token) async {
    // String id = '1_45';
    print(id);
    String pdfUrl = '${urls.token_url}/api/Leave/LeaveBalanceReport/${id}';
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
        final String downloadPath = '$appDocDir/report.pdf';

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
// // Create the directory if it doesn't exist
  // if (!(await Directory(appDocDir).exists())) {
  //   await Directory(downloadDirectoryPath).create(recursive: true);
  //   ScaffoldMessenger.of(context)
  //     ..clearSnackBars()
  //     ..showSnackBar(SnackBar(
  //         content: Text(
  //             'The file doesn"t exist so created on path: $downloadDirectoryPath')));
  // } else {
  //   final File pdfFile = File(downloadPath);
  //   await pdfFile.writeAsBytes(await fileInfo!.file.readAsBytes());

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('PDF downloaded')),
  //   );
  // }
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
