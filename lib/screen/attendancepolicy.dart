import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AttendancePolicy extends StatelessWidget {
  const AttendancePolicy({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context, 'ok');
              },
            ),
            title: const Text('Policy'),
          ),
          body: InteractiveViewer(child: PolicyBody()),
        ),
      ),
    );
  }
}

class PolicyBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PolicyBody();
  }
}

class _PolicyBody extends State<PolicyBody> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 10.0,
          ),
          Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              policy_info(
                label: "In Time",
                msg: "9:00",
                icon: Icon(FontAwesomeIcons.userCheck,
                    size: 18, color: Colors.blueAccent //Color Of Icon
                    ),
              ),
              SizedBox(
                height: 10.0,
              ),
              policy_info(
                label: "Out Time",
                msg: "6:00",
                icon: Icon(FontAwesomeIcons.userCheck,
                    size: 18, color: Colors.blueAccent //Color Of Icon
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget policy_info(
    {required String label, required String msg, required Icon icon}) {
  return Container(
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: 15.0,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Container(
          // width: 350.0,
          margin: EdgeInsets.only(left: 15.0, right: 15.0),
          color: const Color.fromARGB(255, 236, 232, 232),
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              icon,
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: Text(
                  msg,
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
