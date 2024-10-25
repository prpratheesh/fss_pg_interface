import 'dart:html' as html;
import 'package:intl/intl.dart';

void exportLogs(messages) {
  String statusText = messages.join('\n');
  String timeStamp = DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());
  String fileName =
      'PG_APP_LOG_$timeStamp.txt'; // Adjust file name format as needed
  String logData = messages.join('\n'); // Join log messages with line breaks
  final blob = html.Blob([logData], 'text/plain');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
