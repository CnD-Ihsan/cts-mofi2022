import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  @override
  void initState() {
    randomPrint();
    String? tbp = dotenv.env['GOOGLE_MAP_API_KEY'];
    print(tbp);
    super.initState();
  }

  void randomPrint(){
    print("ada cni");
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
