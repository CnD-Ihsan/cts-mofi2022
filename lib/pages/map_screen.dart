import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _returningLatLng;
  late Position _userPosition;
  CameraPosition? _userCameraPosition;
  late LocationPermission _locationPermission;

  @override
  void initState() {
    getUserCurrentLocation();
    super.initState();
  }

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  late final List<Marker> _markers = <Marker>[
    const Marker(
        markerId: MarkerId('1'),
        position: LatLng(6.0320136, 116.1314596),
        infoWindow: InfoWindow(
          title: 'Default',
        )),
  ];

  static const CameraPosition _cts100 = CameraPosition(
    target: LatLng(6.0320136, 116.1314596),
    zoom: 14.4746,
  );

  // created method for getting user current location
  void getUserCurrentLocation() async {
    _userPosition = await Geolocator.getCurrentPosition();
    _returningLatLng = LatLng(_userPosition.latitude, _userPosition.longitude);
    _userCameraPosition = CameraPosition(
        target: _returningLatLng,
        zoom: 19)!;
    updateMarker("1", _returningLatLng);
    if(mounted){
      setState(() {
      });
    }
    await _moveToUser();
  }

  void updateMarker(String markerId, LatLng newPosition) {
    if(mounted){
      setState(() {
        var marker =
        _markers.firstWhere((element) => element.markerId.value == markerId);
        _markers.removeWhere((element) => element.markerId.value == markerId);
        _markers.add(Marker(
          markerId: MarkerId(markerId),
          position: newPosition,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userCameraPosition == null ? const Center(
        // Display Progress Indicator
        child: CircularProgressIndicator(),
      ) : GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _cts100,
        markers: Set<Marker>.of(_markers),
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
        onTap: (tappedLatLng) {
          _returningLatLng = tappedLatLng;
          updateMarker("1", tappedLatLng);
        },
      ),
      floatingActionButton: _userCameraPosition == null ? null : FloatingActionButton.extended(
        onPressed: () => {Navigator.pop(context, _returningLatLng)},
        label: const Text('Confirm'),
        icon: const Icon(Icons.check_circle_outline),
      ),
    );
  }

  Future<void> _moveToUser() async {
    final GoogleMapController controller = await _mapController.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_userCameraPosition!));
  }

  showMapLoader(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading Map...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
