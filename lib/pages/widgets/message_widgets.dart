import 'package:flutter/material.dart';
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
      duration: const Duration(milliseconds: 2000),
    ),
  );
}

redSnackbarMessage(BuildContext context, String? message) {
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
      backgroundColor: Colors.red,
      duration: const Duration(milliseconds: 2000),
    ),
  );
}

alertMessage(BuildContext context, String message) {
  AlertDialog alert = AlertDialog(
    content: ListTile(
      title: Text(message),
      leading: const Icon(Icons.error_outline),
    ),
    actions: <Widget>[
      const Divider(),
      TextButton(
        child: const Center(child: Text('Confirm')),
        onPressed: () {
          Navigator.pop(context);
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

loadingScreen(BuildContext context){
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

imagePickerPrompt(BuildContext context, String type, num woId, Function(List<String>) refresh) {
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
              try{
                refresh(await WorkOrderApi.uploadImgAttachment(type, image, woId));
              }catch(e){
                print(e);
                redSnackbarMessage(context, 'Failed to upload image. Please contact admin if issue persists');
                ok = false;
              }finally{
                if(ok){
                  snackbarMessage(context, 'Image uploaded');
                }
              }
            } else {
              redSnackbarMessage(context, 'No image was selected.');
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
            bool ok = true;
            Navigator.pop(context);
            final List<XFile> image =
                await ImagePicker().pickMultiImage(imageQuality: 25);
            if (image!.isNotEmpty) {
              try{
                refresh(await WorkOrderApi.uploadMultiImgAttachment(type, image, woId));
              }catch(e){
                print(e);
                redSnackbarMessage(context, 'Failed to upload image. Please contact admin if issue persists');
                ok = false;
              }finally{
                if(ok){
                  snackbarMessage(context, 'Image uploaded');
                }
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

deleteAttachment(BuildContext context, num woId, String img, Function(List<String>) refresh) {
  AlertDialog alert = AlertDialog(
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
              try{
                refresh(await WorkOrderApi.deleteImgAttachment(woId, img));
              }catch(e){
                redSnackbarMessage(context, 'Failed to delete image. Please contact admin if issue persists');
                ok = false;
              }finally{
                if(ok){
                  snackbarMessage(context, 'Successfully deleted');
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