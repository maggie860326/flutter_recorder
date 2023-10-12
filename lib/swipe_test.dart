// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'recorder_page.dart';
import 'test_instruction_page.dart';

class SwipeTest extends StatefulWidget {
  final int initialPage;
  const SwipeTest({super.key, required this.initialPage});
  @override
  _SwipeTestState createState() => _SwipeTestState(initialPage: initialPage);
}

class _SwipeTestState extends State<SwipeTest> {
  final int initialPage;
  _SwipeTestState({required this.initialPage});

  late PageController controller;
  // late int pageIndex;

  final List<Widget> pages = [
    TestInstructionPage(),
    const RecorderPage(index: 0),
    const RecorderPage(index: 1),
    const RecorderPage(index: 2),
    const RecorderPage(index: 3),
    const RecorderPage(index: 4),
    const RecorderPage(index: 5),
    TestInstructionPage(),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //创建控制器的实例
    controller = PageController(initialPage: initialPage);
    // pageIndex = initialPage;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            return pages[index];
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
