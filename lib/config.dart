/*這份文件用途為修改路由和題目*/

import "dart:core";
import "package:flutter/material.dart";
import "package:recorder/test_end_page.dart";
import "recorder_page.dart";
import "test_instruction_page.dart";
import 'report_chart_page.dart';
import 'user_id_page.dart';

//後端路由
const String hostUrl = 'http://140.116.158.105:80';
String textUrl = '$hostUrl/api_test/uploadJson';
String wavUrl = '$hostUrl/api_test/uploadWav';
String resultUrl = '$hostUrl/api_test/getResult';

//制定大題數量與指導語
class Task {
  final String task_type;
  final String taskInstruction;
  final int questionNum;
  Task(
      {required this.task_type,
      required this.taskInstruction,
      required this.questionNum});
}

//制定小題格式
class Question {
  String description;
  int questionNo;
  String task_type;
  String task_name;
  String? imagePath;

  Question.task1_Q({
    required this.description,
    required this.questionNo,
  })  : task_type = "task_1",
        task_name = "回答問題";

  Question.task2_Q(
      {required this.description,
      required this.questionNo,
      required this.imagePath})
      : task_type = "task_2",
        task_name = "描述圖片";
}

//列出大題指導語和題目數量
List<Task> taskList = [
  Task(
      task_type: "task_1",
      questionNum: 6,
      taskInstruction: "在接下來的測驗中，你會看到一組問題，請您看完問題後，按下錄音按鈕並開始回答。錄音長度須至少一分鐘。"),
  Task(
      task_type: "task_2",
      questionNum: 3,
      taskInstruction:
          "在接下來的測驗中，你每次會看到一張圖片，請您按下錄音按鈕並盡可能描述圖片中發生的事情與細節。錄音長度須至少一分鐘。")
];

//列出第一大題「回答問題」的問題
final task_1_description = [
  "請您跟我聊聊您的家鄉，\n您的家鄉在哪呢？您到目前為止在您的家鄉住的時間久嗎？有什麼回憶嗎？",
  "若在台灣有颱風預報時，通常會需要準備什麼？發生什麼事？",
  "請問您昨天晚餐在哪裡吃飯？吃什麼？請描述細節及內容。",
  "若您想要泡一杯茶或咖啡，您會怎麼做？請描述細節及內容。",
  "請您跟我聊聊您最近喜歡看的節目是什麼？ 從電視、Youtube或廣播",
  "一年中的四季，您最喜歡哪一個季節？為什麼？",
];

//列出第二大題「描述圖片」的圖片路徑
const task_2_imagePath = [
  "assets/image/picture1.jpg",
  "assets/image/picture2.jpg",
  "assets/image/picture3.jpg",
];

//依據上面兩個 List 生成 Task1_Q 和 Task2_Q 的 instances
List<Question> task_1_Q = List<Question>.generate(
    task_1_description.length,
    (index) => Question.task1_Q(
        description: task_1_description[index], questionNo: index + 1));

//! 因為 isolate 同時只能有 8 個，所以第二大題還不能加入app中
// List<Question> task_2_Q = List<Question>.generate(
//     task_2_imagePath.length,
//     (index) => Question.task2_Q(
//         description: "請描述圖片的內容",
//         imagePath: task_2_imagePath[index],
//         questionNo: index + 1));

List<Widget> pages = [
  UserIDPage(),
  TestInstructionPage(instruction: taskList[0].taskInstruction),
  const RecorderPage(index: 0),
  const RecorderPage(index: 1),
  const RecorderPage(index: 2),
  const RecorderPage(index: 3),
  const RecorderPage(index: 4),
  const RecorderPage(index: 5),
  //! 因為 isolate 同時只能有 8 個，所以第二大題還不能加入app中
  // TestInstructionPage(instruction: taskList[1].taskInstruction),
  // RecorderPage(index: 6),
  // RecorderPage(index: 7),
  // RecorderPage(index: 8),
  const TestEndPage(),
  // ReportChartPage(),
  RadarChartPage()
];

// List<Question> questionList = task_1_Q + task_2_Q;
List<Question> questionList = task_1_Q;
