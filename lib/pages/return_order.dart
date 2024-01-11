import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

import 'map_screen.dart';

class ReturnOrder extends StatefulWidget {
  final num woId;
  final num ftthId;
  final String type;
  final Function(Map, String) refresh;

  const ReturnOrder(
      {Key? key, required this.woId, required this.ftthId, required this.type, required this.refresh})
      : super(key: key);

  @override
  State<ReturnOrder> createState() => _ReturnOrderState();
}

class _ReturnOrderState extends State<ReturnOrder> {
  String returnType = '-';
  String remark = '';
  List<XFile?> listImage = [];
  List<String> listReturnTypes = [
    '-',
    'Due to CT Sabah',
    'Due to Customer',
    'Due to ISP',
    'Due to Wrong Address',
  ];
  var response;

  int _index = 0;
  late PageController _pageController = PageController(initialPage: _index);
  var remarkController = TextEditingController();
  var latController = TextEditingController();
  var lngController = TextEditingController();
  late LatLng? latLngVal;

  final GlobalKey<FormState> _returnFormKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _latFormKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _lngFormKey = GlobalKey<FormFieldState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    remarkController.dispose();
    latController.dispose();
    lngController.dispose();
    _pageController.dispose();

    for (var file in listImage) {
      File(file!.path).delete().then((_) {
        print('File deleted successfully: ${file.path}');
      }).catchError((error) {
        print('Failed to delete the file: ${file.path}, Error: $error');
      });
    }

