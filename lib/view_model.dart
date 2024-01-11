import 'package:flutter/material.dart';

enum ViewState {
  idle, // 沒作用
  waiting, // 等待中
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


}


