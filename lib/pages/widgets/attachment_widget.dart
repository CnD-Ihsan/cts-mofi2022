import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

class Attachments extends StatefulWidget {
  final num woId;
  final List<String> urlImages;
  static const String host = 'https://wfm.ctsabah.net/api/work-orders/order-image/';
  const Attachments({Key? key, required this.woId, required this.urlImages}) : super(key: key);

  @override
  State<Attachments> createState() => _AttachmentsState();
}

class _AttachmentsState extends State<Attachments> {
  late num woId;
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
                            if(mounted){
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
                                  imageUrl: Attachments.host + (urlImages[index]),
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

Widget newInstallationAttachments(BuildContext context, num woId, String progress, String status,Map listImage,  Function(Map, String) refresh) {
  if(status == 'Returned'){
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Attachments',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.start,
          ),
          subtitle: progress != "close_requested" ? const Text('Use button to add image. Tap & hold image to delete them.') : null,
        ),
        const ListTile(
          leading: Icon(Icons.assignment_return_outlined),
          title: Text('Returned Attachments'),
        ),
        Container(
          height: 120.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              progress != "close_requested" ? Container(
                width: 120.0,
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
                      imagePickerPrompt(context, 'return', woId, refresh);
                    },
                  ),
                ),
              ) : const SizedBox(width: 20,),
              ListView.builder(
                  reverse: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: listImage['return']?.length ?? 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        child: Container(
                          height: 100,
                          width: 100,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: Attachments.host + (listImage['return'][index]['name']),
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                        onLongPress: (){
                          if(progress != "close_requested"){
                            deleteAttachment(context, woId, listImage['return'][index]['name'], refresh, 'return');
                          }
                        },
                        onTap: () {
                          openGallery(context, List<dynamic>.from(listImage['return']), index);
                        });
                  }),
            ],
          ),
        ),
        const SizedBox(height: 30,)
      ],
    );
  }else {
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Attachments',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.start,
          ),
          subtitle: progress != "close_requested"
              ? const Text(
              'Use button to add image. Tap & hold image to delete them.')
              : null,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: Icon(Icons.broadcast_on_personal_outlined),
                title: Text('ONT Serial Number *'),
              ),
              Container(
                height: 120.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    progress != "close_requested" ?
                    Container(
                      width: 120.0,
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
                          },
                        ),
                      ),
                    ) : const SizedBox(width: 5,),
                    ListView.builder(
                        reverse: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: listImage['ontsn']?.length ?? 0,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: Attachments.host +
                                      (listImage['ontsn'][index]['name']),
                                  placeholder: (context, url) =>
                                  const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url,
                                      error) => const Icon(Icons.error),
                                ),
                              ),
                              onLongPress: () {
                                if (progress != "close_requested") {
                                  deleteAttachment(context, woId,
                                      listImage['ontsn'][index]['name'],
                                      refresh, 'ontsn');
                                }
                              },
                              onTap: () {
                                openGallery(context,
                                    List<dynamic>.from(listImage['ontsn']),
                                    index);
                              });
                        }),
                  ],
                ),
              ),
              const ListTile(
                leading: Icon(Icons.assignment),
                title: Text('Customer Signature  *'),
              ),
              Container(
                height: 120.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    progress != "close_requested" ?
                    Container(
                      width: 120.0,
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
                            imagePickerPrompt(context, 'sign', woId, refresh);
                            // final XFile? image = await ImagePicker()
                            //     .pickImage(source: ImageSource.gallery);
                          },
                        ),
                      ),
                    ) : const SizedBox(width: 5,),
                    ListView.builder(
                        reverse: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: listImage['sign']?.length ?? 0,
                        itemBuilder: (context, index) {
                          // if(listImage[index])
                          return GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: Attachments.host +
                                      (listImage['sign'][index]['name']),
                                  placeholder: (context, url) =>
                                  const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url,
                                      error) => const Icon(Icons.error),
                                ),
                              ),
                              onLongPress: () {
                                if (progress != "close_requested") {
                                  deleteAttachment(context, woId,
                                      listImage['sign'][index]['name'], refresh,
                                      'sign');
                                }
                              },
                              onTap: () {
                                openGallery(context,
                                    List<dynamic>.from(listImage['sign']),
                                    index);
                              });
                        }),
                  ],
                ),
              ),
              const ListTile(
                leading: Icon(Icons.network_check),
                title: Text('Speed Test *'),
              ),
              Container(
                height: 120.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    progress != "close_requested" ?
                    Container(
                      width: 120.0,
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
                            imagePickerPrompt(
                                context, 'speedtest', woId, refresh);
                            // final XFile? image = await ImagePicker()
                            //     .pickImage(source: ImageSource.gallery);
                          },
                        ),
                      ),
                    ) : const SizedBox(width: 5,),
                    ListView.builder(
                        reverse: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: listImage['speedtest']?.length ?? 0,
                        itemBuilder: (context, index) {
                          // if(listImage[index])
                          return GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: Attachments.host +
                                      (listImage['speedtest'][index]['name']),
                                  placeholder: (context, url) =>
                                  const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url,
                                      error) => const Icon(Icons.error),
                                ),
                              ),
                              onLongPress: () {
                                if (progress != "close_requested") {
                                  deleteAttachment(context, woId,
                                      listImage['speedtest'][index]['name'],
                                      refresh, 'speedtest');
                                }
                              },
                              onTap: () {
                                openGallery(context,
                                    List<dynamic>.from(listImage['speedtest']),
                                    index);
                              });
                        }),
                  ],
                ),
              ),
              const ListTile(
                leading: Icon(Icons.router_outlined),
                title: const Text('RGW Serial Number *'),
              ),
              Container(
                height: 120.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    progress != "close_requested" ?
                    Container(
                      width: 120.0,
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
                            imagePickerPrompt(context, 'rgw', woId, refresh);
                            // final XFile? image = await ImagePicker()
                            //     .pickImage(source: ImageSource.gallery);
                          },
                        ),
                      ),
                    ) : const SizedBox(width: 5,),
                    ListView.builder(
                        reverse: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: listImage['rgw']?.length ?? 0,
                        itemBuilder: (context, index) {
                          // if(listImage[index])
                          return GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: Attachments.host +
                                      (listImage['rgw'][index]['name']),
                                  placeholder: (context, url) =>
                                  const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url,
                                      error) => const Icon(Icons.error),
                                ),
                              ),
                              onLongPress: () {
                                if (progress != "close_requested") {
                                  deleteAttachment(context, woId,
                                      listImage['rgw'][index]['name'], refresh,
                                      'rgw');
                                }
                              },
                              onTap: () {
                                openGallery(context,
                                    List<dynamic>.from(listImage['rgw']),
                                    index);
                              });
                        }),
                  ],
                ),
              ),
              listImage.containsKey('web') ? Column(children: [
                const ListTile(
                  leading: Icon(Icons.web_outlined),
                  title: const Text('Web Attachments'),
                ),
                Container(
                  height: 120.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      progress != "close_requested" ?
                      Container(
                        width: 120.0,
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
                              imagePickerPrompt(context, 'web', woId, refresh);
                            },
                          ),
                        ),
                      ) : const SizedBox(width: 5,),
                      ListView.builder(
                          reverse: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: listImage['web']?.length ?? 0,
                          itemBuilder: (context, index) {
                            // if(listImage[index])
                            return GestureDetector(
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: Attachments.host +
                                        (listImage['web'][index]['name']),
                                    placeholder: (context, url) =>
                                    const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url,
                                        error) => const Icon(Icons.error),
                                  ),
                                ),
                                onLongPress: () {
                                  if (progress != "close_requested") {
                                    deleteAttachment(context, woId,
                                        listImage['web'][index]['name'],
                                        refresh, 'web');
                                  }
                                },
                                onTap: () {
                                  openGallery(context,
                                      List<dynamic>.from(listImage['web']),
                                      index);
                                });
                          }),
                    ],
                  ),
                ),
              ],) : const SizedBox(height: 0, width: 0,),
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

