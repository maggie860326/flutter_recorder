// ignore_for_file: avoid_print, file_names

import 'dart:async';
import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:recorder/model.dart';
import "package:whisper_flutter/whisper_flutter.dart";
import "package:cool_alert/cool_alert.dart";
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'function.dart';

class RecorderPage extends StatefulWidget {
  const RecorderPage(
      {Key? key,
      required this.index,
      // required this.hostUrl,
      // required this.wavUrl,
      required this.testDateTime})
      : super(key: key);
  final int index;
  // final String hostUrl;
  // final String wavUrl;
  final String testDateTime;
  @override
  State<RecorderPage> createState() => _RecorderPageState(
      index: index,
      // hostUrl: hostUrl,
      // wavUrl: wavUrl,
      testDateTime: testDateTime);
}

class _RecorderPageState extends State<RecorderPage>
// with AutomaticKeepAliveClientMixin
{
  int index;
  // final String hostUrl;
  // final String wavUrl = Provider.of<UrlModel>(context, listen: false).wavUrl;
  final String testDateTime;

  _RecorderPageState(
      {required this.index,
      // required this.hostUrl,
      // required this.wavUrl,
      required this.testDateTime});

  //看 whisper 完成了沒
  Completer completer = Completer();

  //recorder 相關變數
  FlutterSoundRecorder? myRecorder = FlutterSoundRecorder();
  StreamSubscription? _recorderSubscription;
  final recordingPlayer = AssetsAudioPlayer();
  String _recorderState = "準備好後請按下按鈕";
  bool _playAudio = false;
  bool _isRecording = false;

  String _timerText = '00:00:00';
  List<String> questions = [
    "請您跟我聊聊您的家鄉，\n您的家鄉在哪呢？您到目前為止在您的家鄉住的時間久嗎？有什麼回憶嗎？",
    "若在台灣有颱風預報時，通常會需要準備什麼？發生什麼事？",
    "請問您昨天晚餐在哪裡吃飯？吃什麼？請描述細節及內容。",
    "若您想要泡一杯茶或咖啡，您會怎麼做？請描述細節及內容。",
    "請您跟我聊聊您最近喜歡看的節目是什麼？ 從電視、Youtube或廣播",
    "一年中的四季，您最喜歡哪一個季節？為什麼？",
  ];

  @override
  void initState() {
    super.initState();
    initializer();
  }

  void initializer() async {
    print("m: 第 $index 頁 initialized.\n");
    //要求權限
    await requestPermission(Permission.microphone);

    //取得路徑
    // appDocPath = await _appDocPath;
    // print("m: App Document Path is: $appDocPath");

    // pathToAudio = "$appDocPath/test/$testDateTime/recording/question$index.wav";
    // pathToText = "$appDocPath/test/$testDateTime/text/question$index.txt";
    // pathToModel = await _getFilePathFromAssets("ggml/ggml-tiny.bin");

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
    print("m: 第 $index 頁 disposed.\n");
  }

  @override
  Widget build(BuildContext context) {
    print("m: 第 $index 頁 build");
    //各種路徑
    // String appDocPath = "";
    String pathToAudio =
        Provider.of<PathModel>(context, listen: false).pathToAudio(index);
    String pathToText = "";
    String pathToModel = "";
    // bool isWhisperComplete = Provider.of<bool>(context, listen: true);

    // print("m: whisper 完成了沒: ${completer.isCompleted}");
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          // height: 50,
          Text(
            "問題 ${index + 1}",
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(20),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 0.5),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              questions[index],
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
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
          FloatingActionButton.large(
            heroTag: "btn $index",
            backgroundColor: Colors.red,
            onPressed: () {
              if (!_isRecording) {
                setState(() {
                  _recorderState = "現在請說話";
                  _isRecording = !_isRecording;
                });
                startRecording(pathToAudio);
              } else {
                setState(() {
                  _recorderState = "準備好後請按下按鈕";
                  _isRecording = !_isRecording;
                });
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
          //播放錄音檔
          // ElevatedButton.icon(
          //   style: ElevatedButton.styleFrom(
          //       elevation: 9.0, backgroundColor: Colors.red),
          //   onPressed: () {
          //     setState(() {
          //       _playAudio = !_playAudio;
          //     });
          //     if (_playAudio) {
          //       playFunc();
          //     } else {
          //       stopPlayFunc();
          //     }
          //   },
          //   icon: _playAudio
          //       ? const Icon(
          //           Icons.stop,
          //         )
          //       : const Icon(Icons.play_arrow),
          //   label: _playAudio
          //       ? const Text(
          //           "停止播放",
          //           style: TextStyle(
          //             fontSize: 28,
          //           ),
          //         )
          //       : const Text(
          //           "播放錄音檔",
          //           style: TextStyle(
          //             fontSize: 28,
          //           ),
          //         ),
          // ),
          // const SizedBox(
          //   height: 20,
          // ),
          ElevatedButton(
            onPressed: () {
              Provider.of<PathModel>(context, listen: false).submitWav(index);
              runWhisper();
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
          // const SizedBox(
          //   height: 20,
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     // isWhisperComplete = completer.isCompleted;
          //     print("m: whisper 完成了沒: ${completer.isCompleted}}");
          //   },
          //   child: const Text(
          //     "看 whisper 跑完了沒",
          //     style: TextStyle(
          //       fontSize: 28,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  /* ==============以下是 function============== */

  // //取得 app 專屬資料夾路徑
  // Future<String> get _appDocPath async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   // print(directory.path);
  //   return directory.path;
  // }

  //將 asset 中檔案複製到 app 專屬資料夾，並取得其在 app 專屬資料夾中的路徑
  // Future<String> _getFilePathFromAssets(String path) async {
  //   var filePath = "$appDocPath/$path";
  //   var file = File(filePath);
  //   //先確認 file 有沒有在 app 專屬資料夾中
  //   if (file.existsSync()) {
  //     print("m: $filePath 已存在");
  //     return filePath;
  //   } else {
  //     //如果 file 不在 app 專屬資料夾中，則將 file 從 assets 複製到 app 專屬資料夾
  //     print("m: $filePath 不存在");
  //     final byteData = await rootBundle.load('assets/$path');
  //     print("m: 已由 assets/$path 抓取檔案");
  //     final buffer = byteData.buffer;
  //     await file.create(recursive: true);

  //     file.writeAsBytes(
  //         buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  //     print("m: 已由 assets/$path 將檔案寫入 $filePath");
  //     return filePath;
  //   }
  // }

  // Future<void> submitWav(String wavUrl) async {
  //   File wavFile = File(pathToAudio);
  //   if (wavFile.existsSync()) {
  //     String result = await sendWavFileToServer(wavUrl, wavFile);
  //     print("m: 傳送wav到後端結果: $result");
  //   } else {
  //     print("m: wav 檔不存在");
  //   }
  // }

  //執行Whisper
  Future<void> runWhisper() async {
    //檢查 audio、model 路徑是否正確
    if (pathToAudio.isEmpty) {
      await CoolAlert.show(
        context: context,
        type: CoolAlertType.info,
        text: "找不到此音檔",
      );

      print("m: audio is empty");
      return;
    }
    if (pathToModel.isEmpty) {
      await CoolAlert.show(
          context: context, type: CoolAlertType.info, text: "找不到此 model");

      print("m: model is empty");
      return;
    }

    // Whisper
    print("m: Start transcribe");
    DateTime startTimestamp = DateTime.now();
    Whisper whisper = Whisper(
      whisperLib: "libwhisper.so",
    );
    var res = await whisper.request(
      whisperRequest: WhisperRequest.fromWavFile(
          audio: File(pathToAudio),
          model: File(pathToModel),
          is_no_timestamps: true,
          language: "zh"),
    );

    DateTime endTimestamp = DateTime.now();
    Duration timeElapsed = endTimestamp.difference(startTimestamp);
    print("m: Time elapsed:  ${timeElapsed.inMilliseconds} milliseconds");
    String? text = res.text;
    if (text != null) {
      await saveText(text);
    }
    print("m: $text");
    completer.complete();
    // isWhisperComplete = completer.isCompleted;
    return;
  }

  //儲存轉錄文字
  Future<void> saveText(String str) async {
    Directory directory = Directory(path.dirname(pathToText));
    try {
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final file = File(pathToText);
      file.writeAsString(str);
      print("m: 成功寫入 $pathToText");
    } catch (e) {
      print("m: $e");
    }
  }

  // void getRecorderState() {
  //   if (myRecorder!.isStopped) {
  //     setState(() {
  //       _recorderState = "準備好後請按下按鈕";
  //     });
  //   } else if (myRecorder!.isRecording) {
  //     setState(() {
  //       _recorderState = "現在請說話";
  //     });
  //   } else if (myRecorder!.isPaused) {
  //     setState(() {
  //       _recorderState = "錄音已暫停";
  //     });
  //   } else {
  //     setState(() {
  //       _recorderState = "Unknown";
  //     });
  //   }
  // }

  Future<void> startRecording(String pathToAudio) async {
    Directory directory = Directory(path.dirname(pathToAudio));
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    if (myRecorder != null) {
      // myRecorder!.openAudioSession();
      await myRecorder!.startRecorder(
        toFile: pathToAudio,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
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
      print("m: 錄音檔位置 $pathToAudio");
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

//   Future<void> playFunc() async {
//     recordingPlayer.open(
//       Audio.file(pathToAudio),
//       autoStart: true,
//       showNotification: true,
//     );
//   }

//   Future<void> stopPlayFunc() async {
//     recordingPlayer.stop();
//   }
// }

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
