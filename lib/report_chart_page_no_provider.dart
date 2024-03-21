import 'dart:io';

import 'package:flutter/material.dart';
// import 'dart:io';
import 'package:path/path.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'model.dart';
import "function.dart";

class RadarChartSample1 extends StatefulWidget {
  RadarChartSample1({super.key});

  @override
  State<RadarChartSample1> createState() => _RadarChartSample1State();
}

class _RadarChartSample1State extends State<RadarChartSample1> {
  int selectedDataSetIndex = -1;
  double angleValue = 0;
  bool relativeAngleMode = true;
  List ranges = [
    (433, 1314),
    (180, 467),
    (0.29, 0.46),
    (175, 518),
    (482.46, 880.0),
    (75, 258),
    (42, 137),
    (4.83, 10),
    (12.91, 21.91),
    (0.011, 0.062),
    (0.001, 0.009),
    (0.35, 0.45),
    (0, 0.065),
    (0.223, 0.298),
    (0.044, 0.099)
  ];

  late Future<String> pathToReport;

  @override
  void initState() {
    pathToReport = getPathToReport();
    super.initState();

    print("m: initialized.\n");
  }

  @override
  Widget build(BuildContext context) {
    // PathModel pathModel = Provider.of<PathModel>(context, listen: false);
    // Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // String pathToReport = '${documentsDirectory.path}/test/result';
    // Future<String> pathToReport = pathModel.pathToReport(0);

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
                  List<String> keyList =
                      snapshot.data['normal_status_dic'].keys.toList();

                  final List<String> titles = getFeatureList(snapshot.data);
                  // 请求成功，显示数据
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDataSetIndex = -1;
                              });
                            },
                            child: const Text(
                              '測驗報告',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            )),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: getRawDataSets(snapshot.data)
                              .asMap()
                              .map((index, value) {
                                final isSelected =
                                    index == selectedDataSetIndex;
                                return MapEntry(
                                  index,
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedDataSetIndex = index;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.yellow
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(46),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 6,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.easeInToLinear,
                                            padding: EdgeInsets.all(
                                                isSelected ? 8 : 6),
                                            decoration: BoxDecoration(
                                              color: value.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInToLinear,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isSelected
                                                  ? value.color
                                                  : Colors.black45,
                                            ),
                                            child: Text(value.title!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .values
                              .toList(),
                        ),
                        const SizedBox(height: 40),
                        AspectRatio(
                            aspectRatio: 1.3,
                            child: RadarChart(
                              RadarChartData(
                                radarTouchData: RadarTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, response) {
                                    if (!event.isInterestedForInteractions) {
                                      setState(() {
                                        selectedDataSetIndex = -1;
                                      });
                                      return;
                                    }
                                    setState(() {
                                      selectedDataSetIndex = response
                                              ?.touchedSpot
                                              ?.touchedDataSetIndex ??
                                          -1;
                                    });
                                  },
                                ),
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
                                  return RadarChartTitle(
                                    text: titles[index],
                                  );
                                },
                              ),
                              swapAnimationDuration:
                                  const Duration(milliseconds: 2000),
                              swapAnimationCurve: Curves.linear,
                            )),
                        Container(
                          height: 200,
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount:
                                  snapshot.data["normal_status_dic"].length,
                              itemBuilder: (context, index) {
                                String key = keyList[index];
                                return Text(
                                  "${key} : ${snapshot.data["normal_status_dic"][key]}",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                );
                              }),
                        ),
                      ]);
                }
              } else {
                // 请求未结束，显示loading
                return const CircularProgressIndicator();
              }
            }));
  }

  Future<String> getPathToReport() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return '${documentsDirectory.path}/test/result';
  }

/* functions */
  List<String> getFeatureList(Map<String, dynamic> _json) {
    List<String> keyList = _json['norm_and_data_dic'].keys.toList();
    print("m: $keyList");
    return keyList;
  }

  List<RadarDataSet> showingDataSets(Map<String, dynamic> _json) {
    return getRawDataSets(_json).asMap().entries.map((entry) {
      final index = entry.key;
      final rawDataSet = entry.value;

      final isSelected = index == selectedDataSetIndex
          ? true
          : selectedDataSetIndex == -1
              ? true
              : false;

      return RadarDataSet(
        fillColor: isSelected
            ? rawDataSet.color.withOpacity(0.2)
            : rawDataSet.color.withOpacity(0.05),
        borderColor:
            isSelected ? rawDataSet.color : rawDataSet.color.withOpacity(0.25),
        entryRadius: isSelected ? 3 : 2,
        dataEntries:
            rawDataSet.values.map((e) => RadarEntry(value: e)).toList(),
        borderWidth: isSelected ? 2.3 : 2,
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
