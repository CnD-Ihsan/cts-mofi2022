import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/login_api.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/login.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/route.dart';

import 'models/login_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SharedPreferences prefs;
  late String? user, email;

  @override
  void initState() {
    // getPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WFM Mobile Apps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/login': (context) => const Login(),
        '/index': (context) =>
            const WorkOrders(user: 'Unauthorized', email: 'Unauthorized'),
        '/show/:orderID': (context) => const ShowOrder(
              orderID: 0,
            ),
      },
      onGenerateRoute: RouteGenerator.generateRoute,
      home: const Landing(),
    );
  }
}

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  State createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  var loginResponse;

  @override
  void initState() {
    _loadUserInfo();
    super.initState();
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool activeUser = await LoginApi.isUserActive(prefs.getString('email'));
    if (prefs.containsKey('user') && activeUser) {
      if(mounted){}
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
      if (mounted) {}
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
