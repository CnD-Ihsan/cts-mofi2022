import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:wfm/models/user_model.dart';


class UserApi {
  static var wfmHost = 'https://wfm.ctsabah.net/api';

  static Future<List<User>> fetchUsers(token) async {
    // Replace 'your-api-endpoint' with the actual API endpoint to fetch users
    // const apiUrl = 'http://80.80.1.131:81/api/users/get-users';
    final apiUrl = '$wfmHost/users/get-users';

    final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Accept" : "application/json",
          "Content-Type" : "application/json",
          "Authorization" : "Bearer $token",
        },
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
    // const apiUrl = 'http://80.80.1.131:81/api/users/reset-password';
    final apiUrl = '$wfmHost/users/reset-password';

    Map dataSend = {
      "email" : email
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Accept" : "application/json",
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $token",
      },
      body: jsonEncode(dataSend),
    );

    Map<String, dynamic> responseData = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception('Failed to reset password.');
    }
  }

  static Future<dynamic> updatePassword(String? token, String userEmail, String pw) async {
    final apiUrl = '$wfmHost/users/update-password';

    Map dataSend = {
      "email" : userEmail,
      "password" : pw,
    };

    Map failedResponse = {
      "failed" : "Failed to update password!",
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Accept" : "application/json",
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $token",
      },
      body: jsonEncode(dataSend),
    );

    print(response.body);

    Map<String, dynamic> responseData = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      return responseData;
    } else {
      return failedResponse;
    }
  }
}
