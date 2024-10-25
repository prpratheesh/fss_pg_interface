import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fss_pg_interface/transaction_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'font_sizes.dart';
import 'logger.dart';

class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController batchController = TextEditingController();
  FocusNode passwordFocusController = FocusNode();
  late FocusNode focusNode;
  bool envStatus = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    _loadEnvFile();
  }

  @override
  void dispose() {
    focusNode.dispose();
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _title(fontSizes) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 8,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'Retail X',
            style: GoogleFonts.aleo(
              textStyle: Theme.of(context).textTheme.bodyLarge,
              fontSize: fontSizes.largerFontSize5,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            )),
      ),
    );
  }

  Widget _usernameController(fontSizes) {
    return Container(
        width: MediaQuery.of(context).size.width/4,
        height: MediaQuery.of(context).size.height / 12,
        // padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
//        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
            ],
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            textAlign: TextAlign.left,
            focusNode: focusNode,
            autofocus: true,
            // obscureText: true,
            controller: userNameController,
            style: TextStyle(fontSize: fontSizes.smallerFontSize4, height: 1, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.person,
                  size: fontSizes.smallerFontSize2,
                  color: Colors.blue,
                ),
              ),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.00),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.yellow, width: 1.0), // Border color when not focused
                borderRadius: BorderRadius.circular(10.0),
              ),
              labelText: ' USERNAME',
              labelStyle: TextStyle(color: Colors.white, fontSize: fontSizes.smallerFontSize4),
            )));
  }

  Widget _passwordController(fontSizes) {
    return Container(
        width: MediaQuery.of(context).size.width/4,
        height: MediaQuery.of(context).size.height / 12,
        // padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
//        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
            ],
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            obscureText: true,
            textAlign: TextAlign.left,
            autofocus: true,
            controller: passwordController,
            style: TextStyle(fontSize: fontSizes.smallerFontSize4, height: 1, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.password,
                  size: fontSizes.smallerFontSize2,
                  color: Colors.blue,
                ),
              ),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.00),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.yellow, width: 1.0), // Border color when not focused
                borderRadius: BorderRadius.circular(10.0),
              ),
              labelText: ' PASSWORD',
              labelStyle: TextStyle(color: Colors.white, fontSize: fontSizes.smallerFontSize4),
            )));
  }

  Widget _loginButton(fontSizes) {
    return InkWell(
      onTap: () async {
        String userNameLogin = userNameController.text;
        String passwordLogin = passwordController.text;
        focusNode.unfocus();
        if (userNameLogin.isEmpty || passwordLogin.isEmpty) {
          scaffoldMsg(context, 'Please Enter Credentials', fontSizes);
          return;
        }else if((userNameLogin=='ADMIN' || userNameLogin=='admin') && (userNameLogin=='ADMIN' || userNameLogin=='admin')){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransactionPage()),
            );
        }
      },
      onDoubleTap: () async {
        // You can add double tap action here
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: MediaQuery.of(context).size.width/4,
          height: MediaQuery.of(context).size.height / 20,
          // padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // More rounded button
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.redAccent], // Green gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
            'LOGIN',
            style: TextStyle(
              fontSize: fontSizes.smallerFontSize4, // Pass font size as a parameter
              fontWeight: FontWeight.normal,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(fontSizes) {
    return const Center(
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              'Version : 1.0.01',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 15,color: Colors.white,fontStyle: FontStyle.normal,),
            ),
        ));
  }

  void scaffoldMsg(BuildContext context, String msg, fontSizes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of the screen width
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
          horizontal: MediaQuery.of(context).size.width * 0.1, // Center it by adding side margins
          vertical: 20,
        ), // Optional, to control vertical margin
      ),
    );
  }

  void _loadEnvFile() async{
    await dotenv.load();
    try{
    if(dotenv.env!=null){
      setState(() {
        envStatus = true;
      });
    }
    else{
      setState(() {
        envStatus = false;
      });
    }}
    catch(e){
      print(e.toString);
    }
    Logger.log(dotenv.env['TRAN_PORTAL_ID'].toString());
    Logger.log(dotenv.env['TRAN_PORTAL_PASSWORD'].toString());
    Logger.log(dotenv.env['RESOURCE_KEY'].toString());
    // print(dotenv.env);
  }

  @override
  Widget build(BuildContext context) {
    final fontSizes = FontSizes.fromContext(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/bg.jpg'), // Use fallback predefined image
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7), BlendMode.luminosity),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _title(fontSizes),
                  Spacer(flex: 2),
                  _usernameController(fontSizes),
                  _passwordController(fontSizes),
                  _loginButton(fontSizes),
                  Spacer(flex: 3),
                  _info(fontSizes),
                ])),
      ),
    );
  }
}