// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'model.dart';
import "report_chart_page_no_provider.dart";

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  // final items = List<String>.generate(20, (i) => "Item ${i + 1}");
  List<FileSystemEntity> fileList = [];

  @override
  void initState() {
    getFileList();
    super.initState();

    print("m: initialized.\n");
  }

  @override
  Widget build(BuildContext context) {
    // PathModel pathModel = Provider.of<PathModel>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: const Text('報告列表'),
        ),
        body: ListView.builder(
            itemCount: fileList.length,
            itemBuilder: (context, index) {
              return Slidable(
                key: ValueKey("$index"),
                direction: Axis.horizontal,
                // The end action pane is the one at the right or the bottom side.
                endActionPane: ActionPane(
                  // A motion is a widget used to control how the pane animates.
                  motion: const DrawerMotion(),
                  // All actions are defined in the children parameter.
                  children: [
                    //刪除
                    SlidableAction(
                      onPressed: (BuildContext context) {
                        // doNothing();
                        deleteFile(fileList[index]);
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: '刪除',
                    ),
                    //重新命名
                    SlidableAction(
                      onPressed: (BuildContext context) {
                        renameFile(context, fileList[index]);
                      },
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.drive_file_rename_outline,
                      label: '重新命名',
                    ),
                  ],
                ),
                child: ListTile(
                    title: Text(basename(fileList[index].path)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Provider<PathModel>(
                              create: (ctx) => PathModel(),
                              child: RadarChartSample1(),
                            ),
                          ));
                    }),
              );
            }));
  }

/* 本頁面會用到的 function */
  getFileList() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/test/result';
    print("m: 遍歷路徑 $path");
    setState(() {
      fileList = Directory(path).listSync();
      print("m: ${fileList.length}");
    });
  }

  void doNothing() {
    print("m: donothing");
    // return ;
  }

  void deleteFile(file) {
    try {
      file.delete();
      getFileList();
      print("m: 已刪除 ${file.path}");
    } catch (e) {
      print("m: 無法刪除 ${file.path}");
    }
  }

  renameFile(BuildContext context, file) {
    String newPath = basename(file.path);

    showDialog<String>(
        context: context,
        barrierDismissible: true, //控制點擊對話框以外的區域是否隱藏對話框
        builder: (BuildContext context) {
          TextEditingController controller = TextEditingController();
          controller.text = newPath;
          controller.selection = TextSelection(
              baseOffset: 0, extentOffset: controller.text.length - 4);
          return AlertDialog(
            // title: Text('帶輸入框訊息視窗'),
            content: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  autofocus: true,
                  controller: controller,
                  decoration: const InputDecoration(labelText: '重新命名'),
                  onChanged: (newFileName) {
                    var path = file.path;
                    var lastSeparator =
                        path.lastIndexOf(Platform.pathSeparator);
                    newPath =
                        path.substring(0, lastSeparator + 1) + newFileName;
                  },
                ))
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('確認'),
                onPressed: () {
                  Navigator.of(context).pop();
                  try {
                    file.rename(newPath);
                    getFileList();
                  } catch (e) {
                    print("m: 無法重新命名 ${file.path}");
                  }
                },
              ),
              ElevatedButton(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
