import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/models/tt_model.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/return_order.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/submit_ont.dart';
import 'package:wfm/pages/widgets/attachment_widget.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShowTroubleshootOrder extends StatefulWidget {
  final num orderID;
  const ShowTroubleshootOrder({super.key, required this.orderID});

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
  final TextEditingController _speedTest = TextEditingController();
  final TextEditingController _actionTaken = TextEditingController();
  final TextEditingController _ontChange = TextEditingController();

  @override
  void initState() {
    getAsync(widget.orderID);
    super.initState();
  }

  @override
  void dispose() {
    _rootCause.dispose();
    _subCause.dispose();
    _faultLocation.dispose();
    _speedTest.dispose();
    _actionTaken.dispose();
    _ontChange.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void refresh(Map img, String action) async {
    await getAsync(widget.orderID);
    if (mounted) {
      if (action == 'delete') {
        snackbarMessage(context, 'Image attachment deleted.');
        Navigator.pop(context);
      } else {
        snackbarMessage(context, 'Image uploaded');
        Navigator.pop(context);
      }
      listImage = img;
      updateActionButton();
    }
  }

  FloatingActionButton? currentButton(String? progress) {
    if (tt.ontChange == 'Approved' && tt.ontChange != '') {
      return FloatingActionButton.extended(
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
        label: const Text('Activate ONT'),
        icon: const Icon(Icons.camera),
      );
    }
    if (progress == 'completion' && tt.ontChange != "Pending") {
      return FloatingActionButton.extended(
        onPressed: () async => {
          loadingScreen(context),
          requestVerification = await WorkOrderApi.ttCompleteOrder(
              tt.ttId,
              _rootCause.value.text,
              _subCause.value.text,
              _faultLocation.value.text,
              _speedTest.value.text,
              _actionTaken.value.text,
              tt.ontChange == "Approved" ? tt.ontChange : null,
              tt.ontChange == "Approved" ? _ontChange.value.text : null),
          if (mounted)
            {
              Navigator.pop(context),
              if (!requestVerification.containsKey('error'))
                {
                  snackbarMessage(context, 'Verification request submitted!'),
                  _pullRefresh(),
                }
              else
                {
                  colorSnackbarMessage(
                      context,
                      'Request failed! ${requestVerification['error']}',
                      Colors.red)
                }
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

  getAsync(num id) async {
    loadingScreen(context);
    updateActionButton();
    try {
      prefs = await SharedPreferences.getInstance();
      tt = await WorkOrderApi.getTroubleshootOrder(id);
      listImage = tt.img;
    } catch (e) {
      print(e);
    }

    _rootCause.text = tt.rootCause ?? _rootCause.text;
    _subCause.text = tt.subCause ?? _subCause.text;
    _faultLocation.text = tt.faultLocation ?? _faultLocation.text;
    _speedTest.text = tt.speedTest ?? _speedTest.text;
    _actionTaken.text = tt.actionTaken ?? _actionTaken.text;
    _ontChange.text = _ontChange.text;

    if (tt.ontChange == "Approved" && _ontChange.text.isEmpty) {
      tt.progress = 'attachment';
    }

    if (mounted) {
      setState(() {});
      Navigator.pop(context); //Pop the loadingScreen(context);
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
    bool validCompletion = _rootCause.value.text.isNotEmpty &&
        _speedTest.value.text.isNotEmpty &&
        _actionTaken.value.text.isNotEmpty;
    if (tt.ontChange == "Approved") {
      validCompletion = validCompletion && _ontChange.text.isNotEmpty;
    }
    if (validCompletion) {
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
        actions: tt.status != 'Pending' ||
                tt.progress == 'close_requested' ||
                tt.ontChange == "Pending"
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
                            final returnedOrder = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReturnOrder(
                                        woId: widget.orderID,
                                        ftthId: tt.ttId,
                                        type: "TT",
                                        refresh: refresh,
                                      )),
                            );

                            if (returnedOrder != null) {
                              await getAsync(returnedOrder as num);
                              setState(() {});
                            }
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
              tt.status != 'Returned' && tt.status != 'Cancelled'
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
                  : const SizedBox(),
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
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(
                            text: tt.ttNo,
                          ));
                          if (mounted) {
                            colorSnackbarMessage(
                                context, "Order ID copied.", Colors.indigo);
                          }
                        }),
                    ListTile(
                      leading: const Icon(Icons.question_mark),
                      title: Text(
                        tt.status +
                            (tt.progress == 'close_requested'
                                ? ' (Close Requested)'
                                : tt.ontChange == 'Pending'
                                    ? ' (Awaiting ONT Change Approval)'
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
                      leading: const Icon(Icons.assignment),
                      title: Text(
                        tt.description ?? '-',
                        style: textFieldStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.info,
                      ),
                      title: Text(
                        tt.remark ?? '-',
                        style: textFieldStyle(
                            customColor:
                                tt.status != 'Completed' && tt.remark != null
                                    ? Colors.red
                                    : Colors.black87),
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
                    ),
                    ListTile(
                        leading: const Icon(Icons.numbers),
                        title: Text(
                          tt.custContact,
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
              tt.status != 'Returned' && tt.status != 'Cancelled'
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        ListTile(
                          title: const Text(
                            'Troubleshooting Details',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.start,
                          ),
                          subtitle: tt.ontChange == "Approved"
                              ? const Text(
                                  "Please activate new ONT before proceeding.",
                                  style: TextStyle(color: Colors.red),
                                )
                              : tt.status != "Completed"
                                  ? const Text(
                                      'Fill in all required (*) fields and attachments to proceed.',
                                      style: TextStyle(color: Colors.black),
                                    )
                                  : null,
                          subtitleTextStyle: const TextStyle(wordSpacing: 0.5),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: tt.progress == 'close_requested' ||
                                    tt.progress == null ||
                                    tt.status == 'Completed'
                                ? [
                                    ListTile(
                                      title: const Text("Root Cause"),
                                      subtitle: Text(tt.rootCause ?? "-"),
                                      style: ListTileStyle.list,
                                    ),
                                    ListTile(
                                        title: const Text("Sub Cause"),
                                        subtitle: Text(tt.subCause ?? "-")),
                                    ListTile(
                                        title: const Text("Fault Location"),
                                        subtitle:
                                            Text(tt.faultLocation ?? "-")),
                                    ListTile(
                                        title: const Text("Speed Test"),
                                        subtitle: Text(tt.speedTest ?? "-")),
                                    ListTile(
                                        title: const Text("Action Taken"),
                                        subtitle: Text(tt.actionTaken ?? "-")),
                                    if (tt.ontChange == "Approved")
                                      ListTile(
                                          title: const Text(
                                              "New Device Serial Number"),
                                          subtitle: Text(tt.ontSn ?? "-")),
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
                                        enabled: tt.ontChange == "Pending" ||
                                                tt.ontChange == "Approved"
                                            ? false
                                            : true,
                                        onChanged: (rootCause) =>
                                            {updateActionButton()},
                                        style: textFieldStyle(),
                                        textAlign: TextAlign.start,
                                        decoration:
                                            textFieldDeco("Enter root cause"),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ListTile(
                                      title: const Text("Sub Cause"),
                                      subtitle: TextField(
                                        controller: _subCause,
                                        enabled: tt.ontChange == "Pending" ||
                                                tt.ontChange == "Approved"
                                            ? false
                                            : true,
                                        style: textFieldStyle(),
                                        textAlign: TextAlign.start,
                                        decoration:
                                            textFieldDeco("Enter sub cause"),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ListTile(
                                      title: const Text("Fault Location"),
                                      subtitle: TextField(
                                        controller: _faultLocation,
                                        enabled: tt.ontChange == "Pending" ||
                                                tt.ontChange == "Approved"
                                            ? false
                                            : true,
                                        style: textFieldStyle(),
                                        textAlign: TextAlign.start,
                                        decoration: textFieldDeco(
                                            "Enter fault location"),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ListTile(
                                      title: const Text("Speed Test (Mbps) *"),
                                      subtitle: TextField(
                                        controller: _speedTest,
                                        enabled: tt.ontChange == "Pending" ||
                                                tt.ontChange == "Approved"
                                            ? false
                                            : true,
                                        onChanged: (speedTest) =>
                                            {updateActionButton()},
                                        style: textFieldStyle(),
                                        textAlign: TextAlign.start,
                                        decoration: textFieldDeco(
                                            "Enter speed test result"),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ListTile(
                                      title: const Text("Action Taken *"),
                                      subtitle: TextField(
                                        controller: _actionTaken,
                                        enabled: tt.ontChange == "Pending" ||
                                                tt.ontChange == "Approved"
                                            ? false
                                            : true,
                                        onChanged: (actionTaken) =>
                                            {updateActionButton()},
                                        style: textFieldStyle(),
                                        textAlign: TextAlign.start,
                                        decoration: textFieldDeco(
                                            "Enter actions taken to troubleshoot."),
                                        maxLines: 8,
                                      ),
                                    ),
                                    if (tt.progress == "close_requested" ||
                                        tt.progress == "completion")
                                      ListTile(
                                        title: const Text("ONT Change status:"),
                                        subtitle: Text(
                                          tt.ontChange ?? 'Not Applicable',
                                          style: TextStyle(
                                              color: tt.ontChange == "Completed"
                                                  ? Colors.green
                                                  : tt.ontChange == "Rejected"
                                                      ? Colors.red
                                                      : Colors.black),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    if (tt.ontChange == null ||
                                        tt.ontChange == "Rejected")
                                      Center(
                                        child: Column(
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: tt.ontChange ==
                                                        "Rejected"
                                                    ? Colors.redAccent
                                                    : Colors
                                                        .indigo, // Change this to the color you want
                                              ),
                                              onPressed: () async {
                                                bool confirm =
                                                    await ontChangePrompt(
                                                        context);
                                                if (confirm) {
                                                  var response =
                                                      await WorkOrderApi
                                                          .ontChangeRequest(
                                                              widget.orderID);
                                                  if (mounted) {
                                                    Navigator.pop(context);
                                                    if (response.statusCode >=
                                                            200 &&
                                                        response.statusCode <
                                                            400) {
                                                      snackbarMessage(context,
                                                          'ONT change approval requested!');
                                                      _pullRefresh();
                                                    } else {
                                                      colorSnackbarMessage(
                                                          context,
                                                          'ONT change request failed!',
                                                          Colors.red);
                                                    }
                                                  }
                                                }
                                              },
                                              child: Text(
                                                  tt.ontChange == "Rejected"
                                                      ? 'Resubmit ONT Change'
                                                      : 'ONT Change'),
                                            ),
                                            const ListTile(
                                              leading: FaIcon(
                                                FontAwesomeIcons.circleInfo,
                                                color: Colors.black54,
                                              ),
                                              title: Text(
                                                "Use the button above if ONT device requires changing.",
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),
                                              titleTextStyle:
                                                  TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    tt.ontChange == "Rejected"
                                        ? ListTile(
                                            leading: const Icon(
                                              Icons.warning_amber_outlined,
                                              color: Colors.redAccent,
                                            ),
                                            title: const Text(
                                              "Previous request was rejected!",
                                              style: TextStyle(
                                                  color: Colors.redAccent),
                                            ),
                                            subtitle: Text(
                                              'Remark: ${tt.remark ?? 'N/A'}',
                                              style: const TextStyle(
                                                  color: Colors.redAccent),
                                            ),
                                          )
                                        : const SizedBox(width: 0),
                                    // if (tt.ontChange == "Approved") Center(
                                    //   child: ListTile(
                                    //     title: const Text("New ONT *"),
                                    //     subtitle: TextField(
                                    //       controller: _ontChange,
                                    //       onChanged: (actionTaken) => {updateActionButton()},
                                    //       // style: textFieldStyle(),
                                    //       textAlign: TextAlign.start,
                                    //       decoration: InputDecoration(
                                    //         border: const OutlineInputBorder(),
                                    //         hintText: 'Enter or scan serial number',
                                    //         suffixIcon: IconButton(
                                    //           icon: const Icon(Icons.camera_alt_outlined),
                                    //           iconSize: 20,
                                    //           color: Colors.indigo,
                                    //           tooltip: 'Scan serial number barcode',
                                    //           onPressed: () async {
                                    //             var ontSn = await CameraUtils.getScanRes();
                                    //             setState(() {
                                    //               ontSn = ontSn;
                                    //               _ontChange.text = ontSn;
                                    //             });
                                    //           },
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    tt.ontChange == "Pending"
                                        ? const Center(
                                            child: ElevatedButton(
                                              onPressed: null,
                                              child:
                                                  Text('Awaiting Approval...'),
                                            ),
                                          )
                                        : const SizedBox(width: 0),
                                    SizedBox(
                                      key: _scrollTroubleshootAttachmentKey,
                                      height: 20,
                                    ),
                                  ],
                          ),
                        ),
                      ],
                    )
                  : tt.status == "Returned"
                      ? Column(
                          children: [
                            const ListTile(
                              title: Text(
                                'Returned Details',
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: const Icon(Icons.note_alt),
                                title: const Text('Remark'),
                                subtitle: Text(tt.remark ?? '-'),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        )
                      : const SizedBox(
                          height: 0,
                        ),
              listImage.isEmpty && tt.progress == 'close_requested'
                  ? const SizedBox(
                      height: 20,
                    )
                  : troubleshootOrderAttachments(
                      context,
                      widget.orderID,
                      listImage,
                      tt.progress ?? "close_requested",
                      tt.status,
                      refresh),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    // TroubleshootOrder tempTT = await WorkOrderApi.getTroubleshootOrder(widget.orderID);
    await getAsync(widget.orderID);
    setState(() {
      // tt = tempTT;
    });
  }

  textFieldStyle({Color customColor = Colors.black87}) {
    return TextStyle(fontSize: 14, color: customColor);
  }

  textFieldDeco(String hint) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      hintText: hint,
    );
  }
}
