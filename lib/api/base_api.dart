import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseApi {
  static final wfmHost = dotenv.env['WFM_HOST'];
  static final appVersion = dotenv.env['VERSION'] ?? "0.0.0";
  static final wfmImageHost = "${wfmHost!}/work-orders/order-image/";
  static final apiHeaders = {
    "useQueryString": "true",
    "version": appVersion,
    "Content": "application/json",
    "Accept": "application/json",
    "Authorization": "",
  };
}
