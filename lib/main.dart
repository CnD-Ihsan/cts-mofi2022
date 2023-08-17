import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfm/api/auth_api.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/login.dart';
import 'package:wfm/pages/show_new_installation.dart';
import 'package:wfm/route.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  final fcmToken = await FirebaseMessaging.instance.getToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   // Check user login status here
  //   if (prefs.containsKey("email") && prefs.getString("email") != null) {
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => ScreenC()));
  //   } else {
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => ScreenA()));
  //   }
  // });

  // FirebaseMessaging.onBackgroundMessage((message) async {
  //   print(message);
  // });

  print(fcmToken);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  late SharedPreferences prefs;
  late String? user, email;

  @override
  void initState() {
    // initFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WFM Mobile Apps',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      routes: {
        '/login': (context) => const Login(),
        '/list': (context) =>
            const WorkOrders(user: 'Unauthorized', email: 'Unauthorized'),
        '/show/:orderID': (context) => const ShowServiceOrder(
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
    bool activeUser = await AuthApi.isUserActive(prefs.getString('email'));
    print(activeUser);

    if (prefs.containsKey('user') && activeUser) {
      if(mounted){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WorkOrders(
                user: prefs.getString('user') ?? 'NullUser',
                email: prefs.getString('email') ?? 'NullEmail'),
            settings: const RouteSettings(name: '/list'),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
