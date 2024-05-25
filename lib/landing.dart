
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/pages/list_orders.dart';

import 'api/auth_api.dart';
import 'api/base_api.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  var loginResponse;

  @override
  void initState() {
    super.initState();
    _verifyVersion();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var activeUser = await AuthApi.isUserActive(prefs.getString('email'), prefs.getString('fcm_token'));
    if(mounted){
      if (prefs.containsKey('user') && activeUser) {
        BaseApi.apiHeaders.update("Authorization", (value) => "Bearer ${prefs.getString('token')}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WorkOrders(
                user: prefs.getString('user') ?? 'NullUser',
                email: prefs.getString('email') ?? 'NullEmail'),
            settings: const RouteSettings(name: '/list'),
          ),
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));
      }
    }
  }

  _verifyVersion() async{
    String latestVersion = await AuthApi.checkVersion();
    String currentVersion = BaseApi.appVersion;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(mounted){
      if(currentVersion != latestVersion){
        AuthApi.logOut(prefs.getString('email'), prefs.getString('fcm_token'));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              // Your page content goes here
              return Scaffold(
                body: Center(
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.update,
                            size: 50,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Update Required',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'A new version of the app is available. Please update to continue using the app.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Current version: $currentVersion',
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Latest version: $latestVersion',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              SystemNavigator.pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            settings: const RouteSettings(name: '/verify_version'),
          ),
        );
      }else{
        _forceNotification();
        // _loadUserInfo();
      }
    }
  }

  _forceNotification() async{
    String latestVersion = await AuthApi.checkVersion();
    String currentVersion = BaseApi.appVersion;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PermissionStatus status = await Permission.notification.status;

    if(mounted){
      if(!status.isGranted){
        AuthApi.logOut(prefs.getString('email'), prefs.getString('fcm_token'));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              // Your page content goes here
              return Scaffold(
                body: Center(
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit_notifications,
                            size: 50,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Notification Permission Required',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'This app requires notification permission. Please enable it from the app setting to continue using the app.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              SystemNavigator.pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            settings: const RouteSettings(name: '/verify_version'),
          ),
        );
      }else{
        _loadUserInfo();
      }
    }
  }

  void checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      // Notification permission is granted
      // Proceed with app initialization
    } else {
      // Notification permission is not granted
      // Request permission from the user
      PermissionStatus permissionStatus = await Permission.notification.request();
      if (permissionStatus.isGranted) {
        // Notification permission granted by the user
        // Proceed with app initialization
      } else {
        // Notification permission denied by the user
        // Handle accordingly (e.g., show a message, disable certain features)
      }
    }
  }
}
