// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';
import 'recorder_page.dart';
import 'recorder_image_page.dart';
import 'test_instruction_page.dart';
import 'test_end_page.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import "report_page.dart";

class isCompleteProvider extends ChangeNotifier {
  //檢查 whisper 完成了沒
  var isCompleteList = [false, false, false, false, false, false];

  bool isComplete(int index) => isCompleteList[index];

  bool get isAllComplete => isCompleteList.every((key) => key == true);

  setComplete(int index) {
    isCompleteList[index] = true;
    notifyListeners();
  }
}

class SwipeTest extends StatefulWidget {
  final int initialPage;
  final String hostUrl;
  const SwipeTest(
      {super.key, required this.initialPage, required this.hostUrl});
  @override
  _SwipeTestState createState() =>
      _SwipeTestState(initialPage: initialPage, hostUrl: hostUrl);
}

class _SwipeTestState extends State<SwipeTest> {
  final int initialPage;
  final String hostUrl;
  _SwipeTestState({required this.initialPage, required this.hostUrl});

  late PageController controller;
  late String wavUrl;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: initialPage);
    wavUrl = '$hostUrl/api_test/uploadWav';
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const TestInstructionPage(
          instruction: "在接下來的測驗中，你會看到一組問題，請您看完問題後，按下錄音按鈕並開始回答。"),
      // Provider<bool>.value(
      //     value: completer0,
      //     builder: (context, child){return RecorderPage(index: 0, hostUrl: hostUrl, wavUrl: wavUrl);}),
      RecorderPage(index: 0, hostUrl: hostUrl, wavUrl: wavUrl),
      RecorderPage(index: 1, hostUrl: hostUrl, wavUrl: wavUrl),
      RecorderPage(index: 2, hostUrl: hostUrl, wavUrl: wavUrl),
      RecorderPage(index: 3, hostUrl: hostUrl, wavUrl: wavUrl),
      RecorderPage(index: 4, hostUrl: hostUrl, wavUrl: wavUrl),
      RecorderPage(index: 5, hostUrl: hostUrl, wavUrl: wavUrl),
      const TestInstructionPage(
          instruction: "在接下來的測驗中，你每次會看到一張圖片，請您按下錄音按鈕並盡可能描述圖片中發生的事情與細節。"),
      RecorderImagePage(index: 6, hostUrl: hostUrl, wavUrl: wavUrl),
      RecorderImagePage(index: 7, hostUrl: hostUrl, wavUrl: wavUrl),
      RecorderImagePage(index: 8, hostUrl: hostUrl, wavUrl: wavUrl),
      TestEndPage(hostUrl: hostUrl),
      ReportPage(hostUrl: hostUrl)
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("測驗流程"), actions: [
        IconButton(
            onPressed: () => controller.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
            icon: const Icon(Icons.keyboard_arrow_left)),
        IconButton(
            onPressed: () => controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
            icon: const Icon(Icons.keyboard_arrow_right))
      ]),
      body: PageView.builder(
        itemBuilder: (context, index) {
          return ChangeNotifierProvider.value(
              value: controller, child: pages[index]);
        },
        controller: controller,
        itemCount: pages.length,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          // setState(() {
          //   pageIndex = index;
          // });
          // print("Page ${index}");
        },
      ),
    );
  }
}
