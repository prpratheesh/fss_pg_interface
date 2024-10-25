import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_picker/file_picker.dart';


Future<void> exportLogs(messages) async {
  String statusText = messages.join('\n');
  String timeStamp = DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());
  String fileName =
      'PG_APP_LOG_$timeStamp.txt'; // Adjust file name format as needed
  fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
  // print(fileName);
  // Prompt the user to choose the directory and file name
  final result = await await FilePicker.platform.saveFile(
    dialogTitle: 'SELECT FOLDER TO SAVE THE LOG:',
    fileName: fileName,
  );
  if (result != null) {
    // Write the status messages to the chosen file
    final file = File(result);
    await file.writeAsString(statusText);
    print('Status messages saved to ${file.path}');
  } else {
    print('No file selected.');
  }
}