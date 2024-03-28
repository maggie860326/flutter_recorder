// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'config.dart';
import 'model.dart';

// String fakeDateTime = "2010-01-01-00:00:00";

void submitWav(PathModel pathModel) async {
  File wavFile = File(await pathModel.pathToAudio());
  if (wavFile.existsSync()) {
    print('m: 開始傳送wav');
    String result = await sendWavFileToServer(
        wavUrl, wavFile, pathModel.testDateTime); //! 測試 pathModel.testDateTime
    print("m: 傳送wav到後端結果: $result");
  } else {
    print("m: wav 檔不存在");
  }
}

enum SubmitState {
  idle,
  fileNotFound, // 沒作用
  stringIsBlank, // 執行中
  success, // 轉錄成功
  failure, // 加载失败
}

//合併指定大題中個小題的文字檔，整理成json格式後傳到後端
Future<SubmitState> submitText(PathModel pathModel, int index) async {
  String pathToReport = await pathModel.pathToReport(index);

  Map<String, dynamic> jsonData = {
    "task_type": taskList[index].task_type,
    "userID": pathModel.userID,
    "user_name": "admin",
    "date_time": pathModel.testDateTime, //! 測試 pathModel.testDateTime
  };

  String text = "";
  bool isDone = false;

//合併各小題文字檔
  for (int i = 0; i < taskList[index].questionNum; i++) {
    File file = File(await pathModel.pathToText(i));
    if (file.existsSync()) {
      text = text + await file.readAsString();
    } else {
      return SubmitState.fileNotFound;
    }
  }
  if (text.trim().isEmpty) {
    return SubmitState.stringIsBlank;
  } else {
    try {
      jsonData["text"] = text;
      // jsonData["text"] =
      //     "我家鄉在屏東 然後從出生到高中 都 高中18歲都在屏東 對 回憶嗎 應該說是個很無聊的地方 屏東嗎 我會推薦去 我不會推薦去墾丁 但是我會推薦去山地門啊 或者是屏東市區 對 因為大部分的人都會比較想要去墾丁 像是泡麵、麵包、罐頭類的 那人家有些會準備電池水那些我是不會 應該是大家比較常見到巴巴水災吧 因為那時候屏東還蠻嚴重的 整個都淹水淹進來 但是我們家那邊可能地勢比較高 沒有遇到這個問題 但是那種同學朋友都 放個番茄蛋麵對 就是自己去超市買番茄蛋 跟一些肉啊菜啊 自己回家燉煮 我不會去觀光客的地方 就像人家說的我家巷口 對 就是我出去 就有一家牛肉攤 對 但是那不是觀光客會去吃的 那個開源路 轉角那邊 因為他的牛肉攤 一碗才70塊而已 而且他的蔬果湯 他是不加鹽巴調味料的 就是可能加個冰塊當作水果冰茶就這樣子而已 因為我身體會有一些心肌或晚上睡不著覺 對 所以我就會自己避免掉 就自己開心一下 路嗎 嗯 我都半糖為兵 對 我覺得我不會去推薦 應該說印象深刻不是他的內容 是他講話的風趣 對 電視節目比較多 我 因為我是最近有看那個 就是 妥中她跟 他們一起 合開了一個 對我來說在南部 尤其現在這種氣候 其實沒有很常下雨 所以我覺得往山上跑或者是往 因為我是蠻戶外的人 所以我覺得往外跑就是 天氣來說非常的舒服 不像冬天可能很冷 對 還蠻多的耶";

      await sendJsonDataToServer(textUrl, jsonData).then((res) async {
        print('m: 傳送json結果: $res');
        jsonData.remove("text");

        try {
          print('m: 要求計算結果中');
          await fetchJsonResultFromServer(resultUrl, jsonData)
              .then((response) async {
            // print('m: 取得計算結果: ${jsonEncode(response)}');
            print("m: 儲存json路徑: $pathToReport");
            await _writeJson(response, pathToReport).then((value) {
              isDone = value;
              print("m: fetch and write isdone: $isDone");
            });
          });
          return isDone;
        } catch (e) {
          print('m: 取得計算結果失敗: $e');
          // return false;
        }
      });
      return SubmitState.success;
    } catch (e) {
      print('m: 傳送json失敗: $e');
      return SubmitState.failure;
    }
  }
}

