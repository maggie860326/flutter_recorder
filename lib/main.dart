// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:io';
import 'swipe_test.dart';
// import 'report_page.dart';
import 'report_list_page.dart';

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
      // //todo: 註冊頁面
      // routes: <String, WidgetBuilder>{
      // '/SwipeTest': (_) => SwipeTest(initialPage: 0,),
      // }
    );
  }
}

class _FirstPage extends StatelessWidget {
  //後端的路由
  final String hostUrl = 'http://10.0.2.2:5000/';

  @override
  Widget build(BuildContext context) {
    print("m: 這支手機的 Processors 數量為  ${Platform.numberOfProcessors}");
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              Card(
                // 繼續上次測驗卡片
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SwipeTest(
                            initialPage: 3,
                            hostUrl: hostUrl,
                          ),
                        ));
                  },
                  child: const SizedBox(
                    width: 300,
                    height: 100,
                    child: Center(child: Text("繼續上次的測驗")),
                  ),
                ),
              ),
              Card(
                //開始新測驗卡片
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SwipeTest(
                            initialPage: 0,
                            hostUrl: hostUrl,
                          ),
                        ));
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportListPage(
                              // hostUrl: hostUrl,
                              ),
                        ));
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
