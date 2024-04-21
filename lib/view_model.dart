// ignore_for_file: avoid_print

/*
WhisperViewModel: 集合與 Whisper 相關的所有functions
runWhisper
_saveText
checkTextSaved
ifAllDoneThenSendTextToServer
 */

import 'package:flutter/material.dart';
import 'model.dart';
import 'dart:io';
import "package:whisper_flutter/whisper_flutter.dart";
import 'function.dart';
import 'package:path/path.dart' as path;
import 'config.dart';

//定義 whisper 轉錄狀態
enum ViewState {
  idle, // 沒作用
  running, // 執行中
  success, // 轉錄成功
  failure, // 轉錄失敗
  textSaved, //已儲存文字檔
}

class WhisperViewModel with ChangeNotifier {
  final List<ViewState> _states =
      List.generate(questionList.length, (i) => ViewState.idle);

  List<ViewState> get states => _states;

//! 執行Whisper
  Future<void> runWhisper(BuildContext context, PathModel pathModel) async {
    File audioFile = File(await pathModel.pathToAudio());
    File modelFile = File(await pathModel.pathToModel);
    int index = pathModel.index;
    String pathToText = await pathModel.pathToText();

    DateTime startTimestamp = DateTime.now();
    Whisper whisper = Whisper(
      whisperLib: "libwhisper.so",
    );
    //通知訂閱者 whisper 開始執行
    _states[index] = ViewState.running;
    notifyListeners();

    try {
      //真正執行 whisper 的地方，whisper.request會建立新的 isolate 來執行轉錄作業
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
      _states[index] = ViewState.success;
      String? text = res.text;
      if (text != null) {
        await _saveText(text, pathToText, index);
      }
      // print("m: Whisper 轉錄文字=$text");
      //通知訂閱者 whisper 成功
      notifyListeners();
    } catch (e) {
      //通知訂閱者 whisper 失敗
      _states[index] = ViewState.failure;
      notifyListeners();
    }
    return;
  }

  //! 儲存轉錄好的字串為 txt file
  Future<void> _saveText(String str, String pathToText, int index) async {
    // print("m: Whisper submitText: index=$index, pathToText=$pathToText");
    Directory directory = Directory(path.dirname(pathToText));
    try {
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final file = File(pathToText);
      file.writeAsString(str);
      print("m: 文字檔寫入 $pathToText");
      _states[index] = ViewState.textSaved;
    } catch (e) {
      print("m: $e");
    }
  }

//! 確認有沒有已經存好的文字檔，如果有則將其狀態設為 textSaved
  void checkTextSaved(PathModel pathModel) async {
    print("m: 檢查已存在的文字檔");
    for (int i = 0; i < questionList.length; i++) {
      String pathToText = await pathModel.pathToText(i);
      File file = File(pathToText);
      if (file.existsSync()) {
        // print("m: checkTextSaved 存在 $pathToText");
        _states[i] = ViewState.textSaved;
        notifyListeners();
      } else {
        // print("m: checkTextSaved 不存在 $pathToText");
      }
    }
  }

//! 檢查音檔轉錄為文字的進度，如果都完成則傳送文字檔到後端
  Future<SubmitState> ifAllDoneThenSendTextToServer(
      PathModel pathModel, PageController controller) async {
    SubmitState state = SubmitState.idle;

    //for loop: 檢查是不是每一題都轉錄完成
    for (int i = 0; i < questionList.length; i++) {
      if (_states[i] == ViewState.textSaved) {
        continue;
      } else {
        print("m: ifAllDone: Not yet.");
        return state;
      }
    }
    //轉錄都完成，傳送文字檔到後端
    print("m: ifAllDone: All done. Call submitText.");
    //submitText 定義在 function.dart 中
    await submitText(pathModel, 0).then((value) {
      state = value;
      print("m: ifAllDone state=$state");
      switch (state) {
        //如果傳送成功，則跳到報告頁面
        case SubmitState.success:
          {
            print("m:跳轉下一頁");
            controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
          }
        //如果字串為空，則通知監聽者(刷新TestEndPage的轉錄狀態列表)
        case SubmitState.stringIsBlank:
          notifyListeners();
        default:
      }
    });
    return state;
  }
}
