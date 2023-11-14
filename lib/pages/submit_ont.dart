import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

class SubmitONT extends StatefulWidget {
  num woId = 0;
  SubmitONT({Key? key, required this.woId}) : super(key: key);

  @override
  State<SubmitONT> createState() => _SubmitONTState();
}

class _SubmitONTState extends State<SubmitONT> {
  num woId = 0;
  String ontSn = 'N/A';
  var response;
  Stream<dynamic>? bc;
  var txt = TextEditingController();

  @override
  void initState() {
    woId = widget.woId;
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
      child: SizedBox(
        height: 186,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            ListTile(
              title: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter or scan serial number',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    iconSize: 20,
                    color: Colors.indigo,
                    tooltip: 'Scan serial number barcode',
                    onPressed: () async {
                      ontSn = await CameraUtils.getScanRes();

                      setState(() {
                        ontSn = ontSn;
                        txt.text = ontSn;
                      });
                    },
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                controller: txt,
              ),
              subtitle: const Padding(
                padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
                child: Text("Note: When using the camera to scan, cover other barcodes to ensure accuracy."),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (txt.text == '' ||
                    txt.text == '-1' ||
                    txt.text.contains(' ')) {
                  alertMessage(context, 'Invalid input');
                  return;
                }
                showLoaderDialog(context);
                response = await WorkOrderApi.activateOnt(woId, txt.text);

                if (mounted) {
                  if (response.containsKey('success')) {
                    setState(() {
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        // behavior: SnackBarBehavior.floating,
                        content: Row(
                          children: [
                            Text('ONT Activated'),
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(milliseconds: 6000),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Expanded(
                                child:
                                Text(response['error'] ?? "Unknown error")),
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 10),
                      ),
                    );
                  }
                  await Future.delayed(const Duration(seconds: 5));
                  if(mounted){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => ShowServiceOrder(orderID: woId),
                      ),
                          (route) => route.isFirst,
                      // ModalRoute.of(context, ),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = const AlertDialog(
      contentPadding: EdgeInsets.all(8),
      content: ListTile(
        leading: CircularProgressIndicator(),
        title: Text("Activating ONT..."),
        subtitle: Text("This might take a while"),
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
