/*
View: 錄音的頁面
包含題目敘述、錄音按鈕、下一題按鈕
如果要修改題目敘述和圖片，請到 config.dart 中 修改 task_#_description
*/

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:recorder/model.dart';
import 'package:recorder/view_model.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'function.dart';

class RecorderPage extends StatefulWidget {
  const RecorderPage({
    Key? key,
    required this.index,
  }) : super(key: key);
  final int index;

  @override
  State<RecorderPage> createState() => _RecorderPageState(
        index: index,
      );
}

class _RecorderPageState extends State<RecorderPage> {
  int index;

  _RecorderPageState({
    required this.index,
  });

  //設定 recorder 相關變數
  FlutterSoundRecorder? myRecorder = FlutterSoundRecorder();
  StreamSubscription? _recorderSubscription;
  final recordingPlayer = AssetsAudioPlayer();
  String _recorderState = "準備好後請按下按鈕";
  bool _playAudio = false; //用來控制 播放/停止播放 按鈕作用
  bool _isRecording = false; //用來控制 錄音/停止錄音 按鈕作用
  bool _isOver1Min = true; //錄音時間是否超過一分鐘
  bool invisible = false; //隱藏或顯示下一題按鈕

  String _timerText = ''; //計時器

  @override
  void initState() {
    super.initState();
    initializer();
  }

  void initializer() async {
    // print("m: 第 $index 頁 initialized.\n");
    //要求權限
    await requestPermission(Permission.microphone);

    //recorder相關設定
    myRecorder = await FlutterSoundRecorder().openRecorder();
    await myRecorder!
        .setSubscriptionDuration(const Duration(milliseconds: 100));
    await initializeDateFormatting();
  }

  @override
  void dispose() {
    super.dispose();
    stopRecording;

    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
    if (myRecorder != null) {
      myRecorder!.closeRecorder();
      myRecorder = null;
    }
    // print("m: 第 $index 頁 disposed.\n");
  }

  @override
  Widget build(BuildContext context) {
    // print("m: 第 $index 頁 build");

    PathModel pathModel = Provider.of<PathModel>(context, listen: false);
    pathModel.index = index;
    Future<String> pathToAudio = pathModel.pathToAudio();
    String? imagePath = questionList[index].imagePath;

    List<Widget> question = [
      Text(
        questionList[index].description, //! 代入題目描述
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
    ];

    if (imagePath != null) {
      //! 代入圖片
      question.add(Image.asset(imagePath));
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Text(
            "${questionList[index].task_name}${questionList[index].questionNo}", //! 代入題目編號
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),

          Container(
            padding: const EdgeInsets.all(0),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 0.5),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Column(children: question),
          ),
          Text(
            _recorderState,
            style: const TextStyle(fontSize: 20, color: Colors.black38),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              _timerText,
              style: const TextStyle(
                  fontSize: 30, color: Color.fromARGB(255, 255, 184, 30)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          //! 錄音/停止錄音按鈕
          Offstage(
            offstage: invisible,
            child: FloatingActionButton.large(
              heroTag: "btn $index",
              backgroundColor: _isOver1Min ? Colors.red : Colors.grey,
              onPressed: () {
                if (!_isRecording) {
                  setState(() {
                    _recorderState = "請講至少 1 分鐘";
                    _isRecording = !_isRecording;
                    _isOver1Min = false;
                  });
                  startRecording(pathToAudio);
                } else {
                  //! 控制1分鐘才能按停止按鈕
                  if (_isOver1Min) {
                    setState(() {
                      _recorderState = "準備好後請按下按鈕";
                      _isRecording = !_isRecording;
                      invisible = true;
                    });
                    stopRecording();
                  } else {}
                }
              },
              child: _isRecording
                  ? const Icon(
                      Icons.stop,
                    )
                  : const Icon(Icons.mic),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          //! 播放/停止播放按鈕
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                elevation: 9.0, backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _playAudio = !_playAudio;
              });
              if (_playAudio) {
                playFunc(pathToAudio);
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
                    "停止播放",
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  )
                : const Text(
                    "播放錄音檔",
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
          ),
          const SizedBox(
            height: 20,
          ),
          Offstage(
            offstage: !invisible,
            child: ElevatedButton(
              onPressed: () {
                submitWav(pathModel);
                Provider.of<WhisperViewModel>(context, listen: false)
                    .runWhisper(context, pathModel);
                Provider.of<PageController>(context, listen: false).nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
              child: const Text(
                "下一題",
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /* ==============以下是 function============== */

  Future<void> startRecording(Future<String> pathToAudio) async {
    Directory directory = Directory(path.dirname(await pathToAudio));
    //如果目錄不存在就創建目錄
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    if (myRecorder != null) {
      // myRecorder!.openAudioSession();
      await myRecorder!.startRecorder(
        toFile: await pathToAudio,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
      );

      if (myRecorder!.onProgress != null) {
        // ignore: no_leading_underscores_for_local_identifiers
        _recorderSubscription = myRecorder!.onProgress!.listen((e) {
          var date = DateTime.fromMillisecondsSinceEpoch(
              e.duration.inMilliseconds,
              isUtc: true);
          var timeText = DateFormat('mm:ss', 'en_GB').format(date);
          setState(() {
            _timerText =
                "${timeText.substring(0, 2)}分${timeText.substring(3, 5)}秒";
            if (date.minute >= 1) {
              _isOver1Min = true;
            } else {
              _isOver1Min = false;
            }
          });
        }, onError: (err) {
          print(err);
        }, onDone: () {
          print('subscription done!!');
        }, cancelOnError: false);
      }
      print("m: 錄音檔位置 ${await pathToAudio}");
      // getRecorderState();
    }
  }

  Future<void> stopRecording() async {
    if (myRecorder != null) {
      await _recorderSubscription!.cancel();
      await myRecorder!.stopRecorder();
      // getRecorderState();
    }
  }

  Future<void> playFunc(Future<String> pathToAudio) async {
    try {
      recordingPlayer.open(
        Audio.file(await pathToAudio),
        autoStart: true,
        showNotification: true,
      );
    } catch (e) {
      print("m: playFunc error: $e");
    }
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }

// 请求存储权限
  Future<void> requestPermission(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted) {
      // 用户授予了存储权限
      print('m: $permission granted');
    } else if (status.isPermanentlyDenied) {
      // 用户永久拒绝了权限
      print('m: $permission permanently denied');
      await openAppSettings(); // 打开应用程序设置页面，用户可以手动授予权限
    } else {
      // 用户拒绝了权限
      print('m: $permission denied');
      await permission.request();
    }
  }
}
