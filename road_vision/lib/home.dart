import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as ps;
import 'package:road_vision/map.dart';
import 'package:road_vision/rec.dart';
import 'package:road_vision/record.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController googleMapController;
  double latitude = 23.258206553906586;
  double longitude = 77.42570364929938;
  Position? _currentPosition;
  bool _locationPermissionGranted = false;
  StreamSubscription<Position>? _locationSubscription; // Add this line

  @override
  void initState() {
    print(map);
    super.initState();
    _getCurrentPosition();
    _startLocationUpdates(); // Start listening for location updates
  }

  @override
  void dispose() {
    // Cancel the location subscription to avoid memory leaks
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _locationPermissionGranted = true;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _locationPermissionGranted = false;
      });
    }
  }

  void _startLocationUpdates() {
    _locationSubscription = Geolocator.getPositionStream(
            // Minimum distance (in meters) to trigger updates
            )
        .listen((Position position) {
      // Handle location updates here
      setState(() {
        _currentPosition = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            if (_locationPermissionGranted) // Show Google Map if permission granted
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition?.latitude ?? latitude,
                        _currentPosition?.longitude ?? longitude),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                        markerId: MarkerId("Current"),
                        position: LatLng(_currentPosition?.latitude ?? latitude,
                            _currentPosition?.longitude ?? longitude))
                  },
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                ),
              )
            else
              CircularProgressIndicator(), // Show progress indicator if permission not granted
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Record(),
                  ),
                );
              },
              child: Text(
                "Capture",
                style: TextStyle(
                  fontFamily: GoogleFonts.nunito().fontFamily,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 5, 109, 183),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecList(),
                  ),
                );
              },
              child: Text(
                "See List",
                style: TextStyle(
                  fontFamily: GoogleFonts.nunito().fontFamily,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 5, 109, 183),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
