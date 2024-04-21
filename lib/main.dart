/*
View: app 主頁面
注入 provider ，使底下的 Widgets 都能使用 PathModel 和 WhisperViewModel
*/


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'swipe_test.dart';
import 'report_list_page.dart';
import 'model.dart';
import 'view_model.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
    );
  }
}

class _FirstPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print("m: 這支手機的 Processors 數量為  ${Platform.numberOfProcessors}");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              Card(
                //! 繼續上次測驗卡片
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => 
                          //! 注入 Provider
                          MultiProvider(
                            providers: [
                              ChangeNotifierProvider<WhisperViewModel>(
                                create: (ctx) => WhisperViewModel(),
                              ),
                              Provider<PathModel>(
                                create: (ctx) => PathModel(),
                              )
                            ],
                            child: const SwipeTest(
                              initialPage: 0,
                            ),
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
                //! 開始新測驗卡片
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => 
                          //! 注入 Provider
                          MultiProvider(
                            providers: [
                              ChangeNotifierProvider<WhisperViewModel>(
                                create: (ctx) => WhisperViewModel(),
                              ),
                              Provider<PathModel>(
                                create: (ctx) => PathModel(),
                              )
                            ],
                            child: const SwipeTest(
                              initialPage: 0,
                            ),
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
                //! 查看測驗報告頁面
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => 
                          //! 注入 Provider
                          MultiProvider(
                            providers: [
                              ChangeNotifierProvider<WhisperViewModel>(
                                create: (ctx) => WhisperViewModel(),
                              ),
                              Provider<PathModel>(
                                create: (ctx) => PathModel(),
                              )
                            ],
                            child: const ReportListPage(
                                ),
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
