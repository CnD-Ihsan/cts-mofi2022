import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/models/tt_model.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/return_order.dart';
import 'package:wfm/pages/submit_ont.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/widgets/attachment_widget.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShowTroubleshootOrder extends StatefulWidget {
  final num orderID;
  const ShowTroubleshootOrder({Key? key, required this.orderID})
      : super(key: key);

  @override
  State<ShowTroubleshootOrder> createState() => _ShowTroubleshootOrderState();
}

class _ShowTroubleshootOrderState extends State<ShowTroubleshootOrder> {
  num orderID = 0;
  String? currentProgress;
  Stream<dynamic>? bc;
  Map listImage = {};
  Map requestVerification = {};
  final GlobalKey _scrollTroubleshootAttachmentKey = GlobalKey();
  final GlobalKey _scrollTroubleshootKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _rootCause = TextEditingController();
  final TextEditingController _subCause = TextEditingController();
  final TextEditingController _faultLocation = TextEditingController();
  final TextEditingController _actionTaken = TextEditingController();

  @override
  void initState() {
    loadingScreen(context);
    getAsync(widget.orderID, true);
    super.initState();
  }

  @override
  void dispose() {
    _rootCause.dispose();
    _subCause.dispose();
    _faultLocation.dispose();
    _actionTaken.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void refresh(Map img, String action) async {
    await getAsync(widget.orderID, false);
    if (mounted) {}
    if (action == 'delete') {
      snackbarMessage(context, 'Image attachment deleted.');
      Navigator.pop(context);
    } else {
      snackbarMessage(context, 'Image uploaded');
    }
    listImage = img;
    updateActionButton();
  }

  FloatingActionButton? currentButton(String? progress) {
    if (progress == 'completion') {
      return FloatingActionButton.extended(
        onPressed: () async => {
          // alertMessage(context, 'Submit order completion?'),
          requestVerification = await WorkOrderApi.ttCompleteOrder(
              tt.ttId,
              _rootCause.value.text,
              _subCause.value.text,
              _faultLocation.value.text,
              _actionTaken.value.text),
          if (!requestVerification.containsKey('error'))
            {
              snackbarMessage(context, 'Verification request submitted!'),
              setState(() {})
            }
          else
            {
              colorSnackbarMessage(context,
                  'Request error! ${requestVerification['error']}', Colors.red)
            }
        },
        label: const Text('Complete Order'),
        icon: const Icon(Icons.check_circle),
      );
    } else {
      return null;
    }
  }

  TroubleshootOrder tt = TroubleshootOrder(
    ttId: 0,
    ttNo: 'Loading...',
    status: 'Loading...',
    isp: 'Loading...',
    description: 'Loading...',
    address: 'Loading...',
    custContact: 'Loading...',
    carrier: 'Loading...',
    speed: 'Loading...',
  );

  late SharedPreferences prefs;

  getAsync(num id, bool needPop) async {
    try {
      prefs = await SharedPreferences.getInstance();
      tt = await WorkOrderApi.getTroubleshootOrder(id);
      listImage = tt.img;
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
      if (needPop) {
        Navigator.pop(context);
      }
      if (tt.ttId == 0) {
        colorSnackbarMessage(
            context,
            'Failed to get work order details! Contact admin if issue persists.',
            Colors.red);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WorkOrders(
                    user: prefs.getString('user') ?? 'Unauthorized',
                    email: prefs.getString('email') ?? 'Unauthorized',
                  )),
        );
      }
    }
  }

  updateActionButton() {
    if (_rootCause.value.text.isNotEmpty &&
        _actionTaken.value.text.isNotEmpty) {
      tt.progress = 'attachment';
      if (listImage['sign'] != null && listImage['speedtest'] != null) {
        tt.progress = 'completion';
      }
    } else {
      tt.progress = 'troubleshooting';
    }

    setState(() {});
  }

  MaterialColor themeColor = Colors.indigo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Troubleshoot Order"),
        actions: tt.status != 'Pending' || tt.progress == 'close_requested'
            ? null
            : [
                Builder(builder: (context) {
                  return PopupMenuButton(
                    icon: const Icon(Icons.menu),
                    position: PopupMenuPosition.under,
                    // color: themeColor,
                    tooltip: "Order Actions",
                    constraints: const BoxConstraints(),
                    // onSelected: (newValue) { // add this property
                    //   setState(() {
                    //     // _value = newValue; // it gives the value which is selected
                    //   });
                    // },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        height: 30,
                        value: 0,
                        onTap: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 10));
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ReturnOrder(
                                        woId: widget.orderID,
                                        ftthId: tt.ttId,
                                        type: "TT",
                                        refresh: refresh,
                                      )),
                            );
                          }
                        },
                        child: const Text(
                          "Return Order",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                })
              ],
      ),
      floatingActionButton: currentButton(tt.progress),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              tt.status != 'Returned' || tt.status != 'Cancelled'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Troubleshooting',
                              style: TextStyle(fontSize: 12, color: themeColor),
                              textAlign: TextAlign.start,
                            ),
                            tt.progress == 'troubleshooting'
                                ? FaIcon(
                                    FontAwesomeIcons.circleHalfStroke,
                                    color: themeColor,
                                  )
                                : FaIcon(
                                    FontAwesomeIcons.solidCircleCheck,
                                    color: themeColor,
                                  )
                          ],
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: tt.progress == 'troubleshooting'
                              ? Colors.black
                              : themeColor,
                        ),
                        Column(
                          children: [
                            Text(
                              'Attachment',
                              style: TextStyle(
                                fontSize: 12,
                                color: tt.progress == 'troubleshooting'
                                    ? Colors.black
                                    : themeColor,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            tt.progress == 'attachment'
                                ? FaIcon(
                                    FontAwesomeIcons.circleHalfStroke,
                                    color: themeColor,
                                  )
                                : tt.progress == 'troubleshooting'
                                    ? const FaIcon(
                                        FontAwesomeIcons.circle,
                                        color: Colors.black,
                                      )
                                    : FaIcon(
                                        FontAwesomeIcons.solidCircleCheck,
                                        color: themeColor,
                                      )
                          ],
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: tt.progress == 'troubleshooting' ||
                                  tt.progress == 'attachment'
                              ? Colors.black
                              : themeColor,
                        ),
                        Column(
                          children: [
                            Text(
                              'Completion',
                              style: TextStyle(
                                fontSize: 12,
                                color: tt.progress == 'troubleshooting' ||
                                        tt.progress == 'attachment'
                                    ? Colors.black
                                    : themeColor,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            tt.progress == 'completion' ||
                                    tt.progress == 'close_requested'
                                ? FaIcon(
                                    FontAwesomeIcons.circleHalfStroke,
                                    color: themeColor,
                                  )
                                : tt.progress == 'troubleshooting' ||
                                        tt.progress == 'attachment'
                                    ? const FaIcon(
                                        FontAwesomeIcons.circle,
                                        color: Colors.black,
                                      )
                                    : FaIcon(
                                        FontAwesomeIcons.solidCircleCheck,
                                        color: themeColor,
                                      )
                          ],
                        ),
                      ],
                    )
                  : const Divider(),
              const ListTile(
                title: Text(
                  'Order Details',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.tag),
                      title: Text(
                        tt.ttNo,
                        style: textFieldStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.question_mark),
                      title: Text(
                        tt.status +
                            (tt.progress == 'close_requested'
                                ? ' (Close Requested)'
                                : ''),
                        style: textFieldStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: Text(
                        tt.date ?? 'N/A',
                        style: textFieldStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        tt.time ?? 'N/A',
                        style: textFieldStyle(),
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
                        title: Text(
                          tt.address,
                          style: textFieldStyle(),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(
                        tt.description,
                        style: textFieldStyle(),
                        textAlign: TextAlign.justify,
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
                  'Customer Details',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.broadcast_on_personal_outlined),
                      title: Text(
                        tt.isp,
                        style: textFieldStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.signal_cellular_alt),
                      title: Text(
                        '${tt.speed} Mbps',
                        style: textFieldStyle(),
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
                        tt.progress != 'activation'
                            ? tt.ontSn.toString()
                            : 'Not Activated',
                        style: textFieldStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      key: _scrollTroubleshootKey,
                    ),
                    ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          tt.custName,
                          style: textFieldStyle(),
                          textAlign: TextAlign.start,
                        ),
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            InkWell(
                              onTap: () async {
                                phonePromptDialog(context, tt.custContact);
                              },
                              child: const Icon(
                                Icons.phone,
                                color: Colors.indigo,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                whatsappPromptDialog(context, tt.custContact);
                              },
                              child: const FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
              tt.status != 'Returned' && tt.status != 'Cancelled' ? Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Troubleshooting Details',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tt.progress == 'close_requested' || tt.progress == null || tt.status == 'Completed'
                          ? [
                        ListTile(
                          title: const Text("Root Cause"),
                          subtitle: Text(tt.rootCause ?? "-"),
                          style: ListTileStyle.list,
                        ),
                        ListTile(
                            title: const Text("Sub Cause"),
                            subtitle: Text(tt.subCause ?? "-")
                        ),
                        ListTile(
                            title: const Text("Fault Location"),
                            subtitle: Text(tt.faultLocation ?? "-")
                        ),
                        ListTile(
                            title: const Text("Action Taken"),
                            subtitle: Text(tt.actionTaken ?? "-")
                        ),
                        SizedBox(
                          key: _scrollTroubleshootAttachmentKey,
                          height: 20,
                        ),
                      ]
                          : [
                        ListTile(
                          title: const Text("Root Cause *"),
                          subtitle: TextField(
                            controller: _rootCause,
                            onChanged: (rootCause) => {updateActionButton()},
                            style: textFieldStyle(),
                            textAlign: TextAlign.start,
                            decoration: textFieldDeco("Enter root cause"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          title: const Text("Sub Cause"),
                          subtitle: TextField(
                            controller: _subCause,
                            style: textFieldStyle(),
                            textAlign: TextAlign.start,
                            decoration: textFieldDeco("Enter sub cause"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          title: const Text("Fault Location"),
                          subtitle: TextField(
                            controller: _faultLocation,
                            style: textFieldStyle(),
                            textAlign: TextAlign.start,
                            decoration: textFieldDeco("Enter fault location"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          title: const Text("Action Taken *"),
                          subtitle: TextField(
                            controller: _actionTaken,
                            onChanged: (actionTaken) => {updateActionButton()},
                            style: textFieldStyle(),
                            textAlign: TextAlign.start,
                            decoration: textFieldDeco(
                                "Enter actions taken to troubleshoot"),
                            maxLines: 8,
                          ),
                        ),
                        SizedBox(
                          key: _scrollTroubleshootAttachmentKey,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ): const SizedBox(height: 0,),
              listImage.isEmpty && tt.progress == 'close_requested'
                  ? const SizedBox(height: 20,)
                  : troubleshootOrderAttachments(
                  context, widget.orderID, listImage, tt.progress ?? "close_requested" , tt.status, refresh),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    TroubleshootOrder _tt = await WorkOrderApi.getTroubleshootOrder(widget.orderID);
    setState(() {
      tt = _tt;
    });
  }

  textFieldStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black87);
  }

  textFieldDeco(String hint) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      hintText: hint,
    );
  }
}
