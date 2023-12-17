import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportChartPage extends StatelessWidget {
  final String pathToReport;
  const ReportChartPage({super.key, required this.pathToReport});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            "${basename(pathToReport)} 的測驗報告",
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ]));
  }
}
