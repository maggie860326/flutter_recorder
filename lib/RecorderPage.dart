// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart' show DateFormat;
// import 'package:path_provider/path_provider.dart';

class RecorderPage extends StatefulWidget {
  const RecorderPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  // FlutterSoundPlayer? myPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? myRecorder = FlutterSoundRecorder();
  StreamSubscription? _recorderSubscription;
  final recordingPlayer = AssetsAudioPlayer();
  String _recorderState = "Stopped";
  String pathToAudio = "";
  bool _playAudio = false;
  bool _isRecording = false;

  String _timerText = '00:00:00';

  @override
  void initState() {
    super.initState();
    initializer();
  }

  void initializer() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.audio.request();
    await Permission.manageExternalStorage.request();
    pathToAudio = '/sdcard/Download/temp.wav';
    // _recordingSession = FlutterSoundRecorder();
    myRecorder = await FlutterSoundRecorder().openRecorder();
    await myRecorder!
        .setSubscriptionDuration(const Duration(milliseconds: 100));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  // @override
  // void dispose() {
  //   stopRecording;

  //   if (_recorderSubscription != null) {
  //     _recorderSubscription!.cancel();
  //     _recorderSubscription = null;
  //   }
  //   if (myRecorder != null) {
  //     myRecorder!.closeRecorder();
  //     myRecorder = null;
  //   }
  // if (myPlayer != null) {
  //   myPlayer = null;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black87,
      appBar: AppBar(title: const Text('錄音頁面')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 40,
            ),
            Center(
              child: Text(
                _recorderState,
                style: const TextStyle(fontSize: 40, color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                _timerText,
                style: const TextStyle(
                    fontSize: 70, color: Color.fromARGB(255, 255, 184, 30)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                setState(() {
                  _isRecording = !_isRecording;
                });
                if (_isRecording) {
                  startRecording();
                } else {
                  stopRecording();
                }
              },
              child: _isRecording
                  ? const Icon(
                      Icons.stop,
                    )
                  : const Icon(Icons.mic),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  elevation: 9.0, backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _playAudio = !_playAudio;
                });
                if (_playAudio) {
                  playFunc();
                } else {
                  stopPlayFunc();
                }
              },
              icon: _playAudio
                  ? const Icon(
                      Icons.stop,
                    )
                  : const Icon(Icons.play_arrow),
              label: _playAudio
                  ? const Text(
                      "Stop",
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    )
                  : const Text(
                      "Play",
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton createElevatedButton(
      {required IconData icon,
      required Color iconColor,
      required void Function() onPressFunc}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(6.0),
        side: const BorderSide(
          color: Colors.red,
          width: 4.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        elevation: 9.0,
      ),
      onPressed: onPressFunc,
      icon: Icon(
        icon,
        color: iconColor,
        size: 38.0,
      ),
      label: const Text(''),
    );
  }

  void getRecorderState() {
    if (myRecorder!.isStopped) {
      setState(() {
        _recorderState = "Stopped";
      });
    } else if (myRecorder!.isRecording) {
      setState(() {
        _recorderState = "Recording";
      });
    } else if (myRecorder!.isPaused) {
      setState(() {
        _recorderState = "Paused";
      });
    } else {
      setState(() {
        _recorderState = "Unknown";
      });
    }
  }

  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    if (myRecorder != null) {
      // myRecorder!.openAudioSession();
      await myRecorder!.startRecorder(
        toFile: pathToAudio,
        codec: Codec.pcm16WAV,
        // sampleRate: 16000,
      );

      if (myRecorder!.onProgress != null) {
        // ignore: no_leading_underscores_for_local_identifiers
        _recorderSubscription = myRecorder!.onProgress!.listen((e) {
          var date = DateTime.fromMillisecondsSinceEpoch(
              e.duration.inMilliseconds,
              isUtc: true);
          var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
          setState(() {
            _timerText = timeText.substring(0, 8);
          });
        }, onError: (err) {
          print(err);
        }, onDone: () {
          print('subscription done!!');
        }, cancelOnError: false);
      }
      getRecorderState();
    }
  }

  Future<void> stopRecording() async {
    if (myRecorder != null) {
      await _recorderSubscription!.cancel();
      await myRecorder!.stopRecorder();
      getRecorderState();
    }
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio),
      autoStart: true,
      showNotification: true,
    );
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }
}
