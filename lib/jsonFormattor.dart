import 'package:flutter/material.dart';
import 'dart:convert';

RichText formatColoredJson(String jsonString) {
  final jsonMap = jsonDecode(jsonString);
  List<TextSpan> textSpans = [];

  jsonMap.forEach((key, value) {
    textSpans.add(
      TextSpan(
        text: '"$key": ', // JSON Key
        style: TextStyle(color: Colors.lightBlueAccent), // Key color
      ),
    );

    textSpans.add(
      TextSpan(
        text: value is String ? '"$value"' : value.toString(), // JSON Value
        style: TextStyle(color: Colors.black87), // Value color
      ),
    );

    textSpans.add(
      TextSpan(text: ',\n'), // Add a comma and new line after each key-value pair
    );
  });

  return RichText(
    text: TextSpan(children: textSpans, style: TextStyle(fontSize: 16.0)),
  );
}
