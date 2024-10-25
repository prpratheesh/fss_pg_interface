import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  Future<http.Response> sendPostRequest(String url, String payload) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // Specify the content type
        },
        body: payload, // Send the raw JSON string as the body
      );
      return response;
    } catch (e) {
      throw Exception('Error sending request: $e');
    }
  }
}