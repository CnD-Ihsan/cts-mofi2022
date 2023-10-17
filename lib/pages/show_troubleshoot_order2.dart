import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/models/tt_model.dart';
import 'package:wfm/pages/submit_ont.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

class ShowTroubleshootOrder extends StatefulWidget {
  final num orderID;
  const ShowTroubleshootOrder({Key? key, required this.orderID}) : super(key: key);

  @override
  State<ShowTroubleshootOrder> createState() => _ShowTroubleshootOrderState();
}

class _ShowTroubleshootOrderState extends State<ShowTroubleshootOrder> {
  num orderID = 0;
  bool ontSubmitted = false;
  Stream<dynamic>? bc;
  var txt = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  Container(
                      margin: const EdgeInsets.only(left: 7),
                      child: const Text("Loading...")),
                ],
              ),
            );
          });
    });
    getAsync(widget.orderID);
    super.initState();
  }

  TroubleshootOrder tt = TroubleshootOrder(
    ttId: 0,
    ttNo: 'Loading...',
    isp: 'Loading...',
    status: 'Loading..',
    description: 'Loading...',
    address: 'Loading...',
    custContact: 'Loading...',
    speed: 'Loading...',
  );

  late SharedPreferences prefs;

  getAsync(num id) async {
    try {
      prefs = await SharedPreferences.getInstance();
      tt = (await WorkOrderApi.getTroubleshootOrder(id));
      if ((tt.ontSn != null && !tt.ontSn.toString().contains(' '))) {
        ontSubmitted = true;
      }
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tt.ttNo),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.maps_home_work),
        //     onPressed: () {
        //       MapUtils.openMap(wo.lat, wo.lng);
        //     },
        //   ),
        //   // add more IconButton
        // ],
      ),
      floatingActionButton: ontSubmitted
          ? null
          : FloatingActionButton.extended(
              onPressed: () => {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    // Returning SizedBox instead of a Container
                    return SubmitONT(
                      woId: widget.orderID,
                    );
                  },
                ),
              },
              label: const Text('Submit ONT SN'),
              icon: const Icon(Icons.camera),
            ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            const ListTile(
              title: Text(
                'Work Order Details',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.question_mark),
                    title: Text(
                      tt.status,
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      tt.date ?? 'N/A',
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      tt.time ?? 'N/A',
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    // leading: const Text(
                    //   'Requested By:',
                    //   style: TextStyle(fontSize: 18),
                    //   textAlign: TextAlign.start,
                    // ),
                    title: Text(
                      tt.description,
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      tt.lat != 0
                          ? MapUtils.openMap(tt.lat, tt.lng)
                          : (tt.address == ''
                              ? alertMessage(context, 'Empty address')
                              : mapPromptDialog(context, tt.address));
                    },
                    child: ListTile(
                      leading: const Icon(Icons.home),
                      // leading: const Text(
                      //   'Requested By:',
                      //   style: TextStyle(fontSize: 18),
                      //   textAlign: TextAlign.start,
                      // ),
                      title: Text(
                        tt.address,
                        style: textStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            const ListTile(
              title: Text(
                'ONT Details',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.broadcast_on_personal_outlined),
                    // leading: const Text(
                    //   'Requested By:',
                    //   style: TextStyle(fontSize: 18),
                    //   textAlign: TextAlign.start,
                    // ),
                    title: Text(
                      tt.isp,
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.signal_cellular_alt),
                    // leading: const Text(
                    //   'Requested By:',
                    //   style: TextStyle(fontSize: 18),
                    //   textAlign: TextAlign.start,
                    // ),
                    title: Text(
                      tt.speed ?? "-",
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Text(
                      'ONT',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                    title: Text(
                      ontSubmitted
                          ? tt.ontSn.toString()
                          : 'N/A (Action Needed)',
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  // SubmitONT(
                  //   ontID: wo.ontActId,
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            const ListTile(
              title: Text(
                'Attachments',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.broadcast_on_personal_outlined),
                    // leading: const Text(
                    //   'Requested By:',
                    //   style: TextStyle(fontSize: 18),
                    //   textAlign: TextAlign.start,
                    // ),
                    title: Text(
                      tt.isp,
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.signal_cellular_alt),
                    // leading: const Text(
                    //   'Requested By:',
                    //   style: TextStyle(fontSize: 18),
                    //   textAlign: TextAlign.start,
                    // ),
                    title: Text(
                      tt.speed ?? "-",
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Text(
                      'ONT',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                    title: Text(
                      ontSubmitted
                          ? tt.ontSn.toString()
                          : 'N/A (Action Needed)',
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  // SubmitONT(
                  //   ontID: wo.ontActId,
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  textStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black87);
  }

  alertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: const Text('Map Coordinate Error.'),
      actions: <Widget>[
        TextButton(
          child: const Center(child: Text('Confirm')),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
