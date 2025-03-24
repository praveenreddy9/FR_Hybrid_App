import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../utility/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/error_handling.dart';
import '../../utility/FooterButton.dart';
import '../../utility/SingleParamHeader.dart';
import '../../utility/size_config.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../services/config.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var accesstoken;
  var USER_ID;
  String USER_NAME = "";
  String USER_ROLE = "";
  String BACKEND_ROLE = "";
  var savedCookies;

  var _selectedRadioButtonOption = 0;

  String stringResponse = '';

  var noVehiclePlaced = '0';
  var delivered = '0';
  var readyToPickup = '0';
  var inTransit = '0';
  var booked = '0';
  var pendingPdi = '0';

  String roleCheck = "BA_LOGIN"; //DEALER_LOGIN,DRIVER_LOGIN, CONSIGNEE_LOGIN,

  String searchValue = '';
  var searchListData = [];

  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  var loggedUserRole;

  String pendingTitle = "PENDING ASSIGNMENT";
  String pendingSubTitle = "Vehicle, Driver to be assigned";
  String pendingStatus = "PENDING_ASSIGNMENT";

  String pickupTitle = "READY TO PICKUP";
  String pickupSubTitle = "Vehicle assigned, on the way to pickup";
  String pickupStatus = "READY_TO_PICKUP";

  String intransitTitle = "INTRANSIT";
  String intransitSubTitle = "Orders dispatched and on the way to destination";
  String intransitStatus = "INTRANSIT";

  String deliveredTitle = "DELIVERED";
  String deliveredSubTitle = "Orders delivered with ePOD";
  String deliveredStatus = "DELIVERED";

  String bookedTitle = "BOOKED";
  String bookedSubTitle = "Orders created, to be dispatched";
  String bookedStatus = "BOOKED";

  String pendingPdiTitle = "PENDING PDI";
  String pendingPdiSubTitle = "Orders with pending ePOD";
  String pendingPdiStatus = "PENDING_PDI";

  List dashboardArray = [];

  @override
  void initState() {
    fetchLocalStorageData();
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          searchValue = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Map mapResponse = {};

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  fetchLocalStorageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString('accessToken');
    USER_ID = prefs.getInt('USER_ID');
    USER_NAME = prefs.getString('USER_NAME')!;
    BACKEND_ROLE = prefs.getString('BACKEND_ROLE')!;
    loggedUserRole = prefs.getString('loggedUserRole');
    savedCookies = prefs.getString('savedCookies');
    USER_ROLE = loggedUserRole;
    // getDashboardCounts();
    _checkAppVersion();
  }

  clearStorage() async {
    Utils.clearToasts(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(context).pushNamed('/splashPage');
  }

  void _checkAppVersion() async {
    // print('logout api check====');
    Utils.returnScreenLoader(context);
    try {
      http.Response response;
      Map map = {"IsForceUpdate": '1'};
      var body = json.encode(map);
      response = await http.post(
        Uri.parse(BASE_URL + APP_UPDATE_CHECK),
        headers: {
          "Content-Type": "application/json",
          "accesstoken": accesstoken,
          "Authorization": accesstoken,
          "Cookie": savedCookies
        },
        body: body,
      );

      if (response.statusCode == 401) {
        clearStorage();
        _showSnackBar('Session Expired, Please Login again.', context, false);
        return;
      }

      if (response.statusCode == 200) {
        if (mapResponse["status"] == "success") {
          Navigator.pop(context);
          stringResponse = response.body;
          mapResponse = json.decode(response.body);
          var updateData = mapResponse['data'];
          // print('updateData=====>${updateData}');
          String currentVersion =
              Platform.isIOS ? IOS_APP_VERSION : ANDROID_APP_VERSION;

          String APP_LINK = Platform.isIOS ? IOS_APP_LINK : ANDROID_APP_LINK;

          //IsForceUpdate 0 don't show,1 for both,2 for Android,3 for iOS

          if (currentVersion != updateData['Version']) {
            if (updateData['IsForceUpdate'] == 1) {
              _showUpdateDialog(APP_LINK);
            } else if (updateData['IsForceUpdate'] == 2) {
              if (Platform.isAndroid) {
                _showUpdateDialog(APP_LINK);
              }
            } else if (updateData['IsForceUpdate'] == 3) {
              if (Platform.isIOS) {
                _showUpdateDialog(APP_LINK);
              }
            }
          }

          getDashboardCounts();
        } else {
          Navigator.pop(context);
          // error_handling.errorValidation(
          //     context, response.statusCode, mapResponse['message'], false);
          getDashboardCounts();
        }
      } else if (response.statusCode == 502) {
        Navigator.pop(context);
        _showSnackBar('Bad Gateway', context, false);
      } else {
        Navigator.pop(context);
        getDashboardCounts();
        // error_handling.errorValidation(
        //     context, response.statusCode, mapResponse['message'], false);
      }
    } catch (e) {
      Navigator.pop(context);
      debugPrint("Error in app version check: $e");
    }
  }

  bool _isVersionLower(String currentVersion, String targetVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> target = targetVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < target.length; i++) {
      if (i >= current.length || current[i] < target[i]) {
        return true;
      } else if (current[i] > target[i]) {
        return false;
      }
    }
    return false;
  }

  void _showUpdateDialog(String APP_LINK) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteBgColor,
          title: const Text("Update Required"),
          content: const Text(
              "A new version of the app is available. Please update to continue."),
          actions: [
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(APP_LINK);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  throw "Could not launch url";
                }
              },
              child: const Text("Update Now"),
            ),
          ],
        );
      },
    );
  }

  void logOut(context) async {
    // print('logout api check====');
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {
      "userid": USER_ID,
    };
    var body = json.encode(map);
    response = await http.post(
      Uri.parse(BASE_URL + API_LOGOUT),
      headers: {
        "Content-Type": "application/json",
        "accesstoken": accesstoken,
        "authorization": accesstoken,
        "Authorization": accesstoken,
        "Cookie": savedCookies
      },
      body: body,
    );
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      if (mapResponse["status"] == "success") {
        _showSnackBar(mapResponse['message'], context, true);
        clearStorage();
      } else {
        error_handling.errorValidation(
            context, response.statusCode, mapResponse['message'], false);
      }
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, mapResponse['message'], false);
    }
  }

  Future getDashboardCounts() async {
    Utils.returnDashboardScreenLoader(context);
    try {
      // Loader.showLoader(context);
      http.Response response;
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "accesstoken": accesstoken,
        "authorization": accesstoken,
        "Authorization": accesstoken,
        "Cookie": savedCookies
      };
      response = await http.get(Uri.parse(BASE_URL + GET_DASHBOARD_COUNTS),
          headers: headers);
      // print('headers======>${headers}');
      // print('swsss======>${response.body}');
      // print('Status======>${response.statusCode}');

      if (response.statusCode == 401) {
        clearStorage();
        _showSnackBar('Session Expired, Please Login again.', context, false);
        return;
      }
      // print('response======>${json.decode(response.body)}');

      if (response.statusCode == 200) {
        Navigator.pop(context);
        // Loader.hideLoader(context);
        stringResponse = response.body;
        mapResponse = json.decode(response.body);
        if (mapResponse["status"] == "success") {
          var parsedResponse = mapResponse['data'];
          noVehiclePlaced = parsedResponse['noVehiclePlaced'] != null
              ? parsedResponse['noVehiclePlaced'].toString()
              : '0';
          readyToPickup = parsedResponse['readyToPickup'] != null
              ? parsedResponse['readyToPickup'].toString()
              : '0';
          inTransit = parsedResponse['inTransit'] != null
              ? parsedResponse['inTransit'].toString()
              : '0';
          delivered = parsedResponse['delivered'] != null
              ? parsedResponse['delivered'].toString()
              : '0';
          booked = parsedResponse['booked'] != null
              ? parsedResponse['booked'].toString()
              : '0';
          pendingPdi = parsedResponse['pendingPdi'] != null
              ? parsedResponse['pendingPdi'].toString()
              : '0';

          var tempPendingObject = {
            'title': pendingTitle,
            'subtitle': pendingSubTitle,
            'count': noVehiclePlaced,
            'status': pendingStatus
          };
          var tempPickupObject = {
            'title': pickupTitle,
            'subtitle': pickupSubTitle,
            'count': readyToPickup,
            'status': pickupStatus
          };
          var tempBookedObject = {
            'title': bookedTitle,
            'subtitle': bookedSubTitle,
            'count': booked,
            'status': bookedStatus
          };
          var tempIntransitObject = {
            'title': intransitTitle,
            'subtitle': intransitSubTitle,
            'count': inTransit,
            'status': intransitStatus
          };
          var tempDeliveredObject = {
            'title': deliveredTitle,
            'subtitle': deliveredSubTitle,
            'count': delivered,
            'status': deliveredStatus
          };
          var tempPendingPdiObject = {
            'title': pendingPdiTitle,
            'subtitle': pendingPdiSubTitle,
            'count': pendingPdi,
            'status': pendingPdiStatus
          };

          var finalArray = [];

          if (parsedResponse['noVehiclePlaced'] != null) {
            finalArray.add(tempPendingObject);
          }
          if (parsedResponse['booked'] != null) {
            finalArray.add(tempBookedObject);
          }
          if (parsedResponse['readyToPickup'] != null) {
            finalArray.add(tempPickupObject);
          }
          if (parsedResponse['inTransit'] != null) {
            finalArray.add(tempIntransitObject);
          }
          if (parsedResponse['delivered'] != null) {
            finalArray.add(tempDeliveredObject);
          }
          if (parsedResponse['pendingPdi'] != null) {
            finalArray.add(tempPendingPdiObject);
          }

          setState(() {
            dashboardArray = finalArray;
          });
        } else {
          setState(() {
            dashboardArray = [];
          });
          error_handling.errorValidation(
              context, response.statusCode, mapResponse['message'], false);
        }
      } else if (response.statusCode == 502) {
        Navigator.pop(context);
        _showSnackBar('Bad Gateway', context, false);
      } else {
        setState(() {
          dashboardArray = [];
        });
        Navigator.pop(context);
        // stringResponse = response.body;
        mapResponse = json.decode(response.body);
        error_handling.errorValidation(
            context, response.statusCode, mapResponse['message'], false);
      }
    } catch (e) {
      Navigator.pop(context);
      debugPrint("Error in app dashboard count: $e");
    }
  }

  Future searchData() async {
    Utils.returnScreenLoader(context);
    try {
      http.Response response;
      Map map = {"vinOrLrOrInvoiceNo": searchValue};
      var body = json.encode(map);
      // print('search body=======>${body}=======${BASE_URL + DASHBOARD_SEARCH}');
      response = await http.post(Uri.parse(BASE_URL + DASHBOARD_SEARCH),
          headers: {
            "Content-Type": "application/json",
            "accesstoken": accesstoken,
            "Authorization": accesstoken,
            "Cookie": savedCookies
          },
          body: body);

      // Logger.showLogging(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        mapResponse = json.decode(response.body);
        if (mapResponse["status"] == "success") {
          setState(() {
            searchListData = mapResponse['data'];
          });
          // print('search resp====>$searchListData');
          if (searchListData.length == 1) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                'tripNumber', searchListData[0]['tripNumber'].toString());
            await prefs.setString(
                'tripId', searchListData[0]['tripId'].toString());
            Navigator.pushNamed(context, '/tripDetails', arguments: {
              "responseData": searchListData[0],
              "lrNumber": searchListData[0]['lrNumber'],
              "fromScreen": 'dashBoard'
            }).then((result) {
              if (result == true) {
                getDashboardCounts();
                setState(() {
                  searchValue = '';
                  searchListData = [];
                  _searchController.clear();
                });
              }
            });
          }
        } else {
          error_handling.errorValidation(
              context, response.statusCode, 'No Data found..', false);
        }
      } else {
        Navigator.pop(context);
        stringResponse = response.body;
        mapResponse = json.decode(response.body);
        error_handling.errorValidation(
            context, response.statusCode, mapResponse['message'], false);
      }
    } catch (e) {
      Navigator.pop(context);
      debugPrint("Error in app search: $e");
    }
  }

  Future<bool> _onWillPop() async {
    // print('back button hitted');
    Utils.clearToasts(context);
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
    return false;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      barrierColor: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (
        BuildContext context,
      ) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return Container(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select from below options',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: ffGMedium,
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.only(top: 5),
                      backgroundColor: buttonTextBgColor,
                      // primary: buttonTextBgColor,
                      // onPrimary: Colors.red,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setInt('Selected_indentId', 00);
                      await prefs.setBool('Indent_Editing', true);
                      await prefs.setBool('fromDashboardScreen', true);
                      // Navigator.pushNamed(context, '/tripCreation',
                      //     arguments: {}).then((_) {
                      //   setState(() {
                      //     // _selectedRadioButtonOption = 1;
                      //   });
                      // });
                      Navigator.pushNamed(context, '/creationFirstScreen')
                          .then((result) {
                        if (result == true) {
                          getDashboardCounts();
                          setState(() {
                            searchValue = '';
                            searchListData = [];
                            _searchController.clear();
                          });
                        }
                      });
                    },
                    child: ListTile(
                      leading: Radio<int>(
                        activeColor: _selectedRadioButtonOption == 1
                            ? appButtonColor
                            : chatFromUserColor,
                        value: 1,
                        groupValue: _selectedRadioButtonOption,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedRadioButtonOption = 1;
                          });
                        },
                      ),
                      title: Text('Create Indent',
                          style: TextStyle(
                            fontFamily: ffGSemiBold,
                            color: popUpListColor,
                            fontSize: 20.0,
                          )),
                      contentPadding: EdgeInsets.zero,
                    )),
                SizedBox(height: 3.0),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     padding: EdgeInsets.only(top: 5),
                //     primary: buttonTextBgColor,
                //     onPrimary: Colors.red,
                //   ),
                //   onPressed: () {
                //     Navigator.pop(context);
                //     Navigator.pushNamed(context, '/tripsList', arguments: {})
                //         .then((_) {
                //       setState(() {
                //         _selectedRadioButtonOption = 2;
                //       });
                //     });
                //   },
                //   child: ListTile(
                //     leading: Radio<int>(
                //       activeColor: _selectedRadioButtonOption == 2
                //           ? appButtonColor
                //           : chatFromUserColor,
                //       value: 2,
                //       groupValue: _selectedRadioButtonOption,
                //       onChanged: (int? value) {
                //         setState(() {
                //           _selectedRadioButtonOption = 2;
                //         });
                //       },
                //     ),
                //     title: Text('Create LR',
                //         style: TextStyle(
                //           fontFamily: ffGSemiBold,
                //           color: popUpListColor,
                //           fontSize: 20.0,
                //         )),
                //     contentPadding: EdgeInsets.zero,
                //   ),
                // ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel',
                      style: TextStyle(
                        fontFamily: ffGMedium,
                        color: buttonBorderColor,
                        fontSize: 16.0,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white, // White background color
                    // primary: white, // White background color
                    side: BorderSide(
                        color: buttonBorderColor), // Red border color
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final double screenHeight = MediaQuery.of(context).size.height;
    // FocusNode _focusNode = FocusNode();
    // TextEditingController _searchController = TextEditingController();
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: white,
        drawer: MyDrawer(
          accountName: USER_NAME,
          accountRole: USER_ROLE,
          backendRole: BACKEND_ROLE,
          accountEmail: USER_ID.toString(),
          onLogout: () => {logOut(context)},
        ),
        body: Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: getScreenWidth(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    // height: getScreenHeight(900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                                top: getScreenHeight(80),
                                left: getScreenWidth(2),
                                right: getScreenWidth(2)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _scaffoldKey.currentState?.openDrawer();
                                  },
                                  child: Container(
                                    height: getScreenWidth(30),
                                    width: getScreenWidth(30),
                                    decoration: BoxDecoration(
                                      color: loginBgColor,
                                      borderRadius: BorderRadius.circular(
                                          getScreenWidth(15)),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(getScreenWidth(4)),
                                      child: Image.asset(
                                        'assets/images/menu@3x.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                // InkWell(
                                //   onTap: () {
                                //     // Navigator.pushNamed(context, '/mapViewPage');
                                //   },
                                //   child: Container(
                                //     height: 30,
                                //     width: 30,
                                //     decoration: BoxDecoration(
                                //       color: loginBgColor,
                                //       borderRadius:
                                //           BorderRadius.circular(15),
                                //     ),
                                //     child: Padding(
                                //       padding: const EdgeInsets.all(6.0),
                                //       child: Center(
                                //         child: Icon(
                                //           FontAwesomeIcons.bell,
                                //           size: 22,
                                //           color: Colors.black,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                Utils.returnRaiseQueryButton(context)
                              ],
                            )),
                        //dashboard search
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: getScreenWidth(2)),
                          margin: EdgeInsets.only(top: getScreenHeight(30)),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(getScreenWidth(10)),
                              border: Border.all(
                                  width: 0,
                                  color: white,
                                  style: BorderStyle.solid)),
                          child: Container(
                            color: Color.fromRGBO(248, 250, 251, 1),
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: getScreenWidth(10),
                                      vertical: getScreenHeight(10)),
                                  width: getScreenWidth(15),
                                  height: getScreenWidth(15),
                                  decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/search.png'),
                                          fit: BoxFit.fill)),
                                ),
                                Container(
                                  width: getScreenWidth(240),
                                  child: TextFormField(
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    controller: _searchController,
                                    focusNode: _focusNode,
                                    decoration: InputDecoration(
                                        hintText: 'Search',
                                        hintStyle: TextStyle(
                                            fontFamily: ffGMedium,
                                            fontSize: getScreenWidth(14),
                                            color: searchHintTextColor),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: getScreenHeight(15),
                                        ),
                                        border: InputBorder.none),
                                    onChanged: (value) {
                                      // if (value.length >= 8) {
                                      setState(() {
                                        searchValue = value;
                                        searchListData = [];
                                      });
                                      // }
                                    },
                                  ),
                                ),
                                Container(
                                  child: searchValue.length >= 1
                                      ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              Utils.clearToasts(context);
                                              searchData();
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: getScreenWidth(5),
                                                vertical: getScreenHeight(5)),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      getScreenWidth(10))),
                                            ),
                                            child: Text(
                                              "Search",
                                              style: TextStyle(
                                                  fontFamily: ffGSemiBold,
                                                  fontSize: getScreenWidth(12),
                                                  color: whiteBgColor),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: searchListData.length >= 2
                              ? Container(
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: getScreenWidth(5),
                                        vertical: getScreenHeight(5)),
                                    shrinkWrap: true,
                                    itemCount: searchListData.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildProductRow(
                                              searchListData[index]['lrNumber']
                                                  .toString(),
                                              loggedUserRole == 'DEALER'
                                                  ? searchValue
                                                  // searchListData[index]
                                                  //         ['vin']
                                                  //     .toString()
                                                  : searchListData[index]
                                                          ['lrStatus']
                                                      .toString(),
                                              searchListData[index]),
                                          Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal:
                                                      getScreenWidth(15)),
                                              child: searchListData.length == 1
                                                  ? null
                                                  : Divider()),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: getScreenHeight(16)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: getScreenWidth(5)),
                                        child: Text(
                                          loggedUserRole == 'DEALER'
                                              ? 'Search by LR Number, Invoice/DO Number and VIN Number.'
                                              : loggedUserRole == 'CUSTOMER'
                                                  ? 'Search by LR Number, Trip Number and Indent Number.'
                                                  : loggedUserRole ==
                                                              'DRIVER' ||
                                                          loggedUserRole == 'BA'
                                                      ? 'Search by LR Number and Trip Number.'
                                                      : 'Search by LR Number, Invoice Number and DO Number.',
                                          style: TextStyle(
                                              fontSize: getScreenWidth(13),
                                              fontFamily: ffGMediumItalic,
                                              color: hintTextColor),
                                        ),
                                      ),
                                      SizedBox(height: getScreenHeight(16)),
                                      BACKEND_ROLE == 'Supplier' ||
                                              BACKEND_ROLE == 'Buyer'
                                          ? _returnEditIndentCard()
                                          : const SizedBox.shrink(),
                                      Text(
                                        ' Shipment Dashboard',
                                        style: TextStyle(
                                          color: HeadingTextColor,
                                          fontSize: getScreenWidth(14),
                                          fontFamily: ffGSemiBold,
                                        ),
                                      ),
                                      SizedBox(height: getScreenHeight(10)),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  searchListData.length >= 2
                      ? const SizedBox.shrink()
                      : Expanded(
                          child: Scrollbar(
                            thumbVisibility: dashboardArray.isNotEmpty,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  RefreshIndicator(
                                    onRefresh: getDashboardCounts,
                                    color: appThemeColor,
                                    backgroundColor: whiteBgColor,
                                    child: dashboardArray.isEmpty
                                        ? Container(
                                            height: getScreenHeight(300),
                                            child: ListView(
                                              physics:
                                                  AlwaysScrollableScrollPhysics(), // Ensures scroll behavior
                                              children: [],
                                            ),
                                          )
                                        : _returnCountsDisplayCard(),
                                  ),
                                  loggedUserRole == 'CUSTOMER'
                                      ? _returnCreateIndentCard()
                                      : loggedUserRole == "DRIVER"
                                          ? Container(
                                              color: whiteBgColor,
                                              margin: EdgeInsets.only(
                                                  top: getScreenHeight(
                                                      dashboardArray.length > 2
                                                          ? 30
                                                          : 270)),
                                              child: FooterButton('START TRIP',
                                                  'fullWidth', context, () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/tripSheet',
                                                ).then((result) {
                                                  if (result == true) {
                                                    getDashboardCounts();
                                                    setState(() {
                                                      searchValue = '';
                                                      searchListData = [];
                                                      _searchController.clear();
                                                    });
                                                  }
                                                });
                                              }),
                                            )
                                          : SizedBox.shrink()
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            )),
        // floatingActionButton: Stack(
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.only(left: 50),
        //       child: Align(
        //         alignment: Alignment.bottomLeft,
        //         child: ElevatedButton(
        //           onPressed: () {
        //             _showBottomSheet(context);
        //           },
        //           child: Icon(
        //             Icons.add,
        //             color: floatingIconButtonColor,
        //             size: 40,
        //           ),
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: floatingIconButtonBgColor,
        //             shape: CircleBorder(),
        //             padding: EdgeInsets.all(10),
        //           ),
        //         ),
        //       ),
        //     ),
        //     Align(
        //       alignment: Alignment.bottomRight,
        //       child: ElevatedButton(
        //         onPressed: () {},
        //         child: Text(
        //           'SOS',
        //           style: TextStyle(
        //               color: appButtonColor,
        //               fontSize: 16,
        //               fontFamily: ffGSemiBold),
        //         ),
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: floatingButtonBgColor,
        //           shape: CircleBorder(),
        //           padding: EdgeInsets.all(18),
        //           side: BorderSide(
        //             width: 3.0,
        //             color: appButtonColor,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }

  _returnCountsDisplayCard() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      // physics:
      //     AlwaysScrollableScrollPhysics(), // Ensures scrollability
      padding: EdgeInsets.zero,
      itemCount: dashboardArray.length,
      itemBuilder: (context, index) {
        var dashboardCard = dashboardArray[index];
        return Container(
          color: whiteBgColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  if (dashboardCard['count'] != '0') {
                    Utils.clearToasts(context);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(
                        'dashBoardCardStatus', dashboardCard['status']);
                    Navigator.pushNamed(
                      context,
                      loggedUserRole == "DEALER"
                          ? '/tripsPage'
                          : '/pendingTripsList',
                      arguments: {
                        'argumentStatus': dashboardCard['status'],
                      },
                    ).then((result) {
                      if (result == true) {
                        getDashboardCounts();
                        setState(() {
                          searchValue = '';
                          searchListData = [];
                          _searchController.clear();
                        });
                      }
                    });
                  }
                },
                child: _buildDashboardCard(
                  dashboardCard['title'],
                  dashboardCard['subtitle'],
                  dashboardCard['count'],
                  buttonTextBgColor,
                  buttonTextBgColor,
                  '',
                ),
              ),
              SizedBox(height: getScreenHeight(5)),
            ],
          ),
        );
      },
    );
  }

  _returnCreateIndentCard() {
    return Column(
      children: [
        Divider(),
        InkWell(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('Selected_indentId', 00);
            await prefs.setBool('Indent_Editing', true);
            await prefs.setBool('fromDashboardScreen', true);

            Navigator.pushNamed(context, '/creationFirstScreen').then((result) {
              if (result == true) {
                getDashboardCounts();
                setState(() {
                  searchValue = '';
                  searchListData = [];
                  _searchController.clear();
                });
              }
            });
          },
          child: _buildDashboardCard(
              'CREATE INDENT ',
              'All the indents created will be visible in left menu',
              "#123",
              buttonTextBgColor,
              buttonTextBgColor,
              'indent_create'),
        ),
      ],
    );
  }

  _returnEditIndentCard() {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('Selected_indentId', 00);
            await prefs.setBool('Indent_Editing', true);
            await prefs.setBool('fromDashboardScreen', true);

            Navigator.pushNamed(context, '/tripsList').then((result) {
              if (result == true) {
                getDashboardCounts();
                setState(() {
                  searchValue = '';
                  searchListData = [];
                  _searchController.clear();
                });
              }
            });
          },
          child: _buildDashboardCard(
              'EDIT INDENT ',
              'Click here to edit product count',
              "#456",
              buttonTextBgColor,
              buttonTextBgColor,
              'indent_create'),
        ),
        Divider(),
      ],
    );
  }

  Widget _buildProductRow(String productName, String units, totalData) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () async {
        Utils.clearToasts(context);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('tripNumber', totalData['tripNumber']);
        await prefs.setString('tripId', totalData['tripId'].toString());
        Navigator.pushNamed(context, '/tripDetails', arguments: {
          "responseData": totalData,
          "lrNumber": totalData['lrNumber'],
          "fromScreen": 'dashBoard'
        }).then((result) {
          if (result == true) {
            getDashboardCounts();
            setState(() {
              searchValue = '';
              searchListData = [];
              _searchController.clear();
            });
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Icon(
                  Icons.book,
                  size: 18,
                  color: backButtonCircleIconColor,
                )),
            Container(
              width: screenWidth * 0.5,
              child: Text(productName,
                  style: TextStyle(fontFamily: ffGMedium, fontSize: 16)),
            ),
            Text(units, style: TextStyle(fontFamily: ffGMedium, fontSize: 16)),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: backButtonCircleIconColor,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String subtitle, String count,
      Color bgColor, Color borderColor, String fromButton) {
    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getScreenWidth(10)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: getScreenHeight(20),
            bottom: getScreenHeight(20),
            left: getScreenWidth(14),
            right: (fromButton == 'indent_create'
                ? getScreenWidth(30)
                : getScreenWidth(0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: fromButton == 'indent_create'
                  ? getScreenWidth(200)
                  : getScreenWidth(170),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: getScreenWidth(16),
                        fontFamily: ffGSemiBold,
                        color: buttonBorderColor),
                  ),
                  SizedBox(height: getScreenHeight(8)),
                  Container(
                    width: fromButton == 'indent_create'
                        ? getScreenWidth(200)
                        : getScreenWidth(190),
                    child: Text(subtitle,
                        style: TextStyle(
                            fontSize: getScreenWidth(14),
                            height: 1,
                            fontFamily: ffGMediumItalic,
                            color: subHeadingTextColor)),
                  ),
                ],
              ),
            ),
            count == "#123"
                ? Container(
                    width: getScreenWidth(40),
                    height: getScreenWidth(40),
                    child: Image.asset(
                      'assets/images/create_indent.png',
                      fit: BoxFit.fill,
                    ),
                  )
                : count == "#456"
                    ? Container(
                        width: getScreenWidth(40),
                        height: getScreenWidth(40),
                        child: Image.asset(
                          'assets/images/edit_indent.png',
                          fit: BoxFit.fill,
                        ),
                      )
                    // ? Container(
                    //     width: getScreenWidth(60),
                    //     alignment: Alignment.center,
                    //     child: Icon(
                    //       Icons.add,
                    //       color: floatingIconButtonColor,
                    //       size: getScreenWidth(50),
                    //     ),
                    //   )
                    : Container(
                        width: getScreenWidth(150),
                        alignment: Alignment.center,
                        child: Text(
                          count,
                          style: TextStyle(
                              fontSize: getScreenWidth(35),
                              color: appButtonColor,
                              fontFamily: ffGBold),
                        ),
                      )
          ],
        ),
      ),
    );
  }
}

