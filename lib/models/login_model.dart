class LoginResponseModel{
  final String user;
  final String token;
  final String? message;

  LoginResponseModel({
    required this.user,
    required this.token,
    this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json){
    return LoginResponseModel(user: json["user"] ?? "", token: json["token"] ?? "", message: json["message"],);
  }
}

class LoginRequestModel{
  String email;
  String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson(){
    Map<String, dynamic> map = {
      'email' : email.trim(),
      'password' : password.trim(),
    };

    return map;
  }
}