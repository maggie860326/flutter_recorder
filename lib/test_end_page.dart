// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'function.dart';

class TestEndPage extends StatelessWidget {
  final String hostUrl;
  final String taskIndex;
   final String testDateTime;
  const TestEndPage(
      {super.key, required this.hostUrl, required this.taskIndex,
      required this.testDateTime});

  @override
  Widget build(BuildContext context) {
    final String textUrl = '$hostUrl/user/uploadJson';

    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 100,
          ),
          const Text(
            "您已完成測驗",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50.0),
            height: 150,
            child: const Text(
              "系統正在處理您的錄音檔，此過程需要一段時間，請點擊下方按鈕查看處理進度。",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
            child: const Text("查看測驗報告"),
            onPressed: () {
              submitText(context, textUrl);
            },
          ),
        ],
      ),
    );
  }

//取得 app 專屬資料夾路徑
  Future<String> get _appDocPath async {
    final directory = await getApplicationDocumentsDirectory();
    // print(directory.path);
    return directory.path;
  }

  void submitText(context, String textUrl) async {
    int taskNum = 0;
    switch (taskIndex) {
      case "task_1":
        taskNum = 6;
        break;
      case "task_2":
        taskNum = 3;
        break;
      default:
        print("m: 無法判斷為哪個 task");
    }
    String appDocPath = await _appDocPath;
    final Map<String, String> jsonData = {};
    //
     jsonData[taskIndex] = "test";

//
    try {
      for (int i = 0; i < taskNum; i++) {
        File file = File("$appDocPath/test/$testDateTime/text/question$i.txt");
        if (file.existsSync()) {
          final text = await file.readAsString();
          jsonData['$i'] = text;
        } else {
          await CoolAlert.show(
            context: context,
            type: CoolAlertType.info,
            text: "第 ${i + 1} 題的錄音檔還未轉錄完成",
          );
          print("m: 第 ${i + 1} 題的錄音檔還未轉錄完成");
          return;
        }
      }
    } catch (e) {
      print("m: $e");
    }
    print("m: $jsonData");
    sendJsonDataToServer(textUrl, jsonData).then((response) {});
    Provider.of<PageController>(context, listen: false).nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    return;
  }
}