//儲存json數據
Future<bool> _writeJson(Map<String, dynamic> _json, String _filePath) async {
  //3. Convert _json ->_jsonString
  String _jsonString = jsonEncode(_json);
  // print('3.(_writeJson) _jsonString: $_jsonString\n - \n');

  Directory directory = Directory(path.dirname(_filePath));
  bool isDone = false;
  try {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    //4. Write _jsonString to the _filePath
    final file = File(_filePath);
    await file.writeAsString(_jsonString).then((value) {
      isDone = true;
      print("m: _writeJson isDone = $isDone");
    });
    print("m: 儲存json成功");
    return true;
  } catch (e) {
    print("m: 儲存json失敗: $e");
    return false;
  }
}

Future<Map<String, dynamic>> readJson(Future<String> _filePath) async {
  final file = File(await _filePath);
  Map<String, dynamic> _json = {};

  // If the _file exists->read it: update initialized _json by what's in the _file
  if (file.existsSync()) {
    try {
      //1. Read _jsonString<String> from the _file.
      String _jsonString = await file.readAsString();
      // print('m: 1.(_readJson) _jsonString: $_jsonString');

      //2. Update initialized _json by converting _jsonString<String>->_json<Map>
      _json = await jsonDecode(_jsonString);
      print('m: 2.(_readJson) _json: $_json \n - \n');
    } catch (e) {
      // Print exception errors
      print('m: Tried reading _file error: $e');
      // If encountering an error, return null
    }
  }
  return _json;
}

/* 以下是執行 http post 的 function */

// 傳送JSON
Future<String> sendJsonDataToServer(
    String url, Map<String, dynamic> jsonData) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'charset': 'UTF-8'},
      body: json.encode(jsonData),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData.toString();
      //return responseData;
    } else {
      return 'Failed to send data to the server';
    }
  } catch (error) {
    return 'Error: $error';
  }
}

// 傳送 WAV
Future<String> sendWavFileToServer(
    String url, File wavFile, String testDateTime) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    // add wav
    var multipartFile =
        await http.MultipartFile.fromPath('wav_file', wavFile.path);
    request.files.add(multipartFile);

    request.fields['date_time'] = testDateTime; // 該次測驗日期
    var response = await request.send();

    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return responseData.toString();
    } else {
      return 'Failed to send WAV file to the server: $responseData';
    }
  } catch (error) {
    return 'Error: $error';
  }
}

// 取得雷達圖
Future<String> sendPngRequestToServer(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // 返回 PNG 文件的 Base64 编码
      return response.body;
    } else {
      return 'Failed to fetch PNG from the server';
    }
  } catch (error) {
    print(error);
    return 'Error: $error';
  }
}

// 取得結果
Future<Map<String, dynamic>> fetchJsonResultFromServer(
    String url, Map<String, dynamic> authData) async {
  try {
    var initialResponse = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(authData),
    );

    if (initialResponse.statusCode == 200) {
      var jsonResponse = json.decode(initialResponse.body);

      // 檢查後端是否已完成計算
      while (jsonResponse['status'] != 'completed' &&
          jsonResponse['status'] != 'error') {
        // 等待一段時間再次請求，例如每60秒檢查一次
        await Future.delayed(Duration(seconds: 60));
        var response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(authData),
        );
        if (response.statusCode != 200) {
          print('m: Failed to fetch data: ${response.body}');
          return {'status': 'error', 'message': 'Failed to fetch data'};
        }
        jsonResponse = json.decode(response.body);
      }

      return jsonResponse;
    } else {
      print('m: Initial request failed: ${initialResponse.body}');
      return {'status': 'error', 'message': 'Initial request failed'};
    }
  } catch (error) {
    print('m: Error: $error');
    return {'status': 'error', 'message': 'Error: $error'};
  }
}