    super.dispose();
  }

  @override
  void initState() {
    // if(widget.type == "TT"){
    //   listReturnTypes.remove('Activation Failure');
    // }
    _pageController = PageController(initialPage: _index);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.key,
      appBar: AppBar(
        title: const Text('Return Order'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _returnFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const SizedBox(height: 16),
                // const Text('* indicates required fields.', style: TextStyle(color: Colors.black54),),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  key: const Key('returnTypeDropdown'),
                  value: returnType,
                  validator: (value){
                    if(value == '-' || value == null){
                      return 'Please select a return type';
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Return Type *",
                    hintText: 'Choose return type.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      returnType = value!;
                    });
                  },
                  items: listReturnTypes.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Container(
                  child: returnType.contains("Wrong Address") ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Tap to select new address'),
                        leading: const Icon(Icons.map),
                        onTap: () async {
                          if(await _handlePermission()){
                            if(mounted){
                              latLngVal = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    settings: const RouteSettings(
                                      name: "/mapScreen",
                                    ),
                                    builder: (context) => const MapScreen()),
                              );
                              latController.text = latLngVal?.latitude.toString() ?? "";
                              lngController.text = latLngVal?.longitude.toString() ?? "";
                              _latFormKey.currentState!.validate();
                              _lngFormKey.currentState!.validate();
                              setState(() {
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: _latFormKey,
                        controller: latController,
                        readOnly: true,
                        canRequestFocus: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Latitude required.';
                          }
                          return null;
                        },
                        decoration:  const InputDecoration(
                            border: InputBorder.none,
                            labelText: "Latitude *"
                        ),
                      ),
                      TextFormField(
                        key: _lngFormKey,
                        controller: lngController,
                        readOnly: true,
                        canRequestFocus: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Longitude required.';
                          }
                          return null;
                        },
                        decoration:  const InputDecoration(
                          border: InputBorder.none,
                          labelText: "Longitude *",
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ) : const SizedBox(),
                ),
                // const Text('Remark *'),
                const SizedBox(height: 16),
                TextFormField(
                  maxLines: 4,
                  controller: remarkController,
                  onSaved: (input) =>
                      remarkController.text = input ?? "Empty remark",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Remark required.';
                    }
                    return null;
                  },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Remark *",
                      hintText: 'Enter remark (required)',
                    ),
                ),
                const SizedBox(height: 32),
                const Text('Attach Image (optional)'),
                const SizedBox(height: 8),
                Container(
                  height: 80.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      Container(
                        width: 100.0,
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
                              AlertDialog alert = AlertDialog(
                                title: const Text('Select image source'),
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                          Icons.add_a_photo_outlined),
                                      title: const Text(
                                        'Camera',
                                        textAlign: TextAlign.start,
                                      ),
                                      onTap: () async {
                                        bool ok = true;
                                        Navigator.pop(context);
                                        final XFile? image = await ImagePicker()
                                            .pickImage(
                                                source: ImageSource.camera,
                                                imageQuality: 25);
                                        if (image!.path.isNotEmpty) {
                                          setState(() {
                                            listImage.add(image);
                                          });
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                          Icons.add_photo_alternate_outlined),
                                      title: const Text(
                                        'Gallery',
                                        textAlign: TextAlign.start,
                                      ),
                                      onTap: () async {
                                        bool ok = true;
                                        Navigator.pop(context);
                                        final List<XFile> image =
                                            await ImagePicker().pickMultiImage(
                                                imageQuality: 25);
                                        if (image.isNotEmpty) {
                                          setState(() {
                                            for (var element in image) {
                                              listImage.add(element);
                                            }
                                          });
                                        } else {
                                          return;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                              showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      ListView.builder(
                          reverse: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: listImage.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child:
                                      Image.file(File(listImage[index]!.path)),
                                ),
                                onLongPress: () {
                                  listImage.removeAt(index);
                                  setState(() {});
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => Scaffold(
                                              body: PhotoViewGallery.builder(
                                                  pageController:
                                                      _pageController,
                                                  onPageChanged: (index) => {
                                                        setState(() =>
                                                            _index = index),
                                                      },
                                                  itemCount: listImage.length,
                                                  builder: (context, index) {
                                                    return PhotoViewGalleryPageOptions(
                                                      imageProvider: FileImage(
                                                          File(listImage[index]!
                                                              .path)),
                                                    );
                                                  }),
                                            )),
                                  );
                                });
                          }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if ((_returnFormKey.currentState?.validate() ?? false)) {
                        showLoaderDialog(context);
                        response = await WorkOrderApi.returnOrder(widget.woId,
                            widget.ftthId, widget.type, returnType, remarkController.text, latController.text, lngController.text,listImage);
                        if (mounted) {
                          if (response.statusCode >= 200 && response.statusCode <= 300) {
                            Navigator.pop(context);
                            snackbarMessage(
                                context, "Order was succesfully returned.");
                            Navigator.pop(context, widget.woId);
                          } else {
                            Navigator.pop(context);
                            colorSnackbarMessage(
                                context, "Return failed. Contact admin if issue persists.", Colors.red);
                          }
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      AlertDialog alert = AlertDialog(
        icon: const Icon(Icons.location_disabled),
        title: const Text('Location Service Unavailable'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        content: const Text('This action requires that the location service (GPS) is enabled. Please turn on location service before proceeding.', textAlign: TextAlign.justify,),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Container(
              //   child: TextButton(
              //     child: const Text(
              //       'Cancel',
              //       style: TextStyle(color: Colors.red),
              //     ),
              //     onPressed: () async {
              //       Navigator.pop(context);
              //     },
              //   ),
              // ),
              TextButton(
                child: const Text('Open Setting'),
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                },
              ),
            ],
          ),
        ],
      );
      if(mounted){
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        AlertDialog alert = AlertDialog(
          icon: const Icon(Icons.back_hand_outlined),
          title: const Text('Permission Denied'),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          content: const Text('This action requires access to your device location. Please allow location permission.'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('Open App Setting'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openAppSettings();
                  },
                ),
              ],
            ),
          ],
        );
        if(mounted){
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      AlertDialog alert = AlertDialog(
        icon: const Icon(Icons.back_hand_outlined),
        title: const Text('Permission Denied'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        content: const Text('This action requires access to your device location. Please allow location permission.'),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text('Open App Setting'),
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openAppSettings();
                },
              ),
            ],
          ),
        ],
      );
      if(mounted){
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }
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
