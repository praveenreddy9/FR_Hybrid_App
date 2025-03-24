import 'dart:async';
import 'dart:io';

import 'package:facial_attendance/utility/FooterButton.dart';

import '/utility/size_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/utility/Colors.dart';

import '/model/request/LoginRequest.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
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
                                    child: null,
                                  ),
                                ],
                              )),
                              FooterButton(
                                  'LIST',
                                  '',
                                  context,
                                  () => {
                                        Navigator.pushNamed(
                                            context, '/userListScreen')
                                      }),
                              // SizedBox(height: getScreenHeight(10)),
                              FooterButton(
                                  'ATTENDANCE',
                                  '',
                                  context,
                                  () => {
                                        Navigator.pushNamed(
                                            // context, '/recognisePage')
                                            context,
                                            // '/recognisePageNew')
                                            // '/faceCaptureScreen')
                                            '/recogniseFirst')
                                      }),
                              FooterButton(
                                  'REGISTER',
                                  '',
                                  context,
                                  () => {
                                        Navigator.pushNamed(
                                            // context, '/recognisePage')
                                            context,
                                            // '/faceCaptureScreen')
                                            '/recogniseSecond')
                                      }),
                              SizedBox(height: getScreenHeight(50)),
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
