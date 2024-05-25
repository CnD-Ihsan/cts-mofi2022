import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfm/api/auth_api.dart';

class AttachmentUtils {
  AttachmentUtils._();
  static Future deleteImgAttachment(num woId, String img) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=';
    Uri url = Uri.parse(googleUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not open the map.';
    }
  }

  static Future openMapString(String? query) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    Uri url = Uri.parse(googleUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode:LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }
}

class MapUtils {
  MapUtils._();
  static Future openMap(double? latitude, double? longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    Uri url = Uri.parse(googleUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode:LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  static Future openMapString(String? query) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    Uri url = Uri.parse(googleUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not open the map.';
    }
  }
}

class CameraUtils {
  CameraUtils._();

  static Future<String> getScanRes() async {
    return await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.BARCODE);
  }
}

class SpeedTestUtils {
  SpeedTestUtils._();
  static Future runSpeedTest() async {
    String googleUrl = 'https://speed.cloudflare.com/';
    Uri url = Uri.parse(googleUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not open Speed Test.';
    }
  }
}

class PermissionHandlerUtils{
  void checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      // Notification permission is granted
      // Proceed with app initialization
    } else {
      // Notification permission is not granted
      // Request permission from the user
      PermissionStatus permissionStatus = await Permission.notification.request();
      if (permissionStatus.isGranted) {
        // Notification permission granted by the user
        // Proceed with app initialization
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if(prefs.containsKey('user')){
          AuthApi.logOut(prefs.getString('email'), prefs.getString('fcm_token'));
        }else{

        }
        // Notification permission denied by the user
        // Handle accordingly (e.g., show a message, disable certain features)
      }
    }
  }


}