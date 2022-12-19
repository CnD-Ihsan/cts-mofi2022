import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/models/work_order_model.dart';
import 'package:http/http.dart' as http;

class WorkOrderApi{

  static Future<WorkOrder> getWorkOrder(num id) async {
    //id = '194';
    var uri = Uri.http('80.80.0.86:80', '/api/serviceorder/show-work-order');
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

    print(data['appointment_date']);
    if(data.containsKey('appointment_date') && data['appointment_date'] != null){
      DateFormat df = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime dt = DateTime.parse(data['appointment_date']);
      tempDate = DateFormat.yMMMMd('en_US').format(dt).toString();
      tempTime = DateFormat.jm().format(dt).toString();
    }

    return WorkOrder(
        woId: data['wo_id'],
        woName: data['wo_name'],
        status: data['status'],
        requestedBy: data['requested_by'],
        address: data['address'],
        startDate: data['appointment_date'],
        time: tempTime,
        date: tempDate,
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
          woName: data['wo_name'],
          status: data['status'],
          requestedBy: data['requested_by'],
          address: data['cust_addr_name'],
          date: tempDate,
          time: tempTime,
          woType: data['wo_type'],
      );
      workOrderList.add(wo);
    }

    return workOrderList;
    }

    static submitOnt(num ontId, String? ontSn) async {
      var uri = Uri.http('80.80.2.254:8080', '/api/workorder/submitOnt');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      Map jsonOnt = {
        "ontId" : ontId,
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