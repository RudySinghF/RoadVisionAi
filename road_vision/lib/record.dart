import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_vision/replay.dart';

import 'map.dart';

class Record extends StatefulWidget {
  const Record({super.key});

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  double latitude = 23.258206553906586;
  double longitude = 77.42570364929938;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription; // Add this line

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
      });
    } catch (e) {
      debugPrint(e.toString());
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

  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;
  List<LatLng> location = <LatLng>[];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _getCurrentPosition();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _recordVideo() async {
    if (_isRecording) {
      try {
        final file = await _cameraController.stopVideoRecording();
        await GallerySaver.saveVideo(file.path);
        int i = 0;
        while (i < 10) {
          location.add(LatLng(_currentPosition?.latitude ?? latitude,
              _currentPosition?.longitude ?? longitude));
          i++;
          print(file.path);
        }

        map.putIfAbsent("${file.path}", () => location);
        print(map);

        setState(() => _isRecording = false);
        final route = MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => VideoPage(filePath: file.path),
        );
        Navigator.push(context, route);
      } catch (e) {
        debugPrint("Error: $e");
      }
    } else {
      try {
        await _cameraController.prepareForVideoRecording();
        await _cameraController.startVideoRecording();
        setState(() => _isRecording = true);
      } catch (e) {
        debugPrint("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CameraPreview(_cameraController),
            Padding(
              padding: const EdgeInsets.all(25),
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                child: Icon(_isRecording ? Icons.stop : Icons.circle),
                onPressed: () => _recordVideo(),
              ),
            ),
          ],
        ),
      );
    }
  }
}
