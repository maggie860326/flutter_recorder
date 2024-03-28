// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
/*
 Model的职责：Model只负责封装数据，不做任何其它操作。
 */

import 'dart:core';
import 'package:flutter/services.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'config.dart';
import 'package:intl/intl.dart' show DateFormat;

class PathModel {
  String userID = "";
  late String testDateTime;

  String setUserID(input) {
    userID = input;
    return userID;
  }

  String setTestDateTime() {
    DateTime now = DateTime.now();
    testDateTime = DateFormat('yyyy-MM-dd-kk:mm:ss').format(now);
    // testDateTime = "2000-01-01-00:00:00";
    return testDateTime;
  }

  Future<String> get appDocPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get pathToModel async {
    const String path = 'ggml/ggml-base.bin';
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

  int index = -1;

  int questionNo = 0;
  // List<Question> questionList = task_1_Q + task_2_Q;

  Future<String> pathToAudio([int? i]) async {
    i ??= index;
    return "${await appDocPath}/test/${userID}/$testDateTime/recording/${userID}_${questionList[i].task_type}_${format('{:02d}', questionList[i].questionNo)}.wav";
  }

  Future<String> pathToText([int? i]) async {
    i ??= index;
    return "${await appDocPath}/test/${userID}/$testDateTime/text/${userID}_${questionList[i].task_type}_${format('{:02d}', questionList[i].questionNo)}.txt";
  }

  Future<String> pathToReport(int i) async {
    return "${await appDocPath}/test/result/${userID}_${testDateTime}.json";
  }

  PathModel copyWith() {
    return PathModel();
  }
}
