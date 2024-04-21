// ignore_for_file: avoid_print

/*
View: 顯示各題錄音檔轉錄為文字的進度
當全部轉錄完成時，自動將文字檔傳送到後端->請求語言特徵分數->跳轉到報告頁面
*/

import 'package:flutter/material.dart';
import 'package:recorder/function.dart';
import 'package:recorder/model.dart';
import 'package:recorder/view_model.dart';
import 'package:provider/provider.dart';
import 'config.dart';

class TestEndPage extends StatelessWidget {
  const TestEndPage({super.key});

  @override
  Widget build(BuildContext context) {
    PathModel pathModel = Provider.of<PathModel>(context, listen: false);
    PageController controller =
        Provider.of<PageController>(context, listen: false);

    WhisperViewModel whisperVM =
        Provider.of<WhisperViewModel>(context, listen: false);

    //檢查有沒有已存成文字檔的文件，function 內容定義在 view_model.dart 的 WhisperViewModel
    whisperVM.checkTextSaved(pathModel);
    SubmitState submitState = SubmitState.idle;

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
                if (submitState == SubmitState.idle) {
                  //檢查音檔轉錄為文字的進度，function 內容定義在 view_model.dart 的 WhisperViewModel
                  whisperVM
                      .ifAllDoneThenSendTextToServer(pathModel, controller)
                      .then((value) {
                    submitState = value;
                    print("m: page state= $submitState");
                  });
                }
                return Column(
                  children: [
                    //用 ListView 顯示每一題的轉錄狀態
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: questionList.length,
                        itemBuilder: (context, index) {
                          return Text(
                            "${questionList[index].task_name}${questionList[index].questionNo}: ${viewModel.states[index]}",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          );
                        }),
                    const SizedBox(
                      height: 40,
                    ),
                    //如果有音檔轉錄出來是空字串，則顯示下列警告
                    Offstage(
                        offstage: submitState != SubmitState.stringIsBlank,
                        child: const Text("錄音內容不可為空，請重新作答。",
                            style: TextStyle(fontSize: 25, color: Colors.red)))
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
