import 'package:emerge_alert_dialog/emerge_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MyDataRow extends DataTableSource {
  MyDataRow({required this.fildata, required this.mcontext});
  List<dynamic> fildata;
  BuildContext mcontext;

  @override
  DataRow? getRow(int index) {
    // TODO: implement getRow
    return DataRow(
      cells: <DataCell>[
        DataCell(
          Text(DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(fildata[index].date))),
        ),
        DataCell(
          Text(fildata[index].time),
        ),
        DataCell(
          GestureDetector(
            child: Image.asset('images/assets/location.png'),
            onTap: () async {
              if (fildata[index].latitude.isNotEmpty &&
                  fildata[index].longtitide.isNotEmpty) {
                var latitude = double.parse(fildata[index].latitude);
                var longitude = double.parse(fildata[index].longtitide);
                MapsLauncher.launchCoordinates(
                    latitude, longitude, 'Location Coordinates');
              } else {
                print('Latitude or longitude is empty');
                _showMyDialog(mcontext);

                // Handle the case where latitude or longitude is empty
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => fildata.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
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
