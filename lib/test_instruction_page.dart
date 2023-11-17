import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestInstructionPage extends StatelessWidget {
  const TestInstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            height: 100,
            child: const Text(
              "在接下來的測驗中，你會看到一組問題，請您看完問題後，按下錄音按鈕並開始回答。",
              style: TextStyle(fontSize: 20, color: Colors.black),
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
