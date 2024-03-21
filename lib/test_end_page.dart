// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:recorder/model.dart';
import 'package:recorder/view_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'function.dart';
import 'config.dart';

class TestEndPage extends StatelessWidget {
  const TestEndPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List<Question> questionList = task_1_Q + task_2_Q;

    PathModel pathModel = Provider.of<PathModel>(context, listen: false);

    WhisperViewModel whisperVM =
        Provider.of<WhisperViewModel>(context, listen: false);

    whisperVM.checkTextSaved(pathModel); //檢查已存成文字檔的文件

    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 100,
          ),
          const Text(
            "您已完成測驗",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50.0),
            height: 120,
            child: const Text(
              "系統正在處理您的錄音檔，此過程需要一段時間，下方可查看各題處理進度。",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Consumer<WhisperViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  children: [
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: questionList.length,
                        itemBuilder: (context, index) {
                          return Text(
                            "${questionList[index].task_name}${questionList[index].questionNo}: ${viewModel.states[index]}",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          );
                        }),
                    const SizedBox(
                      height: 40,
                    ),
                    Offstage(
                      offstage:
                          !whisperVM.ifAllDoneThenSendTextToServer(pathModel),
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<PageController>(context, listen: false)
                              .nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                        },
                        child: const Text(
                          "查看結果",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
