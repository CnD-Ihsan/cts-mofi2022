import 'dart:convert';
import 'package:wfm/models/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginApi{

  static Future<LoginResponseModel> loginRequest(LoginRequestModel login) async{
    var uri = Uri.http('80.80.2.254:8080', '/api/auth/login');

    //Initialize shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try{
      final response = await http.post(
          uri,
          headers: {
            "useQueryString" : "true"
          },
          body: {
            "email" : login.email,
            "password" : login.password,
          }
      );

      Map data = jsonDecode(response.body);

      if(response.statusCode == 200){
        // Set shared preferences
        prefs.setString('email', login.email);
        prefs.setString('user', data['user']);
        prefs.setString('token', data['access_token']);

        return LoginResponseModel(
          user: data['user'],
          token: data['access_token'],
        );
      }else{
        return LoginResponseModel(
          user: '',
          token: '',
          message: data['message'],
        );
      }
    }catch(e){
      return LoginResponseModel(
        user: '',
        token: '',
        message: 'Unexpected error occurred! Contact admin if issue persists.',
      );
    }

  }
}