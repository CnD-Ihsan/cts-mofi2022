import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/base_api.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:wfm/models/so_model.dart';
import 'package:wfm/models/tt_model.dart';
import 'package:http/http.dart' as http;

class WorkOrderApi extends BaseApi {
  static final wfmHost = dotenv.env['WFM_HOST'];
  static final appVersion = dotenv.env['VERSION'] ?? "0.0.0";

  static Future<List<WorkOrder>> getWorkOrderList() async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/all');
    List<WorkOrder> workOrderList = [];

    try{
      final response = await http.get(uri, headers: BaseApi.apiHeaders).timeout(const Duration(seconds:10));
      var jsonData = jsonDecode(response.body);
      print(BaseApi.apiHeaders);
      print(response.body);

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
          ftthId: data['ftth_order_id'],
          woName: data['name'],
          status: data['status'],
          requestedBy: data['requested_by'],
          address: data['cust_addr_name'],
          startDate: data['start_date'],
          date: tempDate,
          time: tempTime,
          group: data['group'],
          type: data['type'],
          closedAt: data['closed_at']
        );
        workOrderList.add(wo);
      }
      return workOrderList;
    }catch(e){
      print(e);
    }

    return workOrderList;
  }

  static Future<ServiceOrder> getServiceOrder(num id) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/show');

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: {"id": id.toString(),},
    );

    Map data = jsonDecode(response.body);
    String? tempDate;
    String? tempTime;

    if (data.containsKey('appointment_date') &&
        data['appointment_date'] != null) {
      DateFormat df = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime dt = df.parse("${data['appointment_date']} ${data['appointment_time']}");
      tempDate = DateFormat.yMMMMd('en_US').format(dt).toString();
      tempTime = DateFormat.jm().format(dt).toString();
    }

    return ServiceOrder(
      soId: data['so_id'],
      soName: data['crm_no'],
      status: data['status'],
      requestedBy: data['requested_by'],
      address: data['address'],
      startDate: data['appointment_date'],
      time: tempTime,
      date: tempDate,
      img: await getImgAttachments(id),
      lat: double.parse(data['latitude']),
      lng: double.parse(data['longitude']),
      ontSn: data['ont_sn'] ?? "Terminated",
      rgwSn: data['hc'] != null ? data['hc']['rgw_sn'] : "Terminated",
      speedTest: data['speed_test'],
      custContact: data['cust_contact'],
      custName: data['cust_name'],
      carrier: data['carrier'],
      speed: data['package'],
      progress: data['progress'],
      desc: data['description'],
      remark: data['remark'],
    );
  }

  static Future<TroubleshootOrder> getTroubleshootOrder(num id) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/show');

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: {"id": id.toString(),},
    );

    Map data = jsonDecode(response.body);

    String? tempDate;
    String? tempTime;

    if (data.containsKey('appointment_date') &&
        data['appointment_date'] != null) {
      DateFormat df = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime dt = df.parse("${data['appointment_date']} ${data['appointment_time']}");
      tempDate = DateFormat.yMMMMd('en_US').format(dt).toString();
      tempTime = DateFormat.jm().format(dt).toString();
    }

    return TroubleshootOrder(
      ttId: data['tt_id'],
      ttNo: data['tt_no'],
      status: data['status'],
      isp: data['carrier'],
      description: data['description'],
      address: data['address'],
      startDate: data['appointment_date'],
      time: tempTime,
      date: tempDate,
      img: await getImgAttachments(id),
      lat: double.parse(data['latitude']),
      lng: double.parse(data['longitude']),
      ontSn: data['ontsn'],
      custContact: data['cust_contact'],
      custName: data['cust_name'],
      speed: data['package_speed'],
      progress: data['progress'],

      rootCause: data['root_cause'],
      ontChange: data['ont_change'],
      subCause: data['sub_cause'],
      speedTest: data['speed_test'],
      actionTaken: data['action_taken'],
      faultLocation: data['fault_location'],
      remark: data['remark'],
    );
  }


  static soCompleteOrder(num woId, String? ontSn, String? rgwSn, String? speedTest) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/so-request-complete');

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: {
        "wo_id": woId.toString(),
        "ont_sn": ontSn,
        "rgw_sn": rgwSn,
        "speed_test": speedTest
      },
    );

    Map temp = {};

    if(response.statusCode >= 200 && response.statusCode <= 300){
      try {
        temp = json.decode(response.body);
      } on FormatException catch (e) {
        temp = {"error" : "The provided string is not a valid JSON"};
      }
    }else{
      temp = {"error" : "Status code: ${response.statusCode}"};
    }
    return temp;
  }

  static ttCompleteOrder(num ttId, String rootCause, String? subCause, String? faultLocation, String speedTest, String actionTaken, String? ontChange, String? ontSn) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/tt-request-complete');

    Map jsonOnt = {
      "tt_id": ttId.toString(),
      "root_cause": rootCause,
      "sub_cause": subCause,
      "fault_location": faultLocation,
      "speed_test": speedTest,
      "action_taken": actionTaken,
    };

    if(ontChange == "Approved"){
      jsonOnt["ont_sn"] = ontSn;
    }

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: jsonOnt,
    );

    Map tempMessage = {};

    try {
      tempMessage = json.decode(response.body);
    } on FormatException catch (e) {
      tempMessage = {"error" : "The provided string is not a valid JSON"};
    }

    if(response.statusCode < 200 || response.statusCode >= 300){
      if(tempMessage.containsKey('errorMessage')){
        tempMessage = {"error" : "Error: ${tempMessage['errorMessage']}"};
      }else if(tempMessage.containsKey('message')){
        tempMessage = {"error" : "Error: ${tempMessage['message']}"};
      }else{
        tempMessage = {"error" : "Error: Unknown error."};
      }
    }

    return tempMessage;
  }

  static returnOrder(num woId, num ftthId, String? ftthType, String? returnType, String? remark, String? latitude, String? longitude,List<XFile?> listImage) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/return-order/$woId');

    Map jsonOnt = {
      "returnType": returnType,
      "remark": remark,
    };

    if(returnType!.contains("Wrong Address")){
      jsonOnt["latitude"] = latitude;
      jsonOnt["longitude"] = longitude;
    }

    ftthType == 'SO'
        ? jsonOnt['soId'] = ftthId.toString()
        : jsonOnt['ttId'] = ftthId.toString();

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: jsonOnt,
    );

    if(response.statusCode >= 200 && response.statusCode <= 300){
      if(listImage.isNotEmpty){
        try{
          await uploadMultiImgAttachment('return', listImage, woId);
        }catch(e){
          return e;
        }
      }
    }
    return response;
  }

  static soReturnOrder(num woId, num soId, String? returnType, String? remarks, List<XFile?> listImage) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/so-request-return/$woId');

    Map jsonOnt = {
      "soId": soId,
      "returnType": returnType,
      "remarks": remarks
    };

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: jsonEncode(jsonOnt),
    );

    if(response.statusCode >= 200 && response.statusCode <= 300){
      try{
        return await uploadMultiImgAttachment('return', listImage, woId);
      }catch(e){
        return "Error: Failed to upload attachment. Please retry later.";
      }
    }else{
      return "Error: Failed to establish connection to server";
    }
  }

  static ttReturnOrder(num woId, num ttId, String? returnType, String? remarks, List<XFile?> listImage) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/tt-request-return/$woId');

    Map jsonOnt = {
      "ttId": ttId,
      "returnType": returnType,
      "remarks": remarks
    };

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: jsonEncode(jsonOnt),
    );

    if(response.statusCode >= 200 && response.statusCode <= 300){
      try{
        return await uploadMultiImgAttachment('return', listImage, woId);
      }catch(e){
        return "Error: Failed to upload attachment. Please retry later.";
      }
    }else{
      return "Error: Failed to establish connection to server";
    }
  }

  static uploadImgAttachment(String type, XFile? img, num id) async {

    File file = File(img!.path);
    final String newFileName = '${type}_${DateTime.now().millisecondsSinceEpoch}';
    final String directoryPath = file.path.split('/').sublist(0, file.path.split('/').length - 1).join('/');
    final File renamedFile = await file.rename('$directoryPath/$newFileName');

    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/upload-image/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      "Version": BaseApi.appVersion,
      "Authorization": "Bearer $token",
    });
    request.fields.addAll({"type": type});

    request.files
        .add(await http.MultipartFile.fromPath('attachment[]', renamedFile.path));

    var response = await request.send();

    if (response.statusCode >= 200 && response.statusCode <= 300) {
      file.delete().then((_) {
        print('File deleted successfully');
      }).catchError((error) {
        print('Failed to delete the file: $error');
      });
      return getImgAttachments(id);
    } else {
      return response;
    }
  }

  static uploadMultiImgAttachment(String type, List<XFile?> imgList, num id) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/upload-image/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      "Version": BaseApi.appVersion,
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

  static deleteImgAttachment(num id, String path, String type) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/remove_image/$id/$path');

    try{
      var response = await http.post(uri, headers: BaseApi.apiHeaders,
          body: {
            'type' : type,
          });

      if (response.statusCode >= 200 && response.statusCode <= 300) {
        return getImgAttachments(id);
      } else {
        return response;
      }
    }catch(e){
      print(e);
    }
  }

  static getImgAttachments(num id) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/get-image');

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: {
        'wo_id': id.toString(),
      }
    );

    Map img = json.decode(response.body);
    return img;
  }

  static activateOnt(num woId, String? ontSn) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/submitOnt');

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: {
        "wo" : woId.toString(),
        "ontsn": ontSn
      },
    );

    Map temp = json.decode(response.body);
    return temp;
  }

  static ontChangeRequest(num woId) async {
    var uri = Uri.parse('${BaseApi.wfmHost}/work-orders/tt-request-ont-change');

    final response = await http.post(
      uri,
      headers: BaseApi.apiHeaders,
      body: {
        "wo_id" : woId.toString(),
      },
    );

    return response;
  }
}
