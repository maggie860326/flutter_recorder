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
    PathModel pathModel = Provider.of<PathModel>(context, listen: false);
    Future<String> pathToReport = pathModel.pathToReport(0);

    return Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
            future: readJson(pathToReport),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // 请求已结束
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  // 请求失败，显示错误
                  return Text("Error: ${snapshot.error}");
                } else {
                  // 请求成功，显示数据
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          // "${basename(pathToReport)} 的測驗報告",
                          "測驗報告",
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        AspectRatio(
                            aspectRatio: 1.3,
                            child: RadarChart(
                              RadarChartData(
                                dataSets: showingDataSets(snapshot.data),
                                tickCount: 3,
                                ticksTextStyle: const TextStyle(
                                    color: Colors.transparent, fontSize: 10),
                                tickBorderData:
                                    const BorderSide(color: Colors.transparent),
                                // gridBorderData:
                                // BorderSide(color: Color.fromARGB(0, 255, 0, 0), width: 4),
                                radarBackgroundColor: Colors.transparent,
                                borderData: FlBorderData(show: false),
                                radarBorderData:
                                    const BorderSide(color: Colors.transparent),
                                titlePositionPercentageOffset: 0.2,
                                titleTextStyle: TextStyle(
                                    color: Colors.black, fontSize: 14),
                                getTitle: (index, angle) {
                                  final List<String> titles =
                                      getFeatureList(snapshot.data);

                                  return RadarChartTitle(
                                    text: titles[index],
                                  );
                                },
                              ),
                              swapAnimationDuration:
                                  Duration(milliseconds: 150), // Optional
                              swapAnimationCurve: Curves.linear, // Optional
                            ))
                      ]);
                }
              } else {
                // 请求未结束，显示loading
                return CircularProgressIndicator();
              }
            }));
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
