/*
 Model的职责：Model只负责封装数据，不做任何其它操作。
 */

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:recorder/function.dart';



const String hostUrl = 'http://10.0.2.2:5000/';

String wavUrl = '$hostUrl/api_test/uploadWav';

String textUrl = '$hostUrl/user/uploadJson';



class UrlModel {
  final String hostUrl = 'http://10.0.2.2:5000/';

  String get wavUrl {
    return '$hostUrl/api_test/uploadWav';
  }

  String get textUrl {
    return '$hostUrl/user/uploadJson';
  }
}

class PathModel {
  final String testDateTime =
      DateFormat('yyyy-MM-dd kk:mm').format(DateTime.now());

  Future<String> get appDocPath async {
    final directory = await getApplicationDocumentsDirectory();
    print("m: App Document Path is: $appDocPath");
    return directory.path;
  }

  Future<String> get pathToModel async {
    const String path = 'ggml/ggml-tiny.bin';
    var filePath = "$appDocPath/$path";
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

  String pathToAudio(int index) {
    return "$appDocPath/test/$testDateTime/recording/question$index.wav";
  }

  String pathToText(int index) {
    return "$appDocPath/test/$testDateTime/text/question$index.txt";
  }

  Future<void> submitWav(int index) async {
    File wavFile = File(pathToAudio(index));
    if (wavFile.existsSync()) {
      String result = await sendWavFileToServer(wavUrl, wavFile);
      print("m: 傳送wav到後端結果: $result");
    } else {
      print("m: wav 檔不存在");
    }
  }
}
