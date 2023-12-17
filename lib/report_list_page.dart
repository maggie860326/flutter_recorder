// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ReportListPage extends StatefulWidget {
  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  final items = List<String>.generate(20, (i) => "Item ${i + 1}");
  List fileList = [];

  @override
  void initState() {
    super.initState();
    getFileList();
  }

  void getFileList() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/test1/recording';
    print("m: 遍歷路徑 $path");
    setState(() {
      fileList = Directory(path).listSync();
    });
  }

  void doNothing(BuildContext context) {
    return;
  }

  void deleteFile(file)

  @override
  Widget build(BuildContext context) {
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
                      onPressed: doNothing,
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: '刪除',
                    ),
                    //重新命名
                    SlidableAction(
                      onPressed: doNothing,
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.drive_file_rename_outline,
                      label: '重新命名',
                    ),
                  ],
                ),
                child: ListTile(title: Text(basename(fileList[index].path))),
              );
            }));
  }
}
