import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/pages/widgets/attachment_widget.dart';

snackbarMessage(BuildContext context, String? message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Expanded(child: Text(message ?? 'Missing')),
          const Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: const Duration(milliseconds: 3000),
    ),
  );
}

colorSnackbarMessage(BuildContext context, String? message, Color? color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Expanded(child: Text(message ?? 'Missing')),
          const Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
        ],
      ),
      backgroundColor: color ?? Colors.green,
      duration: const Duration(milliseconds: 2500),
    ),
  );
}

alertMessage(BuildContext context, String message) {
  AlertDialog alert = AlertDialog(
    contentPadding: const EdgeInsets.only(top: 10),
    content: ListTile(
      title: Text(message),
      leading: const Icon(Icons.error_outline),
    ),
    actions: <Widget>[
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            child: const Center(child: Text('Cancel')),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Center(child: Text('Confirm')),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ],
  );
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

loadingScreen(BuildContext context) {
  return Future.delayed(Duration.zero, () {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                Container(
                    margin: const EdgeInsets.only(left: 7),
                    child: const Text("Loading...")),
              ],
            ),
          );
        });
  });
}

loadingScreenText(BuildContext context, String msg, String? sub) {
  return Future.delayed(Duration.zero, () {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container(
                //     margin: const EdgeInsets.only(left: 7),
                //     child: Text(msg)),
                ListTile(
                  title: Text(msg),
                  subtitle: sub != null ? Text(sub ?? '') : null,
                  leading: const CircularProgressIndicator(),
                  contentPadding: EdgeInsets.zero,
                ),
                // const SizedBox(
                //   height: 20,
                // ),
                // const LinearProgressIndicator(),
              ],
            ),
          );
        });
  });
}

phonePromptDialog(BuildContext context, String contact) {
  AlertDialog alert = AlertDialog(
    title: const Text('Contact Customer'),
    insetPadding: EdgeInsets.zero,
    contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
    content: const Text('Carrier charges might apply. Proceed?'),
    actions: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () async {
              final Uri url = Uri.parse('tel:$contact');
              if (await canLaunchUrl(url)) {
                launchUrl(url);
              }
            },
          ),
        ],
      ),
    ],
  );
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

whatsappPromptDialog(BuildContext context, String contact) {
  AlertDialog alert = AlertDialog(
    title: const Center(
        child: FaIcon(
      FontAwesomeIcons.whatsapp,
      color: Colors.green,
      size: 48,
    )),
    // contentPadding: EdgeInsets.fromLTRB(24, 12, 0, 0),
    insetPadding: EdgeInsets.zero,
    contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
    alignment: Alignment.center,
    content: const Text('Opening external application. Proceed?'),
    actions: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () async {
              Navigator.pop(context);
              final Uri url = Uri.parse('https://wa.me/$contact');
              if (await canLaunchUrl(url)) {
                launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      )
    ],
  );
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

mapPromptDialog(BuildContext context, String address) {
  AlertDialog alert = AlertDialog(
    title: const Text('Coordinate Error'),
    content: const Text(
        'Map coordinate is missing. Search will be based on address name.'),
    actions: <Widget>[
      TextButton(
        style: ElevatedButton.styleFrom(
            //primary: Colors.red,
            ),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.red),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      TextButton(
        child: const Text('OK'),
        onPressed: () {
          Navigator.pop(context);
          MapUtils.openMapString(address);
        },
      ),
    ],
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

imagePickerPrompt(BuildContext context, String type, num woId,
    Function(Map, String) refresh) {
  AlertDialog alert = AlertDialog(
    title: const Text('Select image source'),
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.add_a_photo_outlined),
          title: const Text(
            'Camera',
            textAlign: TextAlign.start,
          ),
          onTap: () async {
            bool ok = true;
            Navigator.pop(context);
            final XFile? image = await ImagePicker()
                .pickImage(source: ImageSource.camera, imageQuality: 25);
            if (image!.path.isNotEmpty) {
              try {
                loadingScreen(context);
                refresh(
                    await WorkOrderApi.uploadImgAttachment(type, image, woId),
                    'upload');
              } catch (e) {
                print(e);
                colorSnackbarMessage(
                    context,
                    'Failed to upload image. Please contact admin if issue persists',
                    Colors.red);
                ok = false;
              } finally {
                if (ok) {
                  // snackbarMessage(context, 'Image uploaded');
                }
              }
            } else {
              colorSnackbarMessage(
                  context, 'No image was selected.', Colors.red);
              return;
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_photo_alternate_outlined),
          title: const Text(
            'Gallery',
            textAlign: TextAlign.start,
          ),
          onTap: () async {
            Navigator.pop(context);
            final List<XFile> image =
                await ImagePicker().pickMultiImage(imageQuality: 25);
            if (image.isNotEmpty) {
              try {
                loadingScreen(context);
                refresh(
                    await WorkOrderApi.uploadMultiImgAttachment(
                        type, image, woId),
                    'upload');
              } catch (e) {
                print(e);
                colorSnackbarMessage(
                    context,
                    'Failed to upload image. Please contact admin if issue persists',
                    Colors.red);
              }
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
}

deleteAttachment(BuildContext context, num woId, String img,
    Function(Map, String) refresh, String type) {
  AlertDialog alert = AlertDialog(
    titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
    actionsPadding: EdgeInsets.zero,
    title: const ListTile(
      title: Text('Delete image?'),
      leading: Icon(Icons.error_outline),
    ),
    actions: <Widget>[
      // const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            child: const Center(child: Text('Cancel')),
            onPressed: () async {
              Navigator.pop(context);
              return;
            },
          ),
          TextButton(
            child: const Center(child: Text('Confirm')),
            onPressed: () async {
              bool ok = true;
              Navigator.pop(context);
              try {
                loadingScreen(context);
                refresh(await WorkOrderApi.deleteImgAttachment(woId, img, type),
                    'delete');
              } catch (e) {
                Navigator.pop(context);
                colorSnackbarMessage(
                    context,
                    'Failed to delete image. Please contact admin if issue persists',
                    Colors.red);
                ok = false;
              } finally {
                if (ok) {
                  // snackbarMessage(context, 'Successfully deleted');
                }
              }
            },
          ),
        ],
      ),
    ],
  );
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<bool> resetPasswordPrompt(BuildContext context, String email) async {
  Completer<bool> completer = Completer<bool>();
  AlertDialog alert = AlertDialog(
    iconColor: Colors.indigo,
    icon: Icon(Icons.warning_amber, size:120,),
    // title: Center(child: const Text('Confirm')),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      Text('You are resetting password for:'),
      SizedBox(height: 10,),
      Text(email, style: const TextStyle(color: Colors.indigo),),
    ],),
    actionsAlignment: MainAxisAlignment.spaceEvenly,
    actions: <Widget>[
      TextButton(
        style: ElevatedButton.styleFrom(
            //primary: Colors.red,
            ),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.red),
        ),
        onPressed: () {
          completer.complete(false);
          Navigator.pop(context, false);
        },
      ),
      TextButton(
        child: const Text('Confirm'),
        onPressed: () {
          loadingScreenText(
              context, "Resetting password...", "Please wait for a while");
          completer.complete(true);
          Navigator.pop(context, true);
        },
      ),
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
  return completer.future;
}
