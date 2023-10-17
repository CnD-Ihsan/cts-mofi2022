import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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