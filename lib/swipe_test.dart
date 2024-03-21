// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:recorder/model.dart';
import 'recorder_page.dart';
import 'test_instruction_page.dart';
import 'test_end_page.dart';
import 'package:provider/provider.dart';
// import 'dart:async';
import "report_page.dart";
import 'package:intl/intl.dart' show DateFormat;
import 'testAPI.dart';
import 'config.dart';

class SwipeTest extends StatefulWidget {
  final int initialPage;
  // final String hostUrl;
  const SwipeTest({
    super.key,
    required this.initialPage,
    // required this.hostUrl
  });
  @override
  _SwipeTestState createState() => _SwipeTestState(
        initialPage: initialPage,
        //  hostUrl: hostUrl
      );
}

class _SwipeTestState extends State<SwipeTest> {
  final int initialPage;
  // final String hostUrl;
  _SwipeTestState({
    required this.initialPage,
    // required this.hostUrl
  });

  late PageController controller;
  late String wavUrl;
  // String testDateTime = "";

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: initialPage);

    // testDateTime = "testDate";

    DateTime now = DateTime.now();

    PathModel pathModel = Provider.of<PathModel>(context, listen: false);
    String testDateTime = pathModel.setTestDateTime();
    print("m: testDateTime = $testDateTime");
  }

  @override
  Widget build(BuildContext context) {
    //產生編號1~6的題目頁面
    // final List<RecorderPage> task1_list = List<RecorderPage>.generate(6, (i) => RecorderPage(index: i+1));

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

  //儲存測驗日期時間
  // Future<void> saveLastTest() async {
  //     try{
  //     final file = File("$appDocPath/last_test.txt");
  //     file.writeAsString(str);
  //     print("m: 成功寫入 $pathToText");
  //   } catch (e) {
  //     print("m: $e");
  //   }
  // }
}
