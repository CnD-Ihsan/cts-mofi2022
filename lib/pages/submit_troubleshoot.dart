import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

class SubmitTroubleshoot extends StatefulWidget {
  num ttId = 0;
  SubmitTroubleshoot({super.key, required this.ttId});

  @override
  State<SubmitTroubleshoot> createState() => _SubmitTroubleshootState();
}

class _SubmitTroubleshootState extends State<SubmitTroubleshoot> {
  num woId = 0;
  String ontSn = 'N/A';
  var response;
  Stream<dynamic>? bc;
  var txt = TextEditingController();

  @override
  void initState() {
    woId = widget.ttId;
    super.initState();
  }

  @override
  void dispose() {
    txt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 160,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ListTile(
              title: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter or scan serial number',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    iconSize: 20,
                    color: Colors.brown,
                    tooltip: 'Scan serial number barcode',
                    onPressed: () {
                      getScanRes();
                    },
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                controller: txt,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (txt.text == '' ||
                      txt.text == '-1' ||
                      txt.text.contains(' ')) {
                    alertMessage(context, 'Invalid input');
                    return;
                  }
                  showLoaderDialog(context);
                  response = await WorkOrderApi.activateOnt(woId, txt.text);
                  if (mounted) {}
                  if (response.containsKey('data')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        // behavior: SnackBarBehavior.floating,
                        content: Row(
                          children: const [
                            Text('ONT Activated'),
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(milliseconds: 3000),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Expanded(
                                child:
                                    Text('Error: ${response['errorMessage']}')),
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(milliseconds: 3000),
                      ),
                    );
                  }
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => ShowServiceOrder(orderID: woId),
                    ),
                    (route) => route.isFirst,
                    // ModalRoute.of(context, ),
                  );
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getScanRes() async {
    ontSn = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.BARCODE);

    setState(() {
      ontSn = ontSn;
      txt.text = ontSn;
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Submitting...")),
        ],
      ),
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
