import 'package:flutter/material.dart';
import 'package:wfm/api/utils.dart';

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
