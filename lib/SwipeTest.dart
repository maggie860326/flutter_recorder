import 'package:flutter/material.dart';
import 'RecorderPage.dart';

class SwipeTest extends StatefulWidget {
  @override
  _SwipeTestState createState() => _SwipeTestState();
}

class _SwipeTestState extends State<SwipeTest> {
  final controller = PageController(initialPage: 0);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("測驗內容"), actions: [
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
        body: PageView(
          scrollDirection: Axis.horizontal,
          // physics: ,
          controller: controller,
          onPageChanged: (index) {
            // print("Page ${index}");
          },
          children: <Widget>[
            const RecorderPage(title: "錄音頁面"),
            Container(
              color: Colors.red,
              child: const Center(child: Text("Page 0")),
            ),
            Container(
              color: Colors.indigo,
              child: const Center(child: Text("Page 1")),
            ),
            Container(
              color: Colors.green,
              child: const Center(child: Text("Page 2")),
            ),
          ],
        ),
      );
}
