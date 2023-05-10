import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/return_order.dart';
import 'package:wfm/pages/submit_ont.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/widgets/attachment_widget.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShowOrder extends StatefulWidget {
  final num orderID;
  const ShowOrder({Key? key, required this.orderID}) : super(key: key);

  @override
  State<ShowOrder> createState() => _ShowOrderState();
}

class _ShowOrderState extends State<ShowOrder> {
  num orderID = 0;
  Stream<dynamic>? bc;
  Map listImage = {};
  Map requestVerification = {};
  var txt = TextEditingController();
  final GlobalKey _scrollAttachmentKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    loadingScreen(context);
    getAsync(widget.orderID, true);
    super.initState();
  }

  void refresh(Map img, String action) async {
      print(img);
      await getAsync(widget.orderID, false);
      if(mounted){}
      if(action == 'delete'){
        snackbarMessage(context, 'Image attachment deleted.');
        Navigator.pop(context);
      }
      else{
        snackbarMessage(context, 'Image uploaded');
      }
      listImage = img;

      // initState();
      // setState((){});
  }

  FloatingActionButton? currentButton(String? progress){
    if(progress == 'activation'){
      return FloatingActionButton.extended(
        onPressed: () => {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              // Returning SizedBox instead of a Container
              return SubmitONT(
                woId: wo.woId,
              );
            },
          ),
        },
        label: const Text('Activate ONT'),
        icon: const Icon(Icons.camera),
      );
    }else if(progress == 'attachment'){
      return FloatingActionButton.extended(
        onPressed: () {
          // get the position of the "attachment" section relative to the top of the screen
          RenderBox? renderBox = _scrollAttachmentKey.currentContext?.findRenderObject() as RenderBox?;
          double offset = renderBox!.localToGlobal(Offset.zero).dy;

          // scroll to the position of the "attachment" section
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        label: const Text('Attachments*'),
        icon: const Icon(Icons.file_download),
      );
    }else if(progress == 'completion'){
      return FloatingActionButton.extended(
        onPressed: () async => {
          // alertMessage(context, 'Submit order completion?'),
          requestVerification = await WorkOrderApi.completeOrder(wo.soId, wo.ontSn),
          if(!requestVerification.containsKey('error')){
            snackbarMessage(context, 'Verification request submitted!'),
            setState(() {})
          }else{
            colorSnackbarMessage(context, 'Request error! ${requestVerification['error']}', Colors.red)
          }
        },
        label: const Text('Complete Order'),
        icon: const Icon(Icons.check_circle),
      );
    }else{
      return null;
    }
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

  getAsync(num id, bool needPop) async {
    try {
      prefs = await SharedPreferences.getInstance();
      wo = await WorkOrderApi.getWorkOrder(id);
      listImage = wo.img;
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
      if(needPop){
        Navigator.pop(context);
      }
      if(wo.woId == 0){
        colorSnackbarMessage(context, 'Failed to get work order details! Contact admin if issue persists.', Colors.red);
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(wo.woName),
        actions: wo.status != 'Pending' || wo.progress == 'close_requested' ? null : [
          Builder(
              builder: (context) {
                return PopupMenuButton(
                  icon: const Icon(Icons.menu),
                  position: PopupMenuPosition.under,
                  // color: Colors.blue,
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
                        await Future.delayed(const Duration(milliseconds: 10));
                        if(mounted){}
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReturnOrder(
                                woId: wo.woId,
                                soId: wo.soId,
                                refresh: refresh,
                              )),
                        );
                      },
                      child: const Text("Return Order", style: TextStyle(color: Colors.red),),
                    ),
                  ],
                );
              }
          )
        ],
      ),
      floatingActionButton: currentButton(wo.progress),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            wo.status != 'Returned' || wo.status != 'Cancelled' ?
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      'Activation',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                      textAlign: TextAlign.start,
                    ),
                    wo.progress == 'activation' ?
                    const FaIcon(FontAwesomeIcons.circleHalfStroke, color: Colors.blue,) :
                    const FaIcon(FontAwesomeIcons.solidCircleCheck, color: Colors.blue,)
                  ],
                ),
                Icon(Icons.chevron_right, color: wo.progress == 'activation' ? Colors.black : Colors.blue,),
                Column(
                  children: [
                    Text(
                      'Attachment',
                      style: TextStyle(fontSize: 12, color: wo.progress == 'activation' ? Colors.black : Colors.blue,),
                      textAlign: TextAlign.start,
                    ),
                    wo.progress == 'attachment' ?
                    const FaIcon(FontAwesomeIcons.circleHalfStroke, color: Colors.blue,) :
                        wo.progress == 'activation' ?
                        const FaIcon(FontAwesomeIcons.circle, color: Colors.black,) :
                        const FaIcon(FontAwesomeIcons.solidCircleCheck, color: Colors.blue,)
                  ],
                ),
                Icon(Icons.chevron_right, color: wo.progress == 'activation' || wo.progress == 'attachment' ? Colors.black : Colors.blue,),
                Column(
                  children: [
                    Text(
                      'Completion',
                      style: TextStyle(fontSize: 12, color: wo.progress == 'activation' || wo.progress == 'attachment' ? Colors.black : Colors.blue,),
                      textAlign: TextAlign.start,
                    ),
                    wo.progress == 'completion' || wo.progress == 'close_requested' ?
                      const FaIcon(FontAwesomeIcons.circleHalfStroke, color: Colors.blue,) :
                      wo.progress == 'activation' || wo.progress == 'attachment' ?
                      const FaIcon(FontAwesomeIcons.circle, color: Colors.black,) :
                      const FaIcon(FontAwesomeIcons.solidCircleCheck, color: Colors.blue,)
                  ],
                ),
              ],
            ) : const Divider(),
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
                      wo.status + (wo.progress == 'close_requested' ? ' (Close Requested)' : ''),
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
                    leading: const Icon(Icons.assignment_ind_outlined),
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
                'Customer Details',
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
                      leading: const Icon(Icons.person),
                      title: Text(
                        wo.custName,
                        style: textStyle(),
                        textAlign: TextAlign.start,
                      ),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          InkWell(
                            onTap: () async {
                              final Uri url = Uri.parse('https://wa.me/${wo.custContact}');
                              if(await canLaunchUrl(url)){
                              launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: const Icon(Icons.whatsapp),
                          ),
                          InkWell(
                            onTap: () async {
                              final Uri url = Uri.parse('tel:${wo.custContact}');
                              if(await canLaunchUrl(url)){
                              launchUrl(url);
                              }
                            },
                            child: const Icon(Icons.phone),
                          ),
                        ],)
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.phone),
                  //   onTap: () async {
                  //     final Uri url = Uri.parse('tel:${wo.custContact}');
                  //     if(await canLaunchUrl(url)){
                  //       launchUrl(url);
                  //     }
                  //   },
                  //   title: Text(
                  //     wo.custContact,
                  //     style: textStyle(),
                  //     textAlign: TextAlign.start,
                  //   ),
                  // ),
                  ListTile(
                    leading: const Text(
                      'ONT',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                    title: Text(
                      wo.progress != 'activation'
                          ? wo.ontSn.toString()
                          : 'Not Activated',
                      style: textStyle(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(
                    key: _scrollAttachmentKey,
                    height: 20,
                  ),
                ],
              ),
            ),
            wo.progress == 'activation' ? const Divider() : newInstallationAttachments(context, wo.woId, listImage, refresh, _scrollAttachmentKey),
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
