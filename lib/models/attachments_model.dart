class ImageModel{
  final String imgId;
  final String woId;
  final String? type;

  ImageModel({
    required this.imgId,
    required this.woId,
    this.type,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json){
    return ImageModel(imgId: json["id"] ?? "", woId: json["woId"] ?? "", type: json["type"],);
  }
}
