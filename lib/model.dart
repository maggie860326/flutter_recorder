// ignore_for_file: public_member_api_docs, sort_constructors_first
/*
 Model的职责：Model只负责封装数据，不做任何其它操作。
 */

import 'dart:math';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:recorder/function.dart';

const String hostUrl = 'http://10.0.2.2:5000/';
String wavUrl = '$hostUrl/api_test/uploadWav';
String textUrl = '$hostUrl/user/uploadJson';

// class UrlModel {
//   final String hostUrl = 'http://10.0.2.2:5000/';

//   String get wavUrl {
//     return '$hostUrl/api_test/uploadWav';
//   }

//   String get textUrl {
//     return '$hostUrl/user/uploadJson';
//   }
// }

class Question {
  final String name;
  final String description;
  final String? imagePath;
  Question({
    required this.name,
    required this.description,
    this.imagePath,
  });
}

List<Question> questionList = <Question>[
  Question(
      name: "回答問題1",
      description: "請您跟我聊聊您的家鄉，\n您的家鄉在哪呢？您到目前為止在您的家鄉住的時間久嗎？有什麼回憶嗎？"),
  Question(name: "回答問題2", description: "若在台灣有颱風預報時，通常會需要準備什麼？發生什麼事？"),
  Question(name: "回答問題3", description: "請問您昨天晚餐在哪裡吃飯？吃什麼？請描述細節及內容。"),
  Question(name: "回答問題4", description: "若您想要泡一杯茶或咖啡，您會怎麼做？請描述細節及內容。"),
  Question(name: "回答問題5", description: "請您跟我聊聊您最近喜歡看的節目是什麼？ 從電視、Youtube或廣播"),
  Question(name: "回答問題6", description: "一年中的四季，您最喜歡哪一個季節？為什麼？"),
  Question(
      name: "描述圖片1",
      description: "請描述圖片的內容",
      imagePath: "assets/image/picture1.jpg"),
  Question(
      name: "描述圖片2",
      description: "請描述圖片的內容",
      imagePath: "assets/image/picture2.jpg"),
  Question(
      name: "描述圖片3",
      description: "請描述圖片的內容",
      imagePath: "assets/image/picture3.jpg"),
];

class PathModel {
  final String testDateTime = "testDate";
  // DateFormat('yyyy-MM-dd kk:mm').format(DateTime.now());

  Future<String> get appDocPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get pathToModel async {
    const String path = 'ggml/ggml-tiny.bin';
    var filePath = "${await appDocPath}/$path";
    var file = File(filePath);

    //先確認 file 有沒有在 app 專屬資料夾中
    if (file.existsSync()) {
      print("m: $filePath 已存在");
      return filePath;
    } else {
      //如果 file 不在 app 專屬資料夾中，則將 file 從 assets 複製到 app 專屬資料夾
      print("m: $filePath 不存在");
      final byteData = await rootBundle.load('assets/$path');
      print("m: 已由 assets/$path 抓取檔案");
      final buffer = byteData.buffer;
      await file.create(recursive: true);

      file.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      print("m: 已由 assets/$path 將檔案寫入 $filePath");
      return filePath;
    }
  }

  int _index = -1;
  int get index => _index;
  set index(int questionIndex) {
    _index = questionIndex;
  }

  Future<String> pathToAudio({int? index}) async {
    index ??= _index;
    return "${await appDocPath}/test/$testDateTime/recording/question$index.wav";
  }

  Future<String> pathToText({int? index}) async {
    index ??= _index;
    return "${await appDocPath}/test/$testDateTime/text/question$index.txt";
  }

  Future<void> submitWav() async {
    File wavFile = File(await pathToAudio());
    if (wavFile.existsSync()) {
      String result = await sendWavFileToServer(wavUrl, wavFile);
      print("m: 傳送wav到後端結果: $result");
    } else {
      print("m: wav 檔不存在");
    }
  }

  PathModel copyWith() {
    return PathModel();
  }
}
