import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/models/so_model.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/return_order.dart';
import 'package:wfm/pages/submit_ont.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/widgets/admin_attachment_widget.dart';
import 'package:wfm/pages/widgets/attachment_widget.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminShowServiceOrder extends StatefulWidget {
  final num orderID;
  const AdminShowServiceOrder({Key? key, required this.orderID}) : super(key: key);

  @override
  State<AdminShowServiceOrder> createState() => _AdminShowServiceOrderState();
}

class _AdminShowServiceOrderState extends State<AdminShowServiceOrder> {
  num orderID = 0;
  Stream<dynamic>? bc;
  Map listImage = {};
  Map requestVerification = {};
  final TextEditingController _rgwSnCt = TextEditingController();
  final TextEditingController _speedTestCt = TextEditingController();

  final GlobalKey<FormState> _completeSoFormKey = GlobalKey<FormState>();
  final GlobalKey _scrollAttachmentKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getAsync(widget.orderID);
    super.initState();
  }

  void refresh(Map img, String action) async {
    await getAsync(widget.orderID);
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

  getAsync(num id) async {
    loadingScreen(context);
    try {
      prefs = await SharedPreferences.getInstance();
      so = await WorkOrderApi.getServiceOrder(id);
      listImage = so.img;
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
      Navigator.pop(context); //Pop the loadingScreen(context);
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
        title: const Text("New Installation Order"),
      ),
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
                      onLongPress: () async {
                        await Clipboard.setData(ClipboardData(text: so.soName));
                        // copied successfully
                      },
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
                    ),
                    ListTile(
                        leading: const Icon(Icons.numbers),
                        title: Text(
                          so.custContact,
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
                              },
                              child: const Icon(Icons.phone, color: themeColor,),
                            ),
                          ],)
                    ),
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
                        style: so.progress != 'activation' ? textStyle() : const TextStyle(fontSize: 14, color: Colors.red),
                        textAlign: TextAlign.start,
                      ),
                      onLongPress: () async {
                        await Clipboard.setData(ClipboardData(text: so.ontSn.toString()));
                        // copied successfully
                      },
                    ),
                    SizedBox(
                      key: _scrollAttachmentKey,
                      height: 20,
                    ),
                  ],
                ),
              ),
              so.status != "Returned" ? Column(children: [
                const ListTile(
                  title: Text(
                    'Required Details',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Speed Test (Mbps)'),
                        subtitle: Text(so.speedTest ?? '-'),
                      ),
                      ListTile(
                        title: const Text('RGW SN'),
                        subtitle: Text(so.rgwSn ?? '-'),
                      ),
                      const SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],)
               : Column(
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
                      subtitle: Text(so.remark ?? '-'),
                    ),
                  ),
                  const SizedBox(height: 12,),
                ],
              ),
              listImage.isNotEmpty || so.progress == 'attachment'
                  ? adminNewInstallationAttachments(context, widget.orderID, so.progress ?? 'close_requested', so.status ,listImage, refresh)
                  : const SizedBox(height: 20,),
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
