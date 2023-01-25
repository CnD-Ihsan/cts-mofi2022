import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class AttachmentUtils {
  AttachmentUtils._();
  static Future openMap(XFile img, num woId) async {

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

class MapUtils {
  MapUtils._();
  static Future openMap(double? latitude, double? longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
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
      await launchUrl(url);
    } else {
      throw 'Could not open the map.';
    }
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
      throw 'Could get Speed Test.';
    }
  }
}