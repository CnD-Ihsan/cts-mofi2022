import 'package:accordion/accordion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

class Attachments extends StatefulWidget {
  final num woId;
  final List<String> urlImages;
  const Attachments({Key? key, required this.woId, required this.urlImages}) : super(key: key);

  @override
  State<Attachments> createState() => _AttachmentsState();
}

class _AttachmentsState extends State<Attachments> {
  late num woId;
  String host = 'http://80.80.2.254:8080/api/workorder/order-image/';
  List<String> urlImages = [''];

  @override
  void initState() {
    woId = widget.woId;
    if(woId != 0){
      getAsync(woId);
    }
    super.initState();
  }

  late SharedPreferences prefs;

  getAsync(num id) async {
    try {
      prefs = await SharedPreferences.getInstance();
      urlImages = await WorkOrderApi.getImgAttachments(woId);
      // if ((wo.ontSn != null && !wo.ontSn.toString().contains(' '))) {
      //   ontSubmitted = true;
      // }
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            // await imagePickerPrompt(context, 'ontsn', woId);
                            if(mounted){
                              // Navigator.pop(context);
                              // Navigator.push(context, MaterialPageRoute(
                              //     settings: const RouteSettings(
                              //       name: "/show",
                              //     ),
                              //     builder: (context) => const ShowOrder(
                              //       orderID: 316,
                              //     )),);
                            }
                          },
                        ),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: urlImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: host + (urlImages[index]),
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                              // Image(
                              //   image: NetworkImage(host + (urlImages == null ? '' : urlImages[0])),
                              //   fit: BoxFit.cover,
                              // ),
                              onLongPress: () async {
                                // deleteAttachment(context, woId, urlImages[index]);
                                // if(mounted){
                                //   Navigator.pop(context);
                                // }
                              },
                              onTap: () {
                                openGallery(context, urlImages, index);
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => PhotoView(
                                //         imageProvider: NetworkImage(host + (urlImages[index])),
                                //       ),
                                //     ));
                              });
                        }),
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
  }
}

Widget noAttachmentWidget(){
  return const ListTile(
  leading: Icon(Icons.broadcast_on_personal_outlined),
  title: Text('Empty Attachments'),
  );
}

Widget newInstallationAttachments(BuildContext context, num woId, List<String> listImage, Function(List<String>) refresh) {
  String host = 'http://80.80.2.254:8080/api/workorder/order-image/';

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
                          imagePickerPrompt(context, 'ontsn', woId, refresh);
                          // final XFile? image = await ImagePicker()
                          //     .pickImage(source: ImageSource.gallery);
                        },
                      ),
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: listImage.length,
                      itemBuilder: (context, index) {
                        // if(listImage[index])
                        return GestureDetector(
                            child: Container(
                              height: 100,
                              width: 100,
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: host + (listImage[index]),
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                            onLongPress: (){
                              deleteAttachment(context, woId, listImage[index], refresh);
                            },
                            onTap: () {
                              openGallery(context, listImage, index);
                            });
                      }),
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
}

void openGallery(BuildContext context, List<String> urlImages, int index){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => GalleryWidget(
        urlImages: urlImages,
        index: index,
      ),
    ),
  );
}

class GalleryWidget extends StatefulWidget {
  final List<String> urlImages;
  final int index;
  final PageController pageController;

  GalleryWidget({Key? key, required this.urlImages, required this.index}) : pageController = PageController(initialPage: index), super(key: key);

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  String host = 'http://80.80.2.254:8080/api/workorder/order-image/';
  late int index = widget.index;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: PhotoViewGallery.builder(
            pageController: widget.pageController,
            onPageChanged: (index) => {
              setState(() => this.index = index),
            },
            itemCount: widget.urlImages.length,
            builder: (context, index) {
              final urlImage = host + widget.urlImages[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(urlImage),
              );
            }),
      );
}
