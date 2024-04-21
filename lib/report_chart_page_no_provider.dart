/*
View: 繪製雷達圖的頁面(不使用 provider)
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import "function.dart";

class RadarChartPageNoProvider extends StatefulWidget {
  final String pathToReport;
  const RadarChartPageNoProvider(this.pathToReport);

  @override
  State<RadarChartPageNoProvider> createState() =>
      _RadarChartPageNoProviderState(pathToReport);
}

class _RadarChartPageNoProviderState extends State<RadarChartPageNoProvider> {
  final String pathToReport;
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

  _RadarChartPageNoProviderState(this.pathToReport);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("測驗報告")),
        body: FutureBuilder<Map<String, dynamic>>(
            future: readJson(Future.value(pathToReport)),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // 请求已结束
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  // 请求失败，显示错误
                  return Text("Error: ${snapshot.error}");
                } else {
                  final List<String> keyList =
                      snapshot.data['normal_status_dic'].keys.toList();

                  final List<String> titles = getFeatureList(snapshot.data);
                  //! 请求成功，显示数据
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDataSetIndex = -1;
                              });
                            },
                            child: Text(
                              "${basenameWithoutExtension(pathToReport)}",
                              style: const TextStyle(
                                fontSize: 25,
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
                        //! 雷達圖
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
                                titleTextStyle: const TextStyle(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: SizedBox(
                            height: 200,
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount:
                                    snapshot.data["normal_status_dic"].length,
                                itemBuilder: (context, index) {
                                  String key = keyList[index];
                                  return Text(
                                    "$key : ${snapshot.data["normal_status_dic"][key]}",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  );
                                }),
                          ),
                        )
                      ]);
                }
              } else {
                // 请求未结束，显示loading
                return const CircularProgressIndicator();
              }
            }));
  }

/* functions */
  Future<String> getPathToReport() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return '${documentsDirectory.path}/test/result';
  }

//取得15個語言特徵的名稱 list
  List<String> getFeatureList(Map<String, dynamic> json) {
    List<String> keyList = json['norm_and_data_dic'].keys.toList();
    print("m: $keyList");
    return keyList;
  }

  //從 json 取得資料，並分成使用者和常模的分數
  List<RawDataSet> getRawDataSets(Map<String, dynamic> json) {
    return [
      RawDataSet.fromJson(json, "data"), //使用者的分數
      RawDataSet.fromJson(json, "norm") //常模的平均分數
    ];
  }

//對
  List<RadarDataSet> showingDataSets(Map<String, dynamic> json) {
    return getRawDataSets(json).asMap().entries.map((entry) {
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
}

//定義雷達圖要使用的資料格式
class RawDataSet {
  String? title;
  Color color = Colors.black;
  List<double> values = [];

  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });

  //從 json import 資料的建構式
  RawDataSet.fromJson(Map<String, dynamic> json, String data) {
    title = (data == "norm") ? "平均值" : "我的分數";
    color = (data == "norm") ? Colors.blue : Colors.orange;

    json["norm_and_data_dic"].forEach((k, v) {
      values.add(v[data]);
    });
    print("m: $title : $values");
  }
}
