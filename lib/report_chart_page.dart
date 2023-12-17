import 'package:flutter/material.dart';
// import 'dart:io';
import 'package:path/path.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportChartPage extends StatelessWidget {
  final String pathToReport;
  ReportChartPage({super.key, required this.pathToReport});
  final List<String> titles = ["Mobile or Tablet", 'Desktop', 'TV'];

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
          SizedBox(
            height: 40,
          ),
          AspectRatio(
              aspectRatio: 1.3,
              child: RadarChart(
                RadarChartData(
                  dataSets: showingDataSets(),
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  titlePositionPercentageOffset: 0.2,
                  titleTextStyle: TextStyle(color: Colors.black, fontSize: 14),
                  getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: titles[index],
                    );
                  },
                ),
                swapAnimationDuration: Duration(milliseconds: 150), // Optional
                swapAnimationCurve: Curves.linear, // Optional
              ))
        ]));
  }

  List<RadarDataSet> showingDataSets() {
    return rawDataSets().asMap().entries.map((entry) {
      final rawDataSet = entry.value;

      return RadarDataSet(
        fillColor: rawDataSet.color.withOpacity(0.1),
        borderColor: rawDataSet.color,
        entryRadius: 3,
        dataEntries:
            rawDataSet.values.map((e) => RadarEntry(value: e)).toList(),
        borderWidth: 2.3,
      );
    }).toList();
  }

  List<RawDataSet> rawDataSets() {
    return [
      RawDataSet(
        title: '我的分數',
        color: Colors.green,
        values: [
          300,
          400,
          250,
        ],
      ),
      RawDataSet(
        title: '平均值',
        color: Colors.red,
        values: [
          250,
          100,
          100,
        ],
      ),
      // RawDataSet(
      //   title: 'Entertainment',
      //   color: Colors.blue,
      //   values: [
      //     200,
      //     150,
      //     50,
      //   ],
      // ),
      // RawDataSet(
      //   title: 'Off-road Vehicle',
      //   color: Colors.yellow,
      //   values: [
      //     150,
      //     200,
      //     150,
      //   ],
      // ),
      // RawDataSet(
      //   title: 'Boxing',
      //   color: Colors.black45,
      //   values: [
      //     100,
      //     250,
      //     100,
      //   ],
      // ),
    ];
  }
}

class RawDataSet {
  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });

  final String title;
  final Color color;
  final List<double> values;
}
