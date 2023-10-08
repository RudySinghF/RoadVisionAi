import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

import 'package:road_vision/map.dart';

class RecList extends StatefulWidget {
  const RecList({Key? key}) : super(key: key);

  @override
  State<RecList> createState() => _RecListState();
}

class _RecListState extends State<RecList> {
  List<File> selectedFiles = [];

  Future<void> pickMP4Files() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedFiles = result.files.map((file) => File(file.path!)).toList();
        });
      }
    } catch (e) {
      print('Error picking MP4 files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MP4 Files from Gallery'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickMP4Files,
              child: Text('Pick MP4 Files'),
            ),
            if (selectedFiles.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final mp4File = selectedFiles[index];
                  String filePath = mp4File.path;
                  // Extract the match from the file path
                  String match = mp4File.path.substring(0, 43) +
                      mp4File.path.substring(55);
                  ;
                  List<LatLng>? location = map[match];

                  return Card(
                    child: ListTile(
                      title: Text('File Name: ${mp4File.path}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (location != null) Text('Location Data:'),
                          if (location != null)
                            ...location.map((latLng) => Text(
                                  "Lat: ${latLng.latitude}, Long: ${latLng.longitude}",
                                )),
                          if (location == null)
                            Text('No location data found for this file.'),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
