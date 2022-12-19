import 'package:intl/intl.dart';
import 'package:wfm/pages/list_orders.dart';

class WorkOrder {
  //Work order details
  final num woId;
  final String woName;
  final String status;
  final String requestedBy;
  final String address;
  final String? woType;
  final String? createdBy;
  final String? startDate;
  final String? endDate;
  final double? lat;
  final double? lng;

  //Derived work order details
  String? date;
  String? time;

  // final num soId;
  // final String soType;
  final String custContact;
  // final String custAddress;
  final String carrier;
  final String speed;
  final String? ontSn;

  WorkOrder({
    required this.woId,
    required this.woName,
    required this.status,
    required this.requestedBy,
    required this.address,
    this.woType = '',
    this.createdBy = '',
    this.startDate = '',
    this.endDate = '',
    this.date = '',
    this.time = '',
    this.lat = 0.0,
    this.lng = 0.0,

    // this.soId,
    // this.soType,
    this.custContact = '',
    // this.custAddress,
    this.carrier = '',
    this.speed = '',
    this.ontSn,
  });

  factory WorkOrder.fromJson(Map<WorkOrder, dynamic> json){

    return WorkOrder(
      woId: json['ftth']['wo_id'] as num,
      woName: json['ftth']['wo_name'] as String,
      status: json['ftth']['status'] as String,
      requestedBy: json['ftth']['requested_by'] as String,
      woType: json['ftth']['wo_type'] as String?,
      createdBy: json['ftth']['wo_created_by'] as String?,
      startDate: json['ftth']['start_date'] as String?,
      endDate: json['ftth']['end_date'] as String?,
      address: json['ftth']['cust_addr_name'] as String,

      // soId: json['so_id'] as num,
      // soType: json['order_type'] as String,
      custContact: json['ftth']['cust_contact'] as String,
      // custAddress: json['cust_addr'] as String,
      speed: json['ftth']['package_speed'] as String,
      carrier: json['ftth']['carrier'] as String,
      ontSn: json['ftth']['ont_sn'] as String?,
    );
  }
}