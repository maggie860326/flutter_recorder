/*
View: 測驗指導語頁面
安插在每一大題開始之前
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestInstructionPage extends StatelessWidget {
  final String instruction;
  const TestInstructionPage({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    //取得 PageView 控制
    PageController controller = Provider.of<PageController>(context);

    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 100,
          ),
          const Text(
            "測驗介紹",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50.0),
            height: 150,
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
            child: const Text("開始測驗"),
            onPressed: () {
              controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            },
          ),
        ],
      ),
    );
  }
}
