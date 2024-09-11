import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wfm/api/base_api.dart';
import 'package:wfm/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthApi extends BaseApi{

  static Future<String> checkVersion() async{
    var uri = Uri.parse('${BaseApi.wfmHost}/auth/getLatestVersion');

    try{
      final response = await http.get(
          uri,
          headers: BaseApi.apiHeaders
      ).timeout(const Duration(seconds:10));

      String latestVersion = response.body;

      return latestVersion;
    }catch(e){
      return "Error retrieving version";
    }
  }

  static Future<dynamic> isUserActive(String? email, String? deviceId) async{
    var uri = Uri.parse('${BaseApi.wfmHost}/auth/isUserActive');
    try{
      final response = await http.post(
          uri,
          headers:BaseApi.apiHeaders,
          body: {
            "email" : email,
            "device_id" : deviceId,
          }
      ).timeout(const Duration(seconds:10));

      Map data = jsonDecode(response.body);

      if(response.statusCode == 200 && data['status'] == true){
        return true;
      }else{
        return false;
      }
    }catch(e){
      return false;
    }
  }

  static Future<LoginResponseModel> loginRequest(String email, String password) async{
    var uri = Uri.parse('${BaseApi.wfmHost}/auth/login');

    //Initialize shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final fcmToken = await FirebaseMessaging.instance.getToken();

    try{
      final response = await http.post(
          uri,
          headers: BaseApi.apiHeaders,
          body: {
            "email" : email,
            "password" : password,
            "fcmToken" : fcmToken
          }
      ).timeout(const Duration(seconds:10));

      Map data = jsonDecode(response.body);

      if(response.statusCode == 200){
        // Set shared preferences
        prefs.setString('email', email);
        prefs.setString('user', data['name']);
        prefs.setString('role', data['role']);
        prefs.setString('organization', data['organization']);
        prefs.setString('token', data['access_token']);
        prefs.setString('fcm_token', fcmToken ?? "Device ID Missing");
        BaseApi.apiHeaders.update("Authorization", (value) => "Bearer ${prefs.getString('token')}");

        return LoginResponseModel(
          user: data['name'],
          token: data['access_token'],
        );
      }else{
        String msg = data['message'] ?? data['error'];
        return LoginResponseModel(
          user: '',
          token: '',
          message: msg,
        );
      }
    }catch(e){
      // String errMsg = e.toString();
      String errMsg = "Server connection error.";

      return LoginResponseModel(
        user: '',
        token: '',
        message: errMsg,
      );
    }

  }

  static Future<bool> logOut(String? email, String? fcmToken) async{
    var uri = Uri.parse('${BaseApi.wfmHost}/auth/logOut');

    try{
      final response = await http.post(
          uri,
          headers: BaseApi.apiHeaders,
          body: {
            "email" : email,
            "device_id" : fcmToken,
          }
      ).timeout(const Duration(seconds:10));

      if(response.statusCode == 200){
        return true;
      }else{
        return false;
      }
    }catch(e){
      return false;
    }
  }

  static Future<bool> logOutUser(String token, String email) async{
    var uri = Uri.parse('${BaseApi.wfmHost}/auth/logOutUser');
    try{
      final response = await http.post(
          uri,
          headers: BaseApi.apiHeaders,
          body: {
            "email" : email,
          }
      ).timeout(const Duration(seconds:10));
      // Map data = jsonDecode(response.body);

      if(response.statusCode == 200){
        return true;
      }else{
        return false;
      }
    }catch(e){
      return false;
    }
  }
}