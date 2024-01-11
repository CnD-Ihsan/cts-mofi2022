import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wfm/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi{
  static const wfmHost = 'https://wfm.ctsabah.net/api';

  static Future<dynamic> isUserActive(String? email, String? deviceId) async{
    var uri = Uri.parse('$wfmHost/auth/isUserActive');

    try{
      final response = await http.post(
          uri,
          headers: {
            "useQueryString" : "true"
          },
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
    var uri = Uri.parse('$wfmHost/auth/login');

    //Initialize shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final fcmToken = await FirebaseMessaging.instance.getToken();

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

        return LoginResponseModel(
          user: data['name'],
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
        message: e.toString(),
      );
    }

  }

  static Future<bool> logOut(String? email, String? fcmToken) async{
    var uri = Uri.parse('$wfmHost/auth/logOut');
    var bodyData = {
      "email" : email,
      "device_id" : fcmToken,
    };

    try{
      final response = await http.post(
          uri,
          headers: {
            "useQueryString" : "true"
          },
          body: {
            "email" : email,
            "device_id" : fcmToken,
          }
      ).timeout(const Duration(seconds:10));

      Map data = jsonDecode(response.body);

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
    var uri = Uri.parse('$wfmHost/auth/logOutUser');
    try{
      final response = await http.post(
          uri,
          headers: {
            "useQueryString" : "true",
            "Authorization": "Bearer $token"
          },
          body: {
            "email" : email,
          }
      ).timeout(const Duration(seconds:10));

      Map data = jsonDecode(response.body);

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