import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/pages/submit_ont.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/widgets/attachment_widget.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

class ShowOrder extends StatefulWidget {
  final num orderID;
  const ShowOrder({Key? key, required this.orderID}) : super(key: key);

  @override
  State<ShowOrder> createState() => _ShowOrderState();
}

class _ShowOrderState extends State<ShowOrder> {
  num orderID = 0;
  bool ontSubmitted = false;
  Stream<dynamic>? bc;
  List<String> listImage = [];
  var txt = TextEditingController();

  @override
  void initState() {
    loadingScreen(context);
    getAsync(widget.orderID);
    super.initState();
  }

  void refresh(List<String> img) async {
      listImage = img;
      setState((){});
  }

  WorkOrder wo = WorkOrder(
    woId: 0,
    soId: 0,
    woName: 'Loading...',
    status: 'Loading..',
    requestedBy: 'Loading...',
    address: 'Loading...',
    custContact: 'Loading...',
    carrier: 'Loading...',
    speed: 'Loading...',
  );

  late SharedPreferences prefs;

  getAsync(num id) async {
    try {
      prefs = await SharedPreferences.getInstance();
      wo = await WorkOrderApi.getWorkOrder(id);
      listImage = wo.img ?? [];
      if ((wo.ontSn != null && !wo.ontSn.toString().contains(' '))) {
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
    final imageList = ImageNotifier(wo.img ?? ['']);

    return Scaffold(
      appBar: AppBar(
        title: Text(wo.woName),
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
                      soId: wo.soId,
                    );
                  },
                ),
              },
              label: const Text('Activate ONT'),
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
                      wo.status,
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      wo.date ?? 'N/A',
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      wo.time ?? 'N/A',
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      wo.requestedBy,
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      wo.lat != 0
                          ? MapUtils.openMap(wo.lat, wo.lng)
                          : (wo.address == ''
                              ? alertMessage(context, 'Empty address')
                              : mapPromptDialog(context, wo.address));
                    },
                    child: ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(
                        wo.address,
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
                    title: Text(
                      wo.carrier,
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.signal_cellular_alt),
                    title: Text(
                      wo.speed,
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
                          ? wo.ontSn.toString()
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
            Container(
              width: 160.0,
              child: Center(
                child: ListTile(
                  title: const Icon(
                    Icons.add_circle_outline,
                    size: 45,
                  ),
                  subtitle: const Text(
                    'Add image',
                    textAlign: TextAlign.center,
                  ),
                  onTap: () async {
                    imagePickerPrompt(context, 'ontsn', wo.woId, refresh);
                    // final XFile? image = await ImagePicker()
                    //     .pickImage(source: ImageSource.gallery);
                  },
                ),
              ),
            ),
            wo.img == null ? const Divider() : newInstallationAttachments(context, wo.woId, listImage, refresh),
            // wo.woId != 0 ? Attachments(woId: wo.woId, urlImages: wo.img ?? []) : const Divider(),
            // FutureBuilder(
            //     future: WorkOrderApi.getImgAttachments(wo.woId),
            //     builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            //       return Attachments(woId: wo.woId, urlImages: wo.img ?? []);
            // })
          ],
        ),
      ),
    );
  }

  textStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black87);
  }
}

class ImageNotifier with ChangeNotifier {
  List<String> _img;

  ImageNotifier(this._img);
  List<String> get img => _img;

  void updateList(num id) async {
    _img = await WorkOrderApi.getImgAttachments(id);
    notifyListeners();
  }
}