void _navigateTo(BuildContext context, String routeName) {
  Utils.clearToasts(context);
  Navigator.pop(context);
  Navigator.pushNamed(context, routeName);
}

TextStyle drawerItemStyle = TextStyle(
  color: drawerSubListColor,
  fontFamily: ffGMedium,
  fontSize: getScreenWidth(16),
);

class MyDrawer extends StatelessWidget {
  final String accountName;
  final String accountRole;
  final String backendRole;
  final String accountEmail;
  final VoidCallback onLogout;

  MyDrawer({
    required this.accountName,
    required this.accountRole,
    required this.backendRole,
    required this.accountEmail,
    required this.onLogout,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: getScreenWidth(200),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(getScreenWidth(30)),
            bottomRight: Radius.circular(getScreenWidth(30)),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
              vertical: getScreenHeight(50), horizontal: getScreenWidth(20)),
          children: <Widget>[
            Text(
              accountName,
              style: TextStyle(
                color: drawerTitleColor,
                fontFamily: ffGBold,
                fontSize: getScreenWidth(14),
              ),
            ),
            Text(
              // accountEmail,
              // accountRole,
              backendRole,
              style: TextStyle(
                color: drawerTitleColor,
                fontFamily: ffGMedium,
                fontSize: getScreenWidth(12),
              ),
            ),
            Divider(thickness: getScreenHeight(1)),
            SizedBox(
                height: getScreenHeight(
                    15)), // Consistent spacing before the ListTile items
            Container(
              height: getScreenHeight(550),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Home',
                      style: TextStyle(
                        color: appThemeColor,
                        fontFamily: ffGSemiBold,
                        fontSize: getScreenWidth(14),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  accountRole == 'CUSTOMER'
                      ? ListTile(
                          title: Text(
                            'My Indents',
                            style: drawerItemStyle,
                          ),
                          onTap: () {
                            _navigateTo(context, '/tripsList');
                          },
                        )
                      : SizedBox.shrink(),
                  // ListTile(
                  //   title: Text(
                  //     'Drivers & Vehicle List',
                  //     style: drawerItemStyle,
                  //   ),
                  //   onTap: () {
                  //     _navigateTo(context, '/vehicleAndDriversList');
                  //   },
                  // ),
                  // ListTile(
                  //   title: Text(
                  //     'EPOD Download',
                  //     style: drawerItemStyle,
                  //   ),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  // ListTile(
                  //   title: Text(
                  //     'Help Centre',
                  //     style: drawerItemStyle,
                  //   ),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  // ListTile(
                  //   title: Text(
                  //     'Settings',
                  //     style: drawerItemStyle,
                  //   ),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ],
              ),
            ),
            // SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: getScreenWidth(20)),
              child: Divider(thickness: getScreenHeight(1)),
            ),
            InkWell(
              onTap: () {
                // Navigator.pop(context);
                onLogout();
              },
              child: ListTile(
                title: Center(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationThickness: getScreenHeight(1),
                      color: drawerSubListColor,
                      fontFamily: ffGMedium,
                      fontSize: getScreenWidth(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
