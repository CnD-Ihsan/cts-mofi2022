import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

Widget newInstallationAttachments(BuildContext context, num woId) {
  return Column(
    children: [
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
            const ListTile(
              leading: Icon(Icons.broadcast_on_personal_outlined),
              // leading: const Text(
              //   'Requested By:',
              //   style: TextStyle(fontSize: 18),
              //   textAlign: TextAlign.start,
              // ),
              title: Text('ONT Serial Number'),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              height: 160.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
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
                          imagePickerPrompt(context, 'ONT Serial Number', woId);
                          // final XFile? image = await ImagePicker()
                          //     .pickImage(source: ImageSource.gallery);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 160.0,
                    color: Colors.blue,
                  ),
                  Container(
                    width: 160.0,
                    color: Colors.green,
                  ),
                  Container(
                    width: 160.0,
                    color: Colors.yellow,
                  ),
                  // FutureBuilder<List<WorkOrder>>(
                  //     future: WorkOrderApi.getWorkOrderList(),
                  //     builder: (context, snapshot) {
                  //       if (snapshot.hasData) {
                  //         List<WorkOrder> list = snapshot.data!;
                  //
                  //         if (filterNotifier.value['status'] != 'All Status') {
                  //           list = list
                  //               .where((workOrder) =>
                  //           workOrder.status == filterNotifier.value['status'])
                  //               .toList();
                  //         }
                  //         if (filterNotifier.value['type'] != 'All Orders') {
                  //           list = list
                  //               .where((workOrder) =>
                  //           workOrder.taskType == filterNotifier.value['type'])
                  //               .toList();
                  //         }
                  //
                  //         return ListView.builder(
                  //           padding: const EdgeInsets.all(10.0),
                  //           itemCount: list.length,
                  //           itemBuilder: (context, index) {
                  //             WorkOrder wo = list[list.length - index - 1];
                  //             var logo = 'else';
                  //
                  //             try {
                  //               var temp = wo.woName.substring(0, 3);
                  //               if (logoDict.containsKey(temp)) {
                  //                 logo = temp;
                  //               }
                  //             } catch (e) {
                  //               print(e);
                  //             }
                  //             logo = logoDict[logo];
                  //
                  //             return InkWell(
                  //               onTap: () {
                  //                 Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                       settings: const RouteSettings(
                  //                         name: "/show",
                  //                       ),
                  //                       builder: (context) => ShowOrder(
                  //                         orderID: wo.soId,
                  //                       )),
                  //                 );
                  //               },
                  //               child: CustomListItemTwo(
                  //                 thumbnail: Image.asset(
                  //                   'assets/img/logo/$logo.png',
                  //                   fit: BoxFit.fitWidth,
                  //                 ),
                  //                 title: wo.woName,
                  //                 subtitle: wo.address,
                  //                 author: wo.woType ?? 'Undefined',
                  //                 publishDate: wo.date ?? 'Unassigned',
                  //                 readDuration: wo.time ?? 'Unassigned',
                  //               ),
                  //             );
                  //           },
                  //         );
                  //       } else if(snapshot.hasError){
                  //         return const Center(
                  //           child: Text('Empty order'),
                  //         );
                  //       }
                  //       return const Center(
                  //         child: CircularProgressIndicator(),
                  //       );
                  //     })),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Customer Signature'),
            ),
            const ListTile(
              leading: Icon(Icons.network_check),
              title: const Text('Speed Test'),
            ),
            const ListTile(
              leading: Icon(Icons.router_outlined),
              title: const Text('RGW Serial Number'),
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
  );

  getAttachments(attachment_type) {}
}
