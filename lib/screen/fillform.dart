import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

var items = [
  "Annual Leave",
  "Sick Leave",
];

final TextEditingController startDateSelected = TextEditingController();
final TextEditingController endDateSelected = TextEditingController();
final TextEditingController totalDateLeft = TextEditingController();

class FillForm extends StatelessWidget {
  const FillForm({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              color: const Color.fromARGB(255, 255, 255, 255),
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: const Text("New Leave Form"),
        ),
        body: InteractiveViewer(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        ),
      ),
    );
  }
}
