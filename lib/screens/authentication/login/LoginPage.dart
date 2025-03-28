import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../utility/size_config.dart';
import '/utility/check_internet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/config.dart';
import '../../../utility/loader.dart';
import '../../../utility/logger.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';

import '/model/request/LoginRequest.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int? selected = 1;

  final LoginRequest _loginRequest = LoginRequest();

  String stringResponse = '';
  Map mapResponse = {};
  late var names = [];
  late var totalList = [];
  late var searchData = [];
  String? selectedRole;
  String? selectedRoleValue;
  FocusNode inputNode = FocusNode();

  @override
  void initState() {
    handleLocalStorage();
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      openKeyboard();
    });
  }

  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }

  handleLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', 10);
  }

  onBackPressed() {
    Navigator.pop(context, true);
  }

  Future<void> checkUserLogin(value) async {
    bool isConnected = await CheckInternet.isInternet();
    if (!isConnected) {
      _showSnackBar(
          "No internet connection. Please try again.", context, false);
      return;
    }

    Loader.showLoader(context);
    http.Response response;
    var apiURL = BASE_URL + VALIDATE_LOGIN_USER_SSO;
    Map map = {"userName": value};
    var body = json.encode(map);
    try {
      response = await http
          .post(Uri.parse(apiURL),
              headers: {"Content-Type": "application/json"}, body: body)
          .timeout(const Duration(seconds: 15));
      // var apiURL = BASE_URL + VALIDATE_LOGIN_USER + value;
      // try {
      //   response = await http.get(Uri.parse(apiURL), headers: {
      //     "Content-Type": "application/json"
      //   }).timeout(const Duration(seconds: 15));

      var apiResp = json.decode(response.body);
      Logger.showLogging(apiURL);
      Logger.showLogging(apiResp);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Loader.hideLoader(context);
        if (apiResp["status"] == "success") {
          var userData = apiResp['data'];
          onLogin(userData);
        } else {
          _showSnackBar(apiResp['message'], context, false);
        }
      } else {
        _showSnackBar(
            apiResp['message'] ?? "Unexpected error occurred.", context, false);
        Loader.hideLoader(context);
      }
    } on TimeoutException catch (e) {
      Loader.hideLoader(context);
      print('timne out checking===========>');
      // Handles Timeout failures
      print('Timeout Error: ${e.message} ${e.toString()}');
      // retryLogin(value);
    } on SocketException catch (e) {
      // Handles SSL/TLS issues like certificate validation failures
      print('SocketException: SSL/TLS Error: ${e.message} ${e.toString()}');
    } on HandshakeException catch (e) {
      // This can be triggered for SSL handshake failures
      print(
          'HandshakeException: SSL Handshake error: ${e.message} ${e.toString()}');
    } catch (e) {
      // Handles other types of errors
      print('Unexpected error: $e ${e.toString()}');
    }
  }

  onLogin(userData) async {
    print('userdata====>${userData}');
    FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('USER_ID', userData['userId'] ?? 0);
    await prefs.setString('loggedUserName', userData['userName']);
    await prefs.setString('loggedUserRole', userData['userType']!);

    // if (userData['userType'] == 'DRIVER') {
    if (userData['requestForOtp']) {
      await prefs.setString('loggedUserPhoneNumber', userData['mobileNumber']);
      // driverMobileCheck(userData);
      Navigator.pushNamed(context, '/otpPage');
    } else {
      Navigator.pushNamed(context, '/passwordPage', arguments: {});
    }
  }

  Future driverMobileCheck(userData) async {
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {
      "password": "",
      "username": "",
      "userType": userData['userType'],
      "phoneNumber": userData['mobileNumber']
    };
    var body = json.encode(map);
    response = await http.post(Uri.parse(BASE_URL + POST_LOGIN_DETAILS),
        headers: {"Content-Type": "application/json"}, body: body);
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      print('login otp resp ==== $mapResponse');

      Navigator.pop(context);
      _showSnackBar(
          mapResponse['message'], context, mapResponse["status"] == "success");
      if (mapResponse["status"] == "success") {
        Navigator.pushNamed(context, '/otpPage');
      }
    } else {
      // print('login resp ==== $mapResponse');
      _showSnackBar(mapResponse['message'], context, false);
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> _onWillPop() async {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
          child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        backgroundColor: loginBgColor,
        body: SafeArea(
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          color: loginBgColor,
                          child: Column(
                            children: [
                              Container(
                                  child: Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: getProportionateScreenWidth(20)),
                                    width: screenWidth,
                                    height: getProportionateScreenHeight(250),
                                    child: Image.asset(
                                      'assets/images/warehouse_image.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  // Positioned(
                                  //   top: screenHeight * 0.01,
                                  //   right: screenWidth * 0.07,
                                  //   child:
                                  //       Utils.returnRaiseQueryButton(context),
                                  // ),
                                ],
                              )),
                              Container(
                                width: screenWidth * 0.8,
                                height: getProportionateScreenHeight(40),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/logiFreight_logo.png',
                                      height: getProportionateScreenHeight(40),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: getScreenHeight(5),
                                    left: screenWidth * 0.1,
                                    right: getScreenWidth(20)),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Login with your provided credentials',
                                    style: TextStyle(
                                      fontFamily: ffGRegular,
                                      color: loginSubHeadingColor,
                                      fontSize: getScreenWidth(16),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // height: getProportionateScreenHeight(60),
                                margin: EdgeInsets.only(
                                    top: screenHeight * 0.02,
                                    left: screenWidth * 0.1,
                                    right: screenWidth * 0.1),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius:
                                      BorderRadius.circular(getScreenWidth(10)),
                                  border: Border.all(
                                    width: getScreenWidth(1),
                                    color: border,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  autofocus: true,
                                  focusNode: inputNode,
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  style: TextStyle(
                                    fontSize: getScreenWidth(18),
                                    color: Colors.black,
                                    fontFamily: ffGMedium,
                                  ),
                                  // keyboardType: defaultTargetPlatform ==
                                  //         TargetPlatform.iOS
                                  //     ? TextInputType.numberWithOptions(
                                  //         decimal: true, signed: true)
                                  //     : TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: 'Username/Email/Phone',
                                    labelStyle: TextStyle(
                                      fontFamily: ffGMedium,
                                      fontSize: getScreenWidth(18),
                                      color: textInputPlaceholderColor,
                                    ),
                                    contentPadding:
                                        EdgeInsets.all(getScreenWidth(15)),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    _loginRequest.username = value.trim();
                                  },
                                ),
                              ),
                              SizedBox(height: getScreenHeight(10)),
                              InkWell(
                                onTap: () {
                                  Utils.clearToasts(context);
                                  var tempValue = _loginRequest.username.trim();
                                  if (tempValue == '') {
                                    _showSnackBar(
                                        "Please enter username/email/phoneNumber",
                                        context,
                                        false);
                                  } else {
                                    checkUserLogin(tempValue);
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: screenWidth * 0.09,
                                      right: screenWidth * 0.09),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(getScreenWidth(10))),
                                      side: BorderSide(
                                          width: 1, color: appThemeColor),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: appThemeColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                getScreenWidth(10))),
                                      ),
                                      alignment: Alignment.center,
                                      height: getScreenHeight(60),
                                      child: Text(
                                        "Next",
                                        style: TextStyle(
                                          fontFamily: ffGSemiBold,
                                          fontSize: getScreenWidth(18),
                                          color: buttonTextWhiteColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: getScreenHeight(5)),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/signupPage');
                                },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  margin: EdgeInsets.only(
                                      right: screenWidth * 0.11),
                                  child: Text(
                                    'Register${BASE_URL == 'https://dealerportal.mllqa.com/api/' ? '..QA' : ''}',
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 1.5,
                                        fontSize: getScreenWidth(16),
                                        fontFamily: ffGMedium,
                                        color: appThemeColor),
                                  ),
                                ),
                              ),
                              SizedBox(height: getScreenHeight(50)),
                              InkWell(
                                onTap: () async {
                                  var url = Uri.parse(
                                      "https://mahindralogistics.com/privacy-policy/");
                                  try {
                                    if (await canLaunchUrl(url)) {
                                      Utils.openUrl(url);
                                    } else {
                                      _showSnackBar(
                                          "Could not open URL in browser.",
                                          context,
                                          false);
                                    }
                                  } catch (e) {
                                    _showSnackBar(
                                        "Failed to open URL in browser.",
                                        context,
                                        false);
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(
                                      right: screenWidth * 0.11),
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 1.5,
                                        fontSize: getScreenWidth(16),
                                        fontFamily: ffGMedium,
                                        color: appThemeColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
