class ServiceOrder {
  //Work order details
  final num soId;
  final String soName;
  final String status;
  final String requestedBy;
  final String address;
  final String? progress;
  final String? desc;
  final String? type;
  final String? createdBy;
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
  final String speed;
  final String? ontSn;
  final String? rgwSn;
  final String? speedTest;
  final String? remark;
  final String? fatName;

  ServiceOrder({
    required this.soId,
    required this.soName,
    required this.status,
    required this.requestedBy,
    required this.address,
    this.progress,
    this.desc,
    this.type,
    this.createdBy,
    this.startDate,
    this.endDate,
    this.date = '',
    this.time = '',
    this.img = const {},
    this.lat = 0.0,
    this.lng = 0.0,

    this.custContact = '',
    this.custName = '',
    this.carrier = '',
    this.speed = '',
    this.ontSn,
    this.rgwSn,
    this.speedTest,
    this.remark,
    this.fatName,
  });

  factory ServiceOrder.fromJson(Map<ServiceOrder, dynamic> json){
    //not updated as it is unused, yet.
    return ServiceOrder(
      soId: json['ftth']['wo_id'] as num,
      soName: json['ftth']['service_order'] as String,
      status: json['ftth']['status'] as String,
      requestedBy: json['ftth']['requested_by'] as String,
      type: json['ftth']['task_type'] as String?,
      createdBy: json['ftth']['wo_created_by'] as String?,
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
    );
  }
}