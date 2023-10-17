class TroubleshootOrder {
  //Work order details
  final num ttId;
  final String ttNo;
  final String status;
  final String isp;
  final String address;
  final String description;
  String? progress;
  final String? type;
  final String? deviceQuantity;
  final String? startDate;
  final String? endDate;
  final double? lat;
  final double? lng;
  final Map img;

  //Derived work order details
  String? date;
  String? time;

  final String custContact;
  final String custName;
  final String carrier;
  final String? speed;
  final String? ontSn;
  final String? rootCause;
  final String? ontChange;
  final String? subCause;
  final String? faultLocation;
  final String? speedTest;
  final String? actionTaken;
  final String? remark;


  TroubleshootOrder({
    required this.ttId,
    required this.ttNo,
    required this.status,
    required this.isp,
    required this.address,
    required this.description,
    this.progress = '',
    this.type = '',
    this.deviceQuantity = '',
    this.startDate = '',
    this.endDate = '',
    this.date = '',
    this.time = '',
    this.img = const {},
    this.lat = 0.0,
    this.lng = 0.0,

    this.custContact = '',
    this.custName = '',
    this.carrier = '',
    this.speed,
    this.ontSn,
    this.rootCause,
    this.ontChange,
    this.subCause,
    this.faultLocation,
    this.speedTest,
    this.actionTaken,
    this.remark,
  });

  factory TroubleshootOrder.fromJson(Map<TroubleshootOrder, dynamic> json){
    //not updated as it is unused, yet.
    return TroubleshootOrder(
      ttId: json['ftth']['wo_id'] as num,
      ttNo: json['ftth']['service_order'] as String,
      status: json['ftth']['status'] as String,
      isp: json['ftth']['requested_by'] as String,
      description: json['ftth']['description'] as String,
      type: json['ftth']['task_type'] as String?,
      deviceQuantity: json['ftth']['deviceQuantity'] as String?,
      startDate: json['ftth']['start_date'] as String?,
      endDate: json['ftth']['end_date'] as String?,
      address: json['ftth']['cust_addr_name'] as String,

      // soId: json['so_id'] as num,
      // soType: json['order_type'] as String,
      custContact: json['ftth']['cust_contact'] as String,
      custName: json['ftth']['cust_name'] as String,
      // custAddress: json['cust_addr'] as String,
      speed: json['ftth']['package_speed'] as String,
      carrier: json['ftth']['carrier'] as String,
      ontSn: json['ftth']['ont_sn'] as String?,
      rootCause: json['ftth']['root_cause'] as String?,
      subCause: json['ftth']['sub_cause'] as String?,
      actionTaken: json['ftth']['action_taken'] as String?,
      faultLocation: json['ftth']['fault_location'] as String?,
    );
  }
}