import 'dart:convert';
import 'package:wfm/models/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginApi{
  // static const wfmHost = 'http://80.80.2.254:8080/api';
  static const wfmHost = 'https://wfm.ctsabah.net/api';

  static Future<bool> isUserActive(String? email) async{
    var uri = Uri.parse('$wfmHost/auth/isUserActive');
    // var uri = Uri.http(_uri);

    try{
      final response = await http.post(
          uri,
          headers: {
            "useQueryString" : "true"
          },
          body: {
            "email" : email,
          }
      ).timeout(const Duration(seconds:10));

      Map data = jsonDecode(response.body);

      if(response.statusCode == 200 && data['status'] == 'Active'){
        return true;
      }else{
        return false;
      }
    }catch(e){
      return false;
    }
  }

  static Future<LoginResponseModel> loginRequest(LoginRequestModel login) async{
    var uri = Uri.parse('$wfmHost/login');
    // var uri = Uri.parse('$wfmHost/auth/login');
    //Initialize shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try{
      final response = await http.post(
          uri,
          headers: {
            "useQueryString" : "true",
            "Content" : "application/json",
            "Accept" : "application/json",
            "Authorization" : ""
          },
          body: {
            "email" : login.email,
            "password" : login.password,
          }
      ).timeout(const Duration(seconds:10));

      Map data = jsonDecode(response.body);
      print(response.body);

      if(response.statusCode == 200){
        data['user'] = 'Admin';
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
      print(e);
      return LoginResponseModel(
        user: '',
        token: '',
        message: 'Unexpected error occurred! Contact admin if issue persists.',
      );
    }

  }
}