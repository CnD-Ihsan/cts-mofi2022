import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/base_api.dart';
import 'dart:convert';
import 'package:wfm/models/user_model.dart';


class UserApi extends BaseApi {
  static Future<List<User>> fetchUsers(token) async {
    final apiUrl = '${BaseApi.wfmHost}/users/get-users';

    final response = await http.get(
        Uri.parse(apiUrl),
        headers: BaseApi.apiHeaders,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<User> users = [];

      for (var user in jsonData) {
        users.add(User(
          id: user['id'],
          name: user['name'],
          email: user['email'],
          organization: user['organization']
        ));
      }

      return users;
    } else {
      throw Exception('Failed to load users.');
    }
  }

  static Future<dynamic> resetPassword(String? token, String email) async {
    final apiUrl = '${BaseApi.wfmHost}/users/reset-password';

    Map dataSend = {
      "email" : email
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: BaseApi.apiHeaders,
      body: dataSend,
    );

    Map<String, dynamic> responseData = jsonDecode(response.body.toString());


    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception('Failed to reset password.');
    }
  }

  static Future<dynamic> updatePassword(String? token, String userEmail, String pw) async {
    final apiUrl = '${BaseApi.wfmHost}/users/update-password';

    Map dataSend = {
      "email" : userEmail,
      "password" : pw,
    };

    Map failedResponse = {
      "failed" : "Failed to update password",
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: BaseApi.apiHeaders,
      body: dataSend,
    );

    Map<String, dynamic> responseData = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      return responseData;
    } else {
      return failedResponse;
    }
  }
}
