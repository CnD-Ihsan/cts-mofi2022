class User {
  final int id;
  final String name;
  final String email;
  final String organization;
  final String? message;

  User({required this.id, required this.name, required this.email, required this.organization, this.message});

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json["id"] ?? 0,
      name: json["name"] ?? "-",
      email: json["email"] ?? "-",
      organization: json["organization"] ?? "-",
      message: json["message"],
    );
  }
}

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