import 'package:flutter/material.dart';
import 'package:wfm/api/utils.dart';
import 'package:wfm/api/work_order_api.dart';
import 'package:image_picker/image_picker.dart';

snackbarMessage(BuildContext context, String? message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Text(message ?? 'Missing'),
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

imagePickerPrompt(BuildContext context, String type, num woId) {
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
            Navigator.pop(context);
            final XFile? image = await ImagePicker()
                .pickImage(source: ImageSource.camera);
            if(image!.path.isNotEmpty){
              WorkOrderApi.attachImg(type, image, woId);
            }else{
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
            final XFile? image = await ImagePicker()
                .pickImage(source: ImageSource.gallery);
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
