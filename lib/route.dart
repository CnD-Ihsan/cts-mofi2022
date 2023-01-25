import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wfm/pages/login.dart';
import 'package:wfm/pages/list_orders.dart';
import 'package:wfm/pages/show_new_installation.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const Login());
      case '/index':
        if (args is Map<String, String>) {
          final user = args['user'] ?? 'Unauthorized';
          final email = args['email'] ?? 'Unauthorized';
          return MaterialPageRoute(builder: (_) => WorkOrders(user: user, email: email));
        }
        return _errorRoute();
      case '/show':
        if (args is num) {
          final orderId = args;
          return MaterialPageRoute(builder: (_) => ShowOrder(orderID: orderId));
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
