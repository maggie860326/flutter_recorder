// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'function.dart';

class ReportPage extends StatefulWidget {
  final String hostUrl;
  const ReportPage({super.key, required this.hostUrl});

  @override
  _ReportPageState createState() => _ReportPageState(hostUrl: hostUrl);
}

class _ReportPageState extends State<ReportPage> {
  final String hostUrl;
  _ReportPageState({required this.hostUrl});

  String output = 'Output will appear here';

  @override
  Widget build(BuildContext context) {
    final String pngUrl = '$hostUrl/api_test/getPng';

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 100,
            ),
            ElevatedButton(
              child: const Text("查看測驗報告"),
              onPressed: () {
                getPng(pngUrl);
              },
            ),
            const SizedBox(
              height: 100,
            ),
            Text(output),
          ],
        ),
      ),
    );
  }

  void getPng(String pngUrl) async {
    try {
      // 請求 PNG
      String pngBase64 = await sendPngRequestToServer(pngUrl);

      String base64String = json.decode(pngBase64)['png_data'];
      // Base64 code -> image
      List<int>? pngBytes = base64.decode(base64String).cast<int>();

      if (pngBytes != Null) {
        Image image = Image.memory(Uint8List.fromList(pngBytes));

        // 顯示圖片
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Container(
                child: image,
              ),
            );
          },
        );
      } else {
        setState(() {
          output = 'Base64 解碼失敗';
        });
      }
    } catch (error) {
      print(error.toString());
      setState(() {
        output = 'Error: $error';
      });
    }
  }
}

//取得 app 專屬資料夾路徑
Future<String> get _appDocPath async {
  final directory = await getApplicationDocumentsDirectory();
  // print(directory.path);
  return directory.path;
}
