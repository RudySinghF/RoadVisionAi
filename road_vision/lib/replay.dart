import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:road_vision/home.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final String filePath;

  const VideoPage({Key? key, required this.filePath}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  // Future<void> saveVideoToStorage(File videoFile) async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final videoPath = '${directory.path}/my_video.mp4';

  //     // Copy the video file to the app's documents directory
  //     await videoFile.copy(videoPath);

  //     print('Video saved to: $videoPath');
  //   } catch (e) {
  //     print('Error saving video: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Preview",
          style: TextStyle(
              fontFamily: GoogleFonts.nunito().fontFamily, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 5, 90, 181),
        actions: [
          GestureDetector(
            onTap: () {
              // saveVideoToStorage(File(widget.filePath));
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "Back",
                style: TextStyle(
                    fontFamily: GoogleFonts.nunito().fontFamily,
                    color: Colors.white),
              ),
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return VideoPlayer(_videoPlayerController);
          }
        },
      ),
    );
  }
}
