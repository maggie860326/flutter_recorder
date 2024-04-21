/*
View: 以列表顯示手機本地端有儲存的測驗報告
 */
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
              //向左滑動即可刪除或重新命名檔案
              return Slidable(
                key: ValueKey("$index"),
                direction: Axis.horizontal,
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
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
                //測驗報告列表
                child: ListTile(
                    title: Text(
                        "${basenameWithoutExtension(fileList[index].path)} 的測驗報告"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Provider<PathModel>(
                              create: (ctx) => PathModel(),
                              child: RadarChartPageNoProvider(
                                  fileList[index].path),
                            ),
                          ));
                    }),
              );
            }));
  }

/* 本頁面會用到的 function */

//取得 result 資料夾下的所有檔案
  Future<List> getFileList() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/test/result';
    print("m: 遍歷路徑 $path");
    setState(() {
      fileList = Directory(path).listSync();
    });
    return fileList;
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
