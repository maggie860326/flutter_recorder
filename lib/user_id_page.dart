import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recorder/model.dart';

class UserIDPage extends StatelessWidget {
  final TextEditingController myController = TextEditingController();

  UserIDPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(children: [
        TextFormField(
          controller: myController,
          decoration: const InputDecoration(
            labelText: '請輸入使用者 ID',
            labelStyle: TextStyle(fontSize: 20),
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
            errorText: "不可空白",
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Provider.of<PathModel>(context, listen: false)
                .setUserID(myController.text);
            Provider.of<PageController>(context, listen: false).nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
          },
          child: const Text(
            "確認送出",
            style: TextStyle(
              fontSize: 28,
            ),
          ),
        ),
      ]),
    );
  }
}
