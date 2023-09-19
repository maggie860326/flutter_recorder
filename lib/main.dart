// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'RecorderPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Change Page',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('換頁Demo'),
          ),
          body: _FirstPage(),
        ),
        routes: <String, WidgetBuilder>{
          '/RecorderPage': (_) => const RecorderPage(
                title: "錄音頁面",
              )
        });
  }
}

class _FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    debugPrint('Card tapped.');
                    Navigator.pushNamed(context, "/RecorderPage");
                  },
                  child: const SizedBox(
                    width: 300,
                    height: 100,
                    child: Center(child: Text("繼續上次的測驗")),
                  ),
                ),
              ),
              Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    debugPrint('Card tapped.');
                    Navigator.pushNamed(context, "/RecorderPage");
                  },
                  child: const SizedBox(
                    width: 300,
                    height: 100,
                    child: Center(child: Text("開始新的測驗")),
                  ),
                ),
              ),
              Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    debugPrint('Card tapped.');
                    Navigator.pushNamed(context, "/RecorderPage");
                  },
                  child: const SizedBox(
                    width: 300,
                    height: 100,
                    child: Center(child: Text("查看測驗報告")),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
