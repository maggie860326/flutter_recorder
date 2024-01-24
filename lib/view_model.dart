// ignore_for_file: avoid_print

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'dart:io';
import "package:whisper_flutter/whisper_flutter.dart";
import 'function.dart';
import 'package:path/path.dart' as path;

enum ViewState {
  idle, // 沒作用
  running, // 執行中
  success, // 轉錄成功
  failure, // 加载失败
}

// 用來保存每個whisper的運作狀態
class WhisperViewModel with ChangeNotifier {
  List<ViewState> _states = List.generate(9, (i) => ViewState.idle);

  // ViewState get state => _state;

  set isRunning(int index) {
    _states[index] = ViewState.running;
    notifyListeners();
  }

  set isSuccess(int index) {
    _states[index] = ViewState.success;
    notifyListeners();
  }

//執行Whisper
  Future<void> runWhisper(BuildContext context, PathModel pathModel) async {
    File audioFile = File(await pathModel.pathToAudio);
    File modelFile = File(await pathModel.pathToModel);

    //檢查 audio 檔案是否存在
    if (!audioFile.existsSync()) {
      await CoolAlert.show(
        context: context,
        type: CoolAlertType.info,
        text: "找不到此音檔",
      );
      print("m: audio is empty");
      return;
    } //檢查 model 檔案是否存在
    else if (!modelFile.existsSync()) {
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
    //通知訂閱者 whisper 開始執行
    _states[pathModel.index] = ViewState.running;
    notifyListeners();

    try {
      //真正執行 whisper 的地方
      var res = await whisper.request(
        whisperRequest: WhisperRequest.fromWavFile(
            audio: audioFile,
            model: modelFile,
            is_no_timestamps: true,
            language: "zh"),
      );

      DateTime endTimestamp = DateTime.now();
      Duration timeElapsed = endTimestamp.difference(startTimestamp);
      print("m: Time elapsed:  ${timeElapsed.inMilliseconds} milliseconds");
      String? text = res.text;
      if (text != null) {
        await _saveText(text, await pathModel.pathToText);
      }
      print("m: $text");
       //通知訂閱者 whisper 成功
      _states[pathModel.index] = ViewState.success;
      notifyListeners();
    } catch (e) {
      //通知訂閱者 whisper 失敗
      _states[pathModel.index] = ViewState.failure;
      notifyListeners();
    }
    return;
  }

  //儲存轉錄文字
  Future<void> _saveText(String str, String pathToText) async {
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
}
