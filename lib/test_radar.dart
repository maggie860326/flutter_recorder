import 'package:flutter/material.dart';
// import 'dart:io';
import 'package:path/path.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'model.dart';
import "function.dart";

class ReportChartPage extends StatelessWidget {
  ReportChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _json = {
      "norm_and_data_dic": {
        "CD": {"data": 0.4046, "norm": 0.4},
        "CW": {"data": 140.0, "norm": 284.67},
        "CWF": {"data": 694.9653, "norm": 751.08},
        "FR": {"data": 0.0106, "norm": 0.032},
        "LPR": {"data": 0.0, "norm": 0.004},
        "MLS": {"data": 16.9333, "norm": 16.17},
        "MLU": {"data": 7.2571, "norm": 7.97},
        "NS": {"data": 30.0, "norm": 65.67},
        "NU": {"data": 70.0, "norm": 144.17},
        "PaR": {"data": 0.0, "norm": 0.017},
        "PrR": {"data": 0.0328, "norm": 0.072},
        "TTR": {"data": 0.5029, "norm": 0.37},
        "TW": {"data": 346.0, "norm": 730.17},
        "UW": {"data": 174.0, "norm": 256.83},
        "VR": {"data": 0.0723, "norm": 0.253}
      },
      "normal_status_dic": {
        "CD": "normal",
        "CW": "normal",
        "CWF": "normal",
        "FR": "abnormal",
        "LPR": "normal",
        "MLS": "normal",
        "MLU": "normal",
        "NS": "normal",
        "NU": "normal",
        "PaR": "normal",
        "PrR": "abnormal",
        "TTR": "abnormal",
        "TW": "normal",
        "UW": "normal",
        "VR": "abnormal"
      },
      "status": "completed"
    };

    final List<String> titles = getFeatureList(_json);

    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            // "${basename(pathToReport)} 的測驗報告",
            "測驗報告",
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          SizedBox(
            height: 40,
          ),
          AspectRatio(
              aspectRatio: 1.3,
              child: RadarChart(
                RadarChartData(
                  dataSets: showingDataSets(_json),
                  tickCount: 3,
                  ticksTextStyle:
                      const TextStyle(color: Colors.transparent, fontSize: 10),
                  tickBorderData: const BorderSide(color: Colors.transparent),
                  // gridBorderData:
                  // BorderSide(color: Color.fromARGB(0, 255, 0, 0), width: 4),
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

/* functions */
  List<String> getFeatureList(Map<String, dynamic> _json) {
    List<String> keyList = _json['norm_and_data_dic'].keys.toList();
    print("m: $keyList");
    return keyList;
  }

  List<RadarDataSet> showingDataSets(Map<String, dynamic> _json) {
    return getRawDataSets(_json).asMap().entries.map((entry) {
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

  List<RawDataSet> getRawDataSets(Map<String, dynamic> _json) {
    return [
      // RawDataSet(
      //   title: '測試一',
      //   color: Colors.yellow,
      //   values: [
      //     300,
      //     400,
      //     250,
      //   ],
      // ),
      // RawDataSet(
      //   title: '測試二',
      //   color: Colors.purple,
      //   values: [
      //     250,
      //     100,
      //     100,
      //   ],
      // ),
      RawDataSet.fromJson(_json, "data"),
      RawDataSet.fromJson(_json, "norm")
    ];
  }
}

class RawDataSet {
  String? title;
  Color color = Colors.black;
  List<double> values = [];

  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });

  RawDataSet.fromJson(Map<String, dynamic> _json, String data) {
    title = (data == "norm") ? "平均值" : "我的分數";
    color = (data == "norm") ? Colors.blue : Colors.orange;

    _json["norm_and_data_dic"].forEach((k, v) {
      values.add(v[data]);
    });
    print("m: $title : $values");
  }
}
