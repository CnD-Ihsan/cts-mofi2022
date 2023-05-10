import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:http/http.dart' as http;

class WorkOrderApi {
  static var wfmHost = '80.80.2.254:8080';

  static Future<WorkOrder> getWorkOrder(num id, String type) async {
    var uri =
        Uri.http(wfmHost, '/api/work-orders/show');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map dataSend = {
      "id": id,
      "returnType": type,
    };

    final response = await http.post(
      uri,
      headers: {
        "useQueryString": "true",
        "Content-Type": "application/json",
        "Authorization" : "Bearer $token",
      },
      body: jsonEncode(dataSend),
    );

    Map data = jsonDecode(response.body);

    String? tempDate;
    String? tempTime;

    if (data.containsKey('appointment_date') &&
        data['appointment_date'] != null) {
      DateFormat df = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime dt = DateTime.parse(data['appointment_date']);
      tempDate = DateFormat.yMMMMd('en_US').format(dt).toString();
      tempTime = DateFormat.jm().format(dt).toString();
    }

    return WorkOrder(
      woId: id,
      soId: data['so_id'],
      woName: data['crm_no'],
      status: data['status'],
      requestedBy: data['requested_by'],
      address: data['address'],
      startDate: data['appointment_date'],
      time: tempTime,
      date: tempDate,
      img: await getImgAttachments(id),
      lat: double.parse(data['latitude']),
      lng: double.parse(data['longitude']),
      ontSn: data['ont_sn'],
      custContact: data['cust_contact'],
      custName: data['cust_name'],
      carrier: data['carrier'],
      speed: data['package'],
      progress: data['progress'],
    );
  }

  static Future<List<WorkOrder>> getWorkOrderList() async {
    var uri = Uri.http(wfmHost, '/api/work-orders/all');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');

    final response = await http.get(uri, headers: {
      "useQueryString": "true",
      "Content-Type": "application/json",
      // "Authorization": "Bearer $token",
    });

    List<WorkOrder> workOrderList = [];
    var jsonData = jsonDecode(response.body);
    String? tempDate;
    String? tempTime;
    for (var data in jsonData) {
      if (data.containsKey('start_date') && data['start_date'] != null) {
        DateFormat df = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime dt = df.parse(data['start_date']);
        tempDate = DateFormat.MMMMd('en_US').format(dt).toString();
        tempTime = DateFormat.jm().format(dt).toString();
      }

      WorkOrder wo = WorkOrder(
        woId: data['wo_id'],
        soId: data['service_order'],
        woName: data['name'],
        status: data['status'],
        requestedBy: data['requested_by'],
        address: data['cust_addr_name'],
        date: tempDate,
        time: tempTime,
        group: data['group'],
        type: data['type'],
      );
      workOrderList.add(wo);
    }
    return workOrderList;
  }

  static completeOrder(num soId, String? ontSn) async {
    var uri = Uri.http(wfmHost, '/api/work-orders/request-complete');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');

    Map jsonOnt = {"so_id": soId, "ont_sn": ontSn};

    final response = await http.post(
      uri,
      headers: {
        "useQueryString": "true",
        "Content-Type": "application/json",
        "Accept": "application/json",
        // "Authorization" : "Bearer $token",
      },
      body: jsonEncode(jsonOnt),
    );

    Map temp = {};

    if(response.statusCode >= 200 && response.statusCode <= 300){
      try {
        temp = json.decode(response.body);
      } on FormatException catch (e) {
        temp = {"error" : "The provided string is not valid JSON"};
      }
    }else{
      temp = {"error" : "Status code: ${response.statusCode}"};
    }

    return temp;
  }

  static returnOrder(num woId, num soId, String? returnType, String? remarks, List<XFile?> listImage) async {
    var uri = Uri.http(wfmHost, '/api/work-orders/request-return/$woId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map jsonOnt = {
      "soId": soId,
      "returnType": returnType,
      "remarks": remarks
    };

    final response = await http.post(
      uri,
      headers: {
        "useQueryString": "true",
        "Content-Type": "application/json",
        "Authorization" : "Bearer $token",
      },
      body: jsonEncode(jsonOnt),
    );

    if(response.statusCode >= 200 && response.statusCode <= 300){
      try{
        return await uploadMultiImgAttachment('return', listImage, woId);
      }catch(e){
        return "Error: Failed to upload attachment. Please retry later.";
      }
      return "Success: Return Order Requested.";
    }else{
      return "Error: Failed to establish connection to server";
    }
  }

  static uploadImgAttachment(String type, XFile? img, num id) async {

    File file = File(img!.path);
    final String newFileName = '${type}_${DateTime.now().millisecondsSinceEpoch}';
    final String directoryPath = file.path.split('/').sublist(0, file.path.split('/').length - 1).join('/');
    final File renamedFile = await file.rename('$directoryPath/$newFileName');

    var uri = Uri.http('80.80.2.254:8080', '/api/work-orders/upload-image/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      "Authorization": "Bearer $token",
    });
    request.fields.addAll({"type": type});

    request.files
        .add(await http.MultipartFile.fromPath('attachment[]', renamedFile.path));

    var response = await request.send();

    if (response.statusCode >= 200 && response.statusCode <= 300) {
      return getImgAttachments(id);
    } else {
      return response;
    }
  }

  static deleteImgAttachment(num id, String path, String type) async {
    var uri =
        Uri.http(wfmHost, '/api/work-orders/remove_image/$id/$path');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var response = await http.post(uri, headers: {
      "Authorization": "Bearer $token",
    },
    body: {'type' : type});

    if (response.statusCode >= 200 && response.statusCode <= 300) {
      return getImgAttachments(id);
    } else {
      return response;
    }
  }

  static uploadMultiImgAttachment(String type, List<XFile?> imgList, num id) async {
    var uri = Uri.http(wfmHost, '/api/work-orders/upload-image/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      "Authorization": "Bearer $token",
    });
    request.fields.addAll({"type": type});

    // List<http.MultipartFile> files = [];
    for (var img in imgList) {

      File file = File(img!.path);
      final String newFileName = '${type}_${DateTime.now().millisecondsSinceEpoch}';
      final String directoryPath = file.path.split('/').sublist(0, file.path.split('/').length - 1).join('/');
      final File renamedFile = await file.rename('$directoryPath/$newFileName');

      request.files.add(
          await http.MultipartFile.fromPath('attachment[]', renamedFile.path));
    }

    var response = await request.send();

    if (response.statusCode >= 200 && response.statusCode <= 300) {
      return getImgAttachments(id);
    } else {
      return response;
    }
  }

  static getImgAttachments(num id) async {
    var uri = Uri.http(wfmHost, '/api/work-orders/get-image',
        {'wo_id': id.toString()});

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print(response.body.toString());
    Map img = json.decode(response.body);
    return img;
  }

  static activateOnt(num woId, String? ontSn) async {
    var uri = Uri.http(wfmHost, '/api/work-orders/submitOnt');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map jsonOnt = {
      "wo" : woId,
      "ontsn": ontSn
    };

    final response = await http.post(
      uri,
      headers: {
        // "useQueryString": "true",
        "Accept": "application/json",
        "Content-Type": "application/json",
        // "Authorization": "Bearer $token",
      },
      body: jsonEncode(jsonOnt),
    );

    Map temp = json.decode(response.body);
    return temp;
  }
}
