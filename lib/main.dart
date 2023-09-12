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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterSoundRecorder _recordingSession = FlutterSoundRecorder();
  final recordingPlayer = AssetsAudioPlayer();
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
    pathToAudio = '/sdcard/Download/temp.wav';
    // _recordingSession = FlutterSoundRecorder();
    await _recordingSession.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _recordingSession
        .setSubscriptionDuration(const Duration(milliseconds: 100));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: const Text('Audio Recording and Playing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 40,
            ),
            Center(
              child: Text(
                _timerText,
                style: const TextStyle(fontSize: 70, color: Colors.red),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  elevation: 9.0, backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _isRecording = !_isRecording;
                });
                if (_isRecording) stopRecording();
                if (!_isRecording) startRecording();
              },
              icon: _isRecording
                  ? const Icon(
                      Icons.stop,
                    )
                  : const Icon(Icons.mic),
              label: const Text(''),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     createElevatedButton(
            //       icon: Icons.mic,
            //       iconColor: Colors.red,
            //       onPressFunc: startRecording,
            //     ),
            //     const SizedBox(
            //       width: 30,
            //     ),
            //     createElevatedButton(
            //       icon: Icons.stop,
            //       iconColor: Colors.red,
            //       onPressFunc: stopRecording,
            //     ),
            //   ],
            // ),
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
                if (_playAudio) playFunc();
                if (!_playAudio) stopPlayFunc();
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

  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession.openAudioSession();
    await _recordingSession.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );

    if (_recordingSession.onProgress != null) {
      // ignore: no_leading_underscores_for_local_identifiers
      StreamSubscription _recorderSubscription =
          _recordingSession.onProgress!.listen((e) {
        var date = DateTime.fromMillisecondsSinceEpoch(
            e.duration.inMilliseconds,
            isUtc: true);
        var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
        setState(() {
          _timerText = timeText; //.substring(0, 8)
        });
      }, onError: (err) {
        print(err);
      }, onDone: () {
        print('subscription done!!');
      }, cancelOnError: false);

      _recorderSubscription.cancel();
      print(_timerText);
    }
  }

  Future<String?> stopRecording() async {
    _recordingSession.closeAudioSession();
    return await _recordingSession.stopRecorder();
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
