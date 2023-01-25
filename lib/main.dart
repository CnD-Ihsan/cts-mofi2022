import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/login.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/route.dart';

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
  // late Future<Widget> home;

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
        '/index': (context) => const WorkOrders(user: 'Unauthorized', email: 'Unauthorized'),
        '/show/:orderID': (context) => const ShowOrder(orderID: 0,),
      },
      onGenerateRoute: RouteGenerator.generateRoute,
      home: const Landing(),
    );
  }
  //
  // getPrefs() async {
  //   prefs = await SharedPreferences.getInstance();
  //
  //   if (prefs.containsKey('user') && prefs.containsKey('token')) {
  //     user = prefs.getString('user');
  //     email = prefs.getString('email');
  //     if(mounted){
  //       // Navigator.push(
  //       //   context,
  //       //   MaterialPageRoute(
  //       //       settings: const RouteSettings(
  //       //         name: "/index",
  //       //       ),
  //       //       builder: (context) => WorkOrders(
  //       //           user: user ?? 'Unauthorized',
  //       //           email: email ?? 'Unauthorized')
  //       //   ),
  //       // );
  //       // Navigator.pushReplacementNamed(context, '/index');
  //       // Navigator.push(
  //       //   context,
  //       //   MaterialPageRoute(
  //       //       builder: (context) => WorkOrders(user: user ?? 'NullUser', email: email ?? 'NullEmail')),
  //       // );
  //     }
  //   } else {
  //     return const Login();
  //   }
  // }
}

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  State createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  void initState() {
    _loadUserInfo();
    super.initState();
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      print(prefs.containsKey('user'));
      if (!prefs.containsKey('user')) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WorkOrders(user: prefs.getString('user') ?? 'NullUser', email: prefs.getString('email') ?? 'NullEmail')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