Widget troubleshootOrderAttachments(BuildContext context, num woId, Map listImage, String progress, String status, Function(Map, String) refresh) {
  if(status == 'Returned'){
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Attachments',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.start,
          ),
          subtitle: progress != "close_requested" ? const Text('Use button to add image. Tap & hold image to delete them.') : null,
        ),
        const ListTile(
          leading: Icon(Icons.assignment_return_outlined),
          title: Text('Returned Attachments'),
        ),
        Container(
          height: 120.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              progress != "close_requested" ? Container(
                width: 120.0,
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
                      imagePickerPrompt(context, 'return', woId, refresh);
                    },
                  ),
                ),
              ) : const SizedBox(width: 20,),
              ListView.builder(
                  reverse: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: listImage['return']?.length ?? 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        child: Container(
                          height: 100,
                          width: 100,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: Attachments.host + (listImage['return'][index]['name']),
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                        onLongPress: (){
                          if(progress != "close_requested"){
                            deleteAttachment(context, woId, listImage['return'][index]['name'], refresh, 'return');
                          }
                        },
                        onTap: () {
                          openGallery(context, List<dynamic>.from(listImage['return']), index);
                        });
                  }),
            ],
          ),
        ),
        const SizedBox(height: 30,)
      ],
    );
  }else{
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Attachments',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.start,
          ),
          subtitle: progress != "close_requested" ? const Text('Use button to add image. Tap & hold image to delete them.') : null,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: Icon(Icons.assignment),
                title: Text('Customer Signature  *'),
              ),
              Container(
                height: 120.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    progress != "close_requested" ? //No more uploading if close requested
                    Container(
                      width: 120.0,
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
                            imagePickerPrompt(context, 'sign', woId, refresh);
                          },
                        ),
                      ),
                    ) : const SizedBox(width: 5,),
                    ListView.builder(
                        reverse: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: listImage['sign']?.length ?? 0,
                        itemBuilder: (context, index) {
                          // if(listImage[index])
                          return GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: Attachments.host + (listImage['sign'][index]['name']),
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                              onLongPress: (){
                                if(progress != "close_requested"){
                                  deleteAttachment(context, woId, listImage['sign'][index]['name'], refresh, 'sign');
                                }
                              },
                              onTap: () {
                                openGallery(context, List<dynamic>.from(listImage['sign']), index);
                              });
                        }),
                  ],
                ),
              ),
              const ListTile(
                leading: Icon(Icons.network_check),
                title: Text('Speed Test *'),
              ),
              Container(
                height: 120.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    progress != "close_requested" ?
                    Container(
                      width: 120.0,
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
                            imagePickerPrompt(context, 'speedtest', woId, refresh);
                          },
                        ),
                      ),
                    ) : const SizedBox(width: 5,),
                    ListView.builder(
                        reverse: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: listImage['speedtest']?.length ?? 0,
                        itemBuilder: (context, index) {
                          // if(listImage[index])
                          return GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: Attachments.host + (listImage['speedtest'][index]['name']),
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                              onLongPress: (){
                                if(progress != "close_requested"){
                                  deleteAttachment(context, woId, listImage['speedtest'][index]['name'], refresh, 'speedtest');
                                }
                              },
                              onTap: () {
                                openGallery(context, List<dynamic>.from(listImage['speedtest']), index);
                              });
                        }),
                  ],
                ),
              ),
              const ListTile(
                leading: Icon(Icons.web_outlined),
                title: Text('Web Attachments'),
              ),
              Container(
                height: 120.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    progress != "close_requested" ?
                    Container(
                      width: 120.0,
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
                            imagePickerPrompt(context, 'web', woId, refresh);
                          },
                        ),
                      ),
                    ) : const SizedBox(width: 20,),
                    ListView.builder(
                        reverse: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: listImage['web']?.length ?? 0,
                        itemBuilder: (context, index) {
                          // if(listImage[index])
                          return GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: Attachments.host + (listImage['web'][index]['name']),
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                              onLongPress: (){
                                if(progress != "close_requested"){
                                  deleteAttachment(context, woId, listImage['web'][index]['name'], refresh, 'web');
                                }
                              },
                              onTap: () {
                                openGallery(context, List<dynamic>.from(listImage['web']), index);
                              });
                        }),
                  ],
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
      ],
    );
  }
}

void openGallery(BuildContext context, List<dynamic> urlImages, int index){
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
  final List<dynamic> urlImages;
  final int index;
  final PageController pageController;

  GalleryWidget({Key? key, required this.urlImages, required this.index}) : pageController = PageController(initialPage: index), super(key: key);

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
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
              final urlImage = '${Attachments.host}${widget.urlImages[index]['name']}';
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(urlImage),
              );
            }),
      );
}
