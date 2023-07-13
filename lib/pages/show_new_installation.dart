import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/models/so_model.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/return_order.dart';
import 'package:wfm/pages/submit_ont.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/widgets/attachment_widget.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShowServiceOrder extends StatefulWidget {
  final num orderID;
  const ShowServiceOrder({Key? key, required this.orderID}) : super(key: key);

  @override
  State<ShowServiceOrder> createState() => _ShowServiceOrderState();
}

class _ShowServiceOrderState extends State<ShowServiceOrder> {
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
      await getAsync(widget.orderID, false);
      if(mounted){
        if(action == 'delete'){
          snackbarMessage(context, 'Image attachment deleted.');
          Navigator.pop(context);
        }
        else{
          snackbarMessage(context, 'Image uploaded');
          Navigator.pop(context);
        }
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
                woId: widget.orderID,
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
          requestVerification = await WorkOrderApi.soCompleteOrder(widget.orderID, so.ontSn),
          if(!requestVerification.containsKey('error')){
            _pullRefresh(),
            snackbarMessage(context, 'Verification request submitted!')
          }else{
            colorSnackbarMessage(context, 'Request error! ${requestVerification['error']}', Colors.red)
          },
        },
        label: const Text('Complete Order'),
        icon: const Icon(Icons.check_circle),
      );
    }else{
      return null;
    }
  }

  ServiceOrder so = ServiceOrder(
    soId: 0,
    soName: 'Loading...',
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
      so = await WorkOrderApi.getServiceOrder(id);
      print(so.progress);
      listImage = so.img;
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
      if(needPop){
        Navigator.pop(context);
      }
      if(so.soId == 0){
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

    const MaterialColor themeColor = Colors.indigo;

    return Scaffold(
      appBar: AppBar(
        title: Text("New Installation Order"),
        actions: so.status != 'Pending' || so.progress == 'close_requested' ? null : [
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
                        if(mounted){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReturnOrder(
                                  woId: widget.orderID,
                                  ftthId: so.soId,
                                  type: "SO",
                                  refresh: refresh,
                                )),
                          );
                        }
                      },
                      child: const Text("Return Order", style: TextStyle(color: Colors.red),),
                    ),
                  ],
                );
              }
          )
        ],
      ),
      floatingActionButton: currentButton(so.progress),
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
              so.status != 'Returned' || so.status != 'Cancelled' ?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Activation',
                        style: TextStyle(fontSize: 12, color: themeColor),
                        textAlign: TextAlign.start,
                      ),
                      so.progress == 'activation' ?
                      const FaIcon(FontAwesomeIcons.circleHalfStroke, color: themeColor,) :
                      const FaIcon(FontAwesomeIcons.solidCircleCheck, color: themeColor,)
                    ],
                  ),
                  Icon(Icons.chevron_right, color: so.progress == 'activation' ? Colors.black : themeColor,),
                  Column(
                    children: [
                      Text(
                        'Attachment',
                        style: TextStyle(fontSize: 12, color: so.progress == 'activation' ? Colors.black : themeColor,),
                        textAlign: TextAlign.start,
                      ),
                      so.progress == 'attachment' ?
                      const FaIcon(FontAwesomeIcons.circleHalfStroke, color: themeColor,) :
                          so.progress == 'activation' ?
                          const FaIcon(FontAwesomeIcons.circle, color: Colors.black,) :
                          const FaIcon(FontAwesomeIcons.solidCircleCheck, color: themeColor,)
                    ],
                  ),
                  Icon(Icons.chevron_right, color: so.progress == 'activation' || so.progress == 'attachment' ? Colors.black : themeColor,),
                  Column(
                    children: [
                      Text(
                        'Completion',
                        style: TextStyle(fontSize: 12, color: so.progress == 'activation' || so.progress == 'attachment' ? Colors.black : themeColor,),
                        textAlign: TextAlign.start,
                      ),
                      so.progress == 'completion' || so.progress == 'close_requested' ?
                        const FaIcon(FontAwesomeIcons.circleHalfStroke, color: themeColor) :
                        so.progress == 'activation' || so.progress == 'attachment' ?
                        const FaIcon(FontAwesomeIcons.circle, color: Colors.black,) :
                        const FaIcon(FontAwesomeIcons.solidCircleCheck, color: themeColor,)
                    ],
                  ),
                ],
              ) : const Divider(),
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
                        so.soName,
                        style: textStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.question_mark),
                      title: Text(
                        so.status + (so.progress == 'close_requested' ? ' (Close Requested)' : ''),
                        style: textStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: Text(
                        so.date ?? 'N/A',
                        style: textStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        so.time ?? 'N/A',
                        style: textStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.assignment_ind_outlined),
                      title: Text(
                        so.requestedBy,
                        style: textStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        so.lat != 0
                            ? MapUtils.openMap(so.lat, so.lng)
                            : (so.address == ''
                                ? alertMessage(context, 'Empty address')
                                : mapPromptDialog(context, so.address));
                      },
                      child: ListTile(
                        leading: const Icon(Icons.home),
                        title: Text(
                          so.address,
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
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.broadcast_on_personal_outlined),
                      title: Text(
                        so.carrier,
                        style: textStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.signal_cellular_alt),
                      title: Text(
                        so.speed,
                        style: textStyle(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          so.custName,
                          style: textStyle(),
                          textAlign: TextAlign.start,
                        ),
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            InkWell(
                              onTap: () async {
                                final Uri url = Uri.parse('https://wa.me/+6${so.custContact}');
                                if(await canLaunchUrl(url)){
                                launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green,),
                            ),
                            InkWell(
                              onTap: () async {
                                await phonePromptDialog(context, so.custContact);
                                // final Uri url = Uri.parse('tel:${so.custContact}');
                                // if(await canLaunchUrl(url)){
                                //   launchUrl(url);
                                // }
                              },
                              child: const Icon(Icons.phone, color: themeColor,),
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
                        so.progress != 'activation'
                            ? so.ontSn.toString()
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
              listImage.isEmpty && so.progress == 'closed_requested'
                  ? const SizedBox(height: 20,)
                  : newInstallationAttachments(context, widget.orderID, so.progress ?? 'close_requested', so.status ,listImage, refresh),
            ],
          ),
        ),
      ),
    );
  }

  textStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black87);
  }

  Future<void> _pullRefresh() async {
    ServiceOrder _so = await WorkOrderApi.getServiceOrder(widget.orderID);
    setState(() {
      so = _so;
    });
  }
}
