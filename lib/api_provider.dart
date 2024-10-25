import 'dart:convert';
import 'package:dio/dio.dart';

class DioService {
  final Dio _dio;

  DioService() : _dio = Dio();

  Future<Response> sendPostRequest(String url, String payload) async {
    try {
      Response response = await _dio.post(
        url,
        data: jsonEncode(payload), // Encode the data to JSON
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Specify the content type
          },
        ),
      );
      return response;
    } catch (e) {
      // Handle errors
      throw Exception('Error sending request: $e');
    }
  }
}
