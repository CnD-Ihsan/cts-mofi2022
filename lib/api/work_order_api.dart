import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:http/http.dart' as http;

class WorkOrderApi{

  static Future<WorkOrder> getWorkOrder(num id) async {
    //id = '194';
    var uri = Uri.http('80.80.0.86:80', '/api/serviceorder/show-work-order/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(uri, headers: {
      "useQueryString" : "true",
      "Content-Type": "application/json",
      "Authorization" : "Bearer $token",
    });

    Map data = jsonDecode(response.body);

    String? tempDate;
    String? tempTime;

    if(data.containsKey('appointment_date') && data['appointment_date'] != null){
      DateFormat df = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime dt = DateTime.parse(data['appointment_date']);
      tempDate = DateFormat.yMMMMd('en_US').format(dt).toString();
      tempTime = DateFormat.jm().format(dt).toString();
    }

    return WorkOrder(
        woId: num.parse(data['work_order']),
        soId: data['so_id'],
        woName: data['crm_no'],
        status: data['status'],
        requestedBy: data['requested_by'],
        address: data['address'],
        startDate: data['appointment_date'],
        time: tempTime,
        date: tempDate,
        img: await getImgAttachments(data['wo_id']),
        lat: double.parse(data['latitude']),
        lng: double.parse(data['longitude']),

        ontSn: data['ont_sn'],
        custContact: data['cust_contact'],
        carrier: data['carrier'],
        speed: data['package'],
    );
  }

  static Future<List<WorkOrder>> getWorkOrderList() async {
    var uri = Uri.http('80.80.2.254:8080', '/api/workorder/all');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(uri, headers: {
      "useQueryString" : "true",
      "Content-Type": "application/json",
      "Authorization" : "Bearer $token",
    });

    List<WorkOrder> workOrderList = [];
    var jsonData = jsonDecode(response.body);
    String? tempDate;
    String? tempTime;

    for(var data in jsonData){
      if(data.containsKey('start_date') && data['start_date'] != null){
        DateFormat df = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime dt = df.parse(data['start_date']);
        tempDate = DateFormat.MMMMd('en_US').format(dt).toString();
        tempTime = DateFormat.jm().format(dt).toString();
      }

      WorkOrder wo = WorkOrder(
          woId: data['wo_id'],
          soId: num.parse(data['service_order']),
          woName: data['wo_name'],
          status: data['status'],
          requestedBy: data['requested_by'],
          address: data['cust_addr_name'],
          date: tempDate,
          time: tempTime,
          woType: data['wo_type'],
          taskType: data['task_type'],
          lat: data['latitude'],
          lng: data['longitude'],
      );
      workOrderList.add(wo);
    }
    return workOrderList;
    }

    static submitOnt(num soId, String? ontSn) async {
      var uri = Uri.http('80.80.0.86:80', '/api/serviceorder/ont-activation');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      Map jsonOnt = {
        "so" : soId,
        "ontsn" : ontSn
      };

      final response = await http.post(
        uri,
        headers: {
          "useQueryString" : "true",
          "Content-Type": "application/json",
          // "Authorization" : "Bearer $token",
        },
        body: jsonEncode(jsonOnt),
      );
      print(response.body);

      Map temp = json.decode(response.body);
      return temp;
    }

    static uploadImgAttachment(String type, XFile? img, num id) async {
      File file = File(img!.path);
      var uri = Uri.http('80.80.2.254:8080', '/api/workorder/upload-image/$id');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({"Authorization" : "Bearer $token",});
      request.fields.addAll({"type": type});

      request.files.add(await http.MultipartFile.fromPath('attachment[]', img!.path));
      // print(await http.MultipartFile.fromPath('attachment', img!.path));

      var response = await request.send();
      print(await response.stream.bytesToString());

      if(response.statusCode >= 200 && response.statusCode <= 300){
        return getImgAttachments(id);
      }else{
        return response;
      }
    }

  static deleteImgAttachment(num id, String path) async {
    var uri = Uri.http('80.80.2.254:8080', '/api/workorder/remove_image/$id/$path');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var response = await http.post(uri, headers: {"Authorization" : "Bearer $token",});
    print(token);
    print(await response.body);

    if(response.statusCode >= 200 && response.statusCode <= 300){
      return getImgAttachments(id);
    }else{
      return response;
    }
  }

  static uploadMultiImgAttachment(String type, List<XFile?> img, num id) async {
    var uri = Uri.http('80.80.2.254:8080', '/api/workorder/upload-image/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({"Authorization" : "Bearer $token",});
    request.fields.addAll({"type": type});

    List<http.MultipartFile> files = [];
    img.forEach((element) async {
      request.files.add(await http.MultipartFile.fromPath('attachment[]', element!.path));
    });

    var response = await request.send();
    print(await response.stream.bytesToString());

    if(response.statusCode >= 200 && response.statusCode <= 300){
      return getImgAttachments(id);
    }else{
      return response;
    }
  }

  static getImgAttachments(num id) async {
    var uri = Uri.http('80.80.2.254:8080', '/api/workorder/get-image', {'data_id' : id.toString()});

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      uri,
      headers: {
        "Authorization" : "Bearer $token",
      },
    );

    var img = json.decode(response.body)['ontsn'];

    if( img != null){
      List<String> imgList = List.from(img);
      return imgList;
    }else{
      return null;
    }
  }

  static activateOnt(String? ontSn) async {
    var uri = Uri.http('80.80.2.254:8080', '/api/workorder/submitOnt');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map jsonOnt = {
      "ontSn" : ontSn
    };

    final response = await http.post(
      uri,
      headers: {
        "useQueryString" : "true",
        "Content-Type": "application/json",
        "Authorization" : "Bearer $token",
      },
      body: jsonEncode(jsonOnt),
    );

    Map temp = json.decode(response.body);

    return temp;
  }


}