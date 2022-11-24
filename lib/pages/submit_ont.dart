import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/show_order.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';


class SubmitONT extends StatefulWidget {
  num ontId = 0, woId = 0;
  SubmitONT({Key? key, required this.ontId, required this.woId}) : super(key: key);

  @override
  State<SubmitONT> createState() => _SubmitONTState();
}

class _SubmitONTState extends State<SubmitONT> {
  num ontId = 0;
  num woId = 0;
  String ontSn = 'N/A';
  var response;
  Stream<dynamic>? bc;
  var txt = TextEditingController();

  @override
  void initState(){
    ontId = widget.ontId;
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
                  hintText: 'Enter ONT Serial Number',
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
                  if(txt.text == '' || txt.text == '-1' || txt.text.contains(' ')){
                    alertMessage(context, 'Invalid input');
                    return;
                  }
                  showLoaderDialog(context);
                  response = await WorkOrderApi.submitOnt(ontId,txt.text);
                  if(mounted){}

                  if((response['code']) == 1){
                    // Navigator.pushReplacement<void, void>(
                    //   context,
                    //   MaterialPageRoute<void>(
                    //     builder: (BuildContext context) =>  ShowOrder(orderID: woId,),
                    //   ),
                    // );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Row(
                          children: const [
                            Text('Serial Number Submitted'),
                            Icon(
                                Icons.check_circle,
                                color: Colors.white,
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(milliseconds: 2000),
                      ),
                    );
                    Navigator.popUntil(context, ModalRoute.withName('/show'));
                    Navigator.pushReplacement<void, void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>  ShowOrder(orderID: woId,),
                      ),
                    );
                  }
                },
                child: const Text('Submit ONT SN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getScanRes() async{
    ontSn = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE);

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


