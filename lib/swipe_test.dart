/*
View: 包含整個測驗流程的 PageView
每一頁會顯示一個題目或是指導語
如果要修改頁面的編排，請到 config.dart 修改 List<Widget> pages
*/

import 'package:flutter/material.dart';
import 'package:recorder/model.dart';
import 'package:provider/provider.dart';
import 'config.dart';

class SwipeTest extends StatefulWidget {
  final int initialPage;
  const SwipeTest({
    super.key,
    required this.initialPage,
  });
  @override
  _SwipeTestState createState() => _SwipeTestState(
        initialPage: initialPage,
      );
}

class _SwipeTestState extends State<SwipeTest> {
  final int initialPage;
  _SwipeTestState({
    required this.initialPage,
  });

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

    PathModel pathModel = Provider.of<PathModel>(context, listen: false);
    String testDateTime = pathModel.setTestDateTime();
    print("m: testDateTime = $testDateTime");
  }

  @override
  Widget build(BuildContext context) {
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
        onPageChanged: (index) {},
      ),
    );
  }
}
