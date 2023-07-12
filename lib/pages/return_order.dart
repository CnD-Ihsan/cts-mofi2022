import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/pages/widgets/message_widgets.dart';

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
  String returnType = 'Customer Unavailable';
  String remarks = '';
  List<XFile?> listImage = [];
  List<String> listReturnTypes = [
    'Customer Unavailable',
    'Wrong Address',
    'Activation Failure',
    'Technical Issues',
    'Other'
  ];
  var response;

  int _index = 0;
  late PageController _pageController = PageController(initialPage: _index);
  var remarkController = TextEditingController();

  final GlobalKey<FormState> _returnFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    remarkController.dispose();

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
    if(widget.type == "TT"){
      listReturnTypes.remove('Activation Failure');
    }
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
                const SizedBox(height: 16),
                const Text('Return Type'),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  key: const Key('returnTypeDropdown'),
                  value: returnType,
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
                const SizedBox(height: 32),
                const Text('Remarks *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: remarkController,
                  onSaved: (input) =>
                      remarkController.text = input ?? "Empty remarks",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Remarks required!';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Enter remarks',
                      // hintText: 'Enter remarks',
                      border: UnderlineInputBorder()),
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
                            widget.ftthId, widget.type, returnType, remarkController.text, listImage);
                        print(response);
                        if (mounted) {
                          if (response.statusCode >= 200 && response.statusCode <= 300) {
                            snackbarMessage(
                                context, "Order Succesfully returned!");
                            // Navigator.popUntil(
                            //     context, (route) => route.isFirst);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  settings: const RouteSettings(
                                    name: "/show",
                                  ),
                                  builder: (context) =>
                                      ShowServiceOrder(
                                        orderID: widget.woId,
                                      )),
                            );
                          } else {
                            Navigator.pop(context);
                            colorSnackbarMessage(
                                context, "Return failed! Contact admin if issue persists.", Colors.red);
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
