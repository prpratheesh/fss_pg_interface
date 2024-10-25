import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'api_provider.dart';
import 'api_provider_http.dart';
import 'font_sizes.dart';
import 'jsonFormattor.dart';
import 'logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:colored_json/colored_json.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart'; // or any other theme
import 'dart:convert';
import 'export_logs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'aes.dart'; // Import the AESHelper class
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class TransactionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _jsonController = TextEditingController();
  String _tranType = 'PURCHASE';
  String _pgTranMode = 'HOSTED';
  bool envStatus = false;
  String textData = '';
  late AnimationController animationController;
  List<String> statusMessages = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int _seconds = 0;
  String platformInfo = '';
  var envData = '';
  Map<String, dynamic> envMap = {};
  final Map<String, String> formData = {
    'amt': '65.00',
    'action': '1',
    'trackId': 'RnxkiOvuj4VWjDykkC',
    'udf1': 'test udf1',
    'udf2': 'test udf2',
    'udf3': 'test udf3',
    'udf4': 'test udf4',
    'udf5': 'test udf5',
    'currencycode': '784',
    'id': 'ipay12345abcdef',
    'password': 'Term@309309',
  };
  DioService dioService = DioService();
  final httpService = HttpService();

  @override
  void initState() {
    super.initState();
    updatePlatformInfo((info) {
      setState(() {
        platformInfo = info;
      });
    });
    addStatusMessage('PLATFORM ---> $platformInfo...');
    animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animationController.repeat();
    startTimer();
    loadEnvData();
  }

  @override
  void dispose() {
    animationController.dispose();
    _jsonController.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void scaffoldMsg(BuildContext context, String msg, fontSizes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          width: MediaQuery.of(context).size.width *
              0.8, // 80% of the screen width
          alignment: Alignment.center,
          child: Text(
            msg.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSizes.smallerFontSize4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width *
              0.1, // Center it by adding side margins
          vertical: 20,
        ), // Optional, to control vertical margin
      ),
    );
  }

  Widget _title(fontSizes) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 12,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'Transactions',
            style: GoogleFonts.aleo(
              textStyle: Theme.of(context).textTheme.bodyLarge,
              fontSize: fontSizes.largerFontSize4,
              fontWeight: FontWeight.normal,
              color: Colors.green,
            )),
      ),
    );
  }

  Future<void> loadEnvData() async {
    try {
      if (platformInfo == 'WIN') {
        await dotenv.load(fileName: 'assets/.env');
      } else if (platformInfo == 'WEB') {
        await dotenv.load();
      }
      envMap = dotenv.env; // Directly get the env variables as a Map
      addStatusMessage('ENVIRONMENT DATA LOADED...');
      Logger.log('Loaded ENV data: $envMap', level: LogLevel.info);
    } catch (e) {
      Logger.log(e.toString(), level: LogLevel.error);
      addStatusMessage('ERROR LOADING ENV FILE: ${e.toString()}');
      return;
    }
    // Pretty print JSON string with indentation
    final prettyJsonString = const JsonEncoder.withIndent('  ').convert(envMap);
    addStatusMessage(
        prettyJsonString); // This will now print it with proper indentation
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // Ensure widget is still mounted
      setState(() {
        _seconds++;
      });
    });
  }

  void updatePlatformInfo(Function(String) updateState) {
    String platformInfo;
    if (kIsWeb) {
      platformInfo = 'WEB';
    } else if (io.Platform.isWindows) {
      platformInfo = 'WIN';
    } else if (io.Platform.isMacOS) {
      platformInfo = 'MAC';
    } else if (io.Platform.isLinux) {
      platformInfo = 'LIN';
    } else if (io.Platform.isAndroid) {
      platformInfo = 'AND';
    } else if (io.Platform.isIOS) {
      platformInfo = 'IOS';
    } else {
      platformInfo = 'UNK';
    }
    updateState(platformInfo);
  }

  void addStatusMessage(String message) {
    if (!mounted) return; // Ensure widget is still mounted
    String currentTime = DateFormat('hh:mm:ss.SSS').format(DateTime.now());
    setState(() {
      statusMessages.add('$currentTime :  $message');
    });
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String encryptionPayload(String payload, String encryptionKey) {
    // Define your key (must be 16, 24, or 32 bytes for AES)
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromLength(16); // Initialization Vector

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));
    // Create encrypter
    // final encrypter = encrypt.Encrypter(encrypt.AES(key));
    // Plain text to be encrypted
    final plainText = payload;
    // Encrypting the text
    final encrypted = encrypter.encrypt(plainText);
    Logger.log('Encrypted: ${encrypted.base64}', level: LogLevel.info);
    // Decrypting the text
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    Logger.log('Decrypted: $decrypted', level: LogLevel.info);
    return encrypted.base64;
  }

  String encryptionPayloadCBC(String payload, String encryptionKey) {
    Logger.log('payload: $payload', level: LogLevel.critical);
    Logger.log('encryptionKey: $encryptionKey', level: LogLevel.critical);
    Logger.log('iv: PGKEYENCDECIVSPC', level: LogLevel.critical);
    // Define your key (must be 16, 24, or 32 bytes for AES)
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromUtf8("PGKEYENCDECIVSPC");
    // final iv = encrypt.IV.fromLength(16);  // Initialization Vector
    // Use CBC mode for encryption
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    // Plain text to be encrypted
    final plainText = payload;
    // Encrypting the text
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    Logger.log('Encrypted: ${encrypted.base64}', level: LogLevel.critical);
    // Decrypting the text
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    Logger.log('Decrypted: $decrypted', level: LogLevel.info);
    return encrypted.base64;
  }

  String convertToQueryString(Map<String, dynamic> data) {
    List<String> queryParameters = [];

    data.forEach((key, value) {
      // Convert the value to a string without replacing spaces
      String formattedValue = value.toString();
      queryParameters.add('$key=$formattedValue');
    });
    // Join the parameters with '&' and return the query string
    return queryParameters.join('&');
  }

  String convertToJsonString(String trandata, String id) {
    // Create a map with the required structure
    // trandata = '0CE90F34CBE341598BC0BD7D6269167E62D490E2C9669AE1CE64ACEF1D0856512B36A01523130DAAD080DF8C128DA34B2DBED6A3B6B25233C359CC0890CB523C96EA730DC65C1A47E5015B9D52673673530024D05EDA7B98DFDADAAE928E9CEA1DC48507FF2BBEA81ABA677F8082726E3A7E2DEC4B0281AAC536EEA30595E0613BC45D0EEEE16FABD5596B24114AB7CDCEA78869714674DE061FE77B3622C14964D9C4C6BEF03AAA15498B5890DC7E7666AD079408538DC5CB0729CAD427AD30';
    Map<String, dynamic> data = {
      'trandata': trandata,
      'id': id,
    };
    return jsonEncode([data]);
    // Convert the map to a JSON string
    // String jsonString = jsonEncode([data]);
    // Pretty-print the JSON
    // var jsonPrettyPrint = JsonEncoder.withIndent('  '); // Indent with 2 spaces
    // print(jsonPrettyPrint);
    // return jsonPrettyPrint.convert(jsonDecode(jsonString));
  }

  Map<String, dynamic> convertToJson(String trandata, String id) {
    // Create a map with the required structure
    Map<String, dynamic> data = {
      'trandata': trandata,
      'id': id,
    };
    // Return the map directly
    return {
      'data': [data]
    };
  }

  @override
  Widget build(BuildContext context) {
    final fontSizes = FontSizes.fromContext(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage(
                  'assets/bg2.jpg'), // Fallback predefined image
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.7),
                BlendMode.luminosity,
              ),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(0)),
            gradient: const LinearGradient(
              colors: [Color(0xffffffff), Color(0xffffffff)],
              stops: [0, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _title(fontSizes),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the row horizontally
                children: [
                  Expanded(
                    flex:
                        1, // Set the flex to determine how much space each box takes up
                    child: Container(
                      height: MediaQuery.of(context).size.height / 1.15,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green, // Green border
                          width: 1, // Border width
                        ),
                        color: Colors.transparent, // Transparent background
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            15.0), // Add padding inside the container
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between Dropdown and Button
                              children: [
                                Expanded(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height / 20,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: (_pgTranMode == 'HOSTED' && _tranType != 'PURCHASE' && _tranType != 'AUTH')
                                            ? 'PURCHASE' // Reset to 'PURCHASE' if invalid
                                            : (_pgTranMode == 'TRANPORTAL' && (_tranType == 'PURCHASE' || _tranType == 'AUTH'))
                                            ? 'INQUIRY' // Reset to 'INQUIRY' if invalid
                                            : _tranType, // Otherwise, keep the selected value
                                        items: (_pgTranMode == 'HOSTED'
                                            ? <String>['PURCHASE', 'AUTH']
                                            : <String>['INQUIRY', 'CREDIT', 'CAPTURE', 'VOID', 'REFUND'])
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Center(
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  fontSize: fontSizes.smallerFontSize5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _tranType = newValue!;
                                            print(_tranType);
                                          });
                                        },
                                        selectedItemBuilder: (BuildContext context) {
                                          return (_pgTranMode == 'HOSTED'
                                              ? <String>['PURCHASE', 'AUTH']
                                              : <String>['INQUIRY', 'CREDIT', 'CAPTURE', 'VOID', 'REFUND'])
                                              .map((String value) {
                                            return Center(
                                              child: Text(
                                                _tranType!,
                                                style: TextStyle(
                                                  fontSize: fontSizes.smallerFontSize5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }).toList();
                                        },
                                        dropdownColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5), // Add spacing between the Dropdown and Button
                                Expanded(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height / 20,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _pgTranMode,
                                        items: <String>['HOSTED', 'TRANPORTAL']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Center(
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  fontSize: fontSizes.smallerFontSize5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _pgTranMode = newValue!;
                                            print(_pgTranMode);
                                          });
                                        },
                                        selectedItemBuilder: (BuildContext context) {
                                          return <String>['HOSTED', 'TRANPORTAL'].map((String value) {
                                            return Center(
                                              child: Text(
                                                _pgTranMode!,
                                                style: TextStyle(
                                                  fontSize: fontSizes.smallerFontSize5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }).toList();
                                        },
                                        dropdownColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5), // Add spacing between the Dropdown and Button
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      formData['id'] = envMap['TRAN_PORTAL_ID'];
                                      formData['password'] = envMap['TRAN_PORTAL_PASSWORD'];
                                      String queryString = convertToQueryString(formData) + '&';
                                      String payload = AES.encryptAES(envMap['RESOURCE_KEY'], queryString);
                                      String jsonOutput = convertToJsonString(payload, envMap['TRAN_PORTAL_ID']);
                                      Logger.log('UploadData: $jsonOutput', level: LogLevel.info);
                                      addStatusMessage(jsonOutput);

                                      var url = 'https://pguat.creditpluspinelabs.com/ipay/hostedHTTP';
                                      try {
                                        final response = await httpService.sendPostRequest(url, jsonOutput);
                                        if (response.statusCode == 200) {
                                          var data = jsonDecode(response.body);
                                          final trandata = data['trandata'];
                                          if (trandata != null) {
                                            final decryptedTrandata = AES.decryptAES(envMap['RESOURCE_KEY'], trandata);
                                            Logger.log('Decrypted URL && Payment ID: $decryptedTrandata', level: LogLevel.debug);
                                            int colonIndex = decryptedTrandata.indexOf(":");
                                            String paymentId = decryptedTrandata.substring(0, colonIndex);
                                            String url = decryptedTrandata.substring(colonIndex + 1);
                                            final completeUrl = '$url?PaymentID=$paymentId';
                                            Logger.log('Page: $completeUrl', level: LogLevel.critical);
                                            final uri = Uri.parse(completeUrl);
                                            await launchUrl(uri);
                                          } else {
                                            print('Error: "trandata" field not found in response');
                                          }
                                        } else {
                                          print('Request failed with status: ${response.statusCode}');
                                          print('Response body: ${response.body}');
                                        }
                                      } catch (e) {
                                        print('Error: $e');
                                      }
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: MediaQuery.of(context).size.height / 20,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.blue,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.15),
                                              offset: const Offset(4, 6),
                                              blurRadius: 15,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'PROCESS',
                                          style: TextStyle(
                                            fontSize: fontSizes.smallerFontSize5,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),//TRAN SELECTOR AND PROCESS BUTTON
                            const SizedBox(
                                height:
                                    10), // Add spacing between the containers
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Center the Row itself
                              children: [
                                Expanded(
                                  flex:
                                      1, // Set the flex to determine how much space each box takes up
                                  child: Center(
                                    // Center the container within the Row
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          20), // Add some padding
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .white, // Set background color to white
                                        borderRadius: BorderRadius.circular(
                                            5), // Rounded corners
                                        border: Border.all(
                                          color: Colors
                                              .green, // Optional: Add a border to the box
                                          width: 1,
                                        ),
                                      ),
                                      child: GridView.builder(
                                        shrinkWrap:
                                            true, // Ensure GridView only takes up as much space as needed
                                        physics:
                                            const NeverScrollableScrollPhysics(), // Disable scrolling
                                        itemCount: formData.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              2, // 2 TextFormFields per row
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 10,
                                          childAspectRatio:
                                              5, // Adjust this to control the field height
                                        ),
                                        itemBuilder: (context, index) {
                                          String key =
                                              formData.keys.elementAt(index);
                                          String value = formData[key]!;
                                          return TextFormField(
                                            decoration: InputDecoration(
                                              labelText:
                                                  key.toString().toUpperCase(),
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                            initialValue: value,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ), //TRABSACTION BOX
                  const SizedBox(
                      width: 5), // Add spacing between the containers
                  Expanded(
                    flex: 2, // This will take up the remaining available space
                    child: Container(
                      height: MediaQuery.of(context).size.height / 1.15,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              Colors.green, // Optional: Add a border to the box
                          width: 1,
                        ),
                        color: Colors.transparent, // Transparent background
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          // Main content area
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListView.builder(
                              shrinkWrap: false,
                              itemCount: statusMessages.length,
                              controller: _scrollController,
                              itemBuilder: (context, index) {
                                final message = statusMessages[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 1.0),
                                  child: Text(
                                    message,
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.justify,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Button at the bottom right corner
                          Positioned(
                            bottom: 20, // Adjust the distance from the bottom
                            right: 20, // Adjust the distance from the right
                            child: IconButton(
                              icon:
                                  const Icon(Icons.download_for_offline_sharp),
                              iconSize: fontSizes
                                  .largerFontSize2, // Set the size of the icon
                              color: Colors.green, // Set the color of the icon
                              onPressed: () {
                                Logger.log(statusMessages.toString(),
                                    level: LogLevel.critical);
                                if (statusMessages.toString() != null &&
                                    statusMessages.toString() != '' &&
                                    statusMessages.toString() != '[]') {
                                  if (platformInfo == 'WEB') {
                                    exportLogs(statusMessages);
                                    setState(() {
                                      statusMessages.clear();
                                    });
                                  } else {
                                    exportLogs(statusMessages);
                                    setState(() {
                                      statusMessages.clear();
                                    });
                                  }
                                } else {
                                  scaffoldMsg(
                                      context, 'No Data to Export', fontSizes);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), // MESSAGE BOX//MESSAGE BOX
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
