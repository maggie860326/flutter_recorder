import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'function.dart';
import 'model.dart';

class testAPI extends StatelessWidget {
  const testAPI({super.key});

  @override
  Widget build(BuildContext context) {
    PathModel pathModel = Provider.of<PathModel>(context, listen: false);

    return Scaffold(
      body: Column(
        children: <Widget>[
          ElevatedButton(
            child: Text("傳送wav"),
            onPressed: () {
              submitWav(pathModel);
            },
          ),
          ElevatedButton(
            child: Text("傳送json並取得結果"),
            onPressed: () {
              submitText(pathModel, 1);
            },
          ),
        ],
      ),
    );
  }
}
