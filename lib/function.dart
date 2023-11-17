import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// 傳送JSON
Future<String> sendJsonDataToServer(
    String url, Map<String, dynamic> jsonData) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'charset': 'UTF-8'},
      body: json.encode(jsonData),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData.toString();
      //return responseData;
    } else {
      return 'Failed to send data to the server';
    }
  } catch (error) {
    return 'Error: $error';
  }
}

// 傳送 WAV
Future<String> sendWavFileToServer(String url, File wavFile) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    var multipartFile =
        await http.MultipartFile.fromPath('wav_file', wavFile.path);

    request.files.add(multipartFile);

    var response = await request.send();

    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return responseData.toString();
    } else {
      return 'Failed to send WAV file to the server: $responseData';
    }
  } catch (error) {
    return 'Error: $error';
  }
}

// 取得雷達圖
Future<String> sendPngRequestToServer(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // 返回 PNG 文件的 Base64 编码
      return response.body;
    } else {
      return 'Failed to fetch PNG from the server';
    }
  } catch (error) {
    return 'Error: $error';
  }
}
