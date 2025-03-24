// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import '/model/lr.dart';
// import '/model/response/epod_response.dart'; 
// import '/utility/Constants.dart';
// import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;

// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../model/response/defect_types_response.dart';
// import '../model/response/lr_info_response.dart';
// import '../model/response/pdi_response.dart';
// import '../model/response/record_delivery_response.dart'; 
// import '../utility/check_internet.dart';
// import '../utility/logger.dart';
// import 'config.dart';

// class ApiService {
//   static var stringResponse;

//   static var authtoken;

//   static var mapResponse;

//   // set accesstoken(String? accesstoken) {
//   //   Future<SharedPreferences> prefs =  SharedPreferences.getInstance();
//   //      accesstoken = prefs.getString('accessToken');
//   // }

//   Future<HttpClient> createHttpClientWithCertificate() async {
//     SecurityContext context = SecurityContext.defaultContext;
//     // SecurityContext context = SecurityContext(withTrustedRoots: false);
//     try {
//       // Load the certificate
//       // final certData = await rootBundle.load('assets/certificate/STAR_mlldev_com.crt');  //dev
//       final certData =
//           await rootBundle.load('assets/certificate/STAR_mllqa_com.crt'); //QA
//       context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
//     } catch (e) {
//       print("Error loading certificate: $e");
//       // Handle error
//     }
//     HttpClient client = HttpClient(context: context);
//     return client;
//   }

//   Future getAPI(url, requestBody) async {
//     try {
//       HttpClient client = await ApiService().createHttpClientWithCertificate();
//       final request = await client.postUrl(url);
//       request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? accesstoken = prefs.getString('accessToken');
//       print('accesstoken======>$accesstoken,====>${accesstoken.runtimeType}');
//       request.headers.set("accesstoken", "<accesstoken>");
//       print('common request=====>$request');
//       request.write(jsonEncode(requestBody));
//       final response = await request.close();
//       final responseBody = await response.transform(utf8.decoder).join();
//       stringResponse = responseBody;
//       print('common stringResponse=====>${stringResponse}');

//       final Map<String, dynamic> parsedResponse = jsonDecode(stringResponse);
//       return parsedResponse;
//     } catch (e) {
//       print('Error making common POST request: $e');
//     }
//   }

//   // static Future<LRInfoResponse> getTrips(Map map, String status, TripsViewModel viewModel) async {
//   //   var url = "";
//   //
//   //   if(status == "INTRANSIT") {
//   //     url = BASE_URL + DEALER_INTRANSIT_API;
//   //   }else if(status == "BOOKED") {
//   //     url = BASE_URL + DEALER_BOOKED_API;
//   //   }else if(status == "DELIVERED") {
//   //     url = BASE_URL + DEALER_DELIVERD_API;
//   //   }
//   //
//   //   //encode Map to JSON
//   //   var body = json.encode(map);
//   //
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   var token = prefs.getString('accessToken');
//   //
//   //   var response = await http.get(Uri.parse(url),
//   //       headers: {"Content-Type": "application/json", "accesstoken": '$token'},
//   //       // body: body
//   //   );
//   //
//   //   var res = json.decode(response.body);
//   //   Logger.apiLogging(map, url, response);
//   //   LRInfoResponse result = LRInfoResponse.fromMap(res);
//   //
//   //   Logger.apiLogging(map, url, response);
//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     // viewModel.setResponse(result);
//   //   }
//   //
//   //   return result;
//   // }

//   // static Future<RecordDeliveryResponse> getRecordDelivery(Map map, RecordDeliveryViewModel viewModel) async {
//   //   var url = BASE_URL + DEALER_RECORD_DELIVERY_API;
//   //   //encode Map to JSON
//   //   var body = json.encode(map);
//   //
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   var token = prefs.getString('accessToken');
//   //
//   //   var response = await http.post(Uri.parse(url),
//   //     headers: {"Content-Type": "application/json", "accesstoken": '$token'},
//   //     body: body
//   //   );
//   //
//   //   var res = json.decode(response.body);
//   //   RecordDeliveryResponse result = RecordDeliveryResponse.fromMap(res);
//   //
//   //   Logger.apiLogging(map, url, response);
//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     // viewModel.setResponse(result);
//   //   }
//   //
//   //   return result;
//   // }

//   // static Future<DefectTypesResponse> getDefectTypes(Map map, PDIViewModel viewModel) async {
//   //   var url = BASE_URL + DEALER_DEFECT_TYPE_API;
//   //   //encode Map to JSON
//   //   var body = json.encode(map);
//   //
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   var token = prefs.getString('accessToken');
//   //
//   //   var response = await http.get(Uri.parse(url),
//   //       headers: {"Content-Type": "application/json", "accesstoken": '$token'},
//   //       // body: body
//   //   );
//   //
//   //   var res = json.decode(response.body);
//   //   Logger.apiLogging(map, url, response);
//   //   DefectTypesResponse result = DefectTypesResponse.fromMap(res);
//   //
//   //   Logger.apiLogging(map, url, response);
//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     // viewModel.setResponse(result);
//   //   }
//   //
//   //   return result;
//   // }

//   // static Future<EPODResponse> getEpod(Map map, EPODViewModel viewModel) async {
//   //   var url = BASE_URL + DEALER_EPOD_IMAGE_API;
//   //   //encode Map to JSON
//   //   var body = json.encode(map);
//   //
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   var token = prefs.getString('accessToken');
//   //
//   //   var response = await http.post(Uri.parse(url),
//   //     headers: {"Content-Type": "application/json", "accesstoken": '$token'},
//   //     body: body
//   //   );
//   //
//   //   var res = json.decode(response.body);
//   //   EPODResponse result = EPODResponse.fromMap(res);
//   //
//   //   Logger.apiLogging(map, url, response);
//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     // viewModel.setResponse(result);
//   //   }
//   //
//   //   return result;
//   // }

//   // static Future<DefectTypesResponse> submitPDI(Map map, PDIViewModel viewModel) async {
//   //   var url = BASE_URL + DEALER_EPOD_UPDATE_API;
//   //   //encode Map to JSON
//   //   var body = json.encode(map);
//   //
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   var token = prefs.getString('accessToken');
//   //
//   //   var response = await http.post(Uri.parse(url),
//   //     headers: {"Content-Type": "application/json", "accesstoken": '$token'},
//   //     body: body
//   //   );
//   //
//   //   var res = json.decode(response.body);
//   //   Logger.apiLogging(map, url, response);
//   //   DefectTypesResponse result = DefectTypesResponse.fromMap(res);
//   //
//   //   Logger.apiLogging(map, url, response);
//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     // viewModel.setResponse(result);
//   //   }
//   //
//   //   return result;
//   // }

//   // static Future<DefectTypesResponse> savePDI(Map map, DefectTypeViewModel viewModel) async {
//   //   var url = BASE_URL + DEALER_EPOD_UPDATE_API;
//   //   //encode Map to JSON
//   //   var body = json.encode(map);
//   //
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   var token = prefs.getString('accessToken');
//   //
//   //   var response = await http.post(Uri.parse(url),
//   //       headers: {"Content-Type": "application/json", "accesstoken": '$token'},
//   //       body: body
//   //   );
//   //
//   //   var res = json.decode(response.body);
//   //   Logger.apiLogging(map, url, response);
//   //   DefectTypesResponse result = DefectTypesResponse.fromMap(res);
//   //
//   //   Logger.apiLogging(map, url, response);
//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     // viewModel.setResponse(result);
//   //   }
//   //
//   //   return result;
//   // }

//   // static Future<EPODResponse> confirmEPOD(Map map, EPODViewModel viewModel) async {
//   //   var url = BASE_URL + DEALER_EPOD_CONFIRM_API;
//   //   //encode Map to JSON
//   //   var body = json.encode(map);
//   //
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   var token = prefs.getString('accessToken');
//   //
//   //   var response = await http.post(Uri.parse(url),
//   //       headers: {"Content-Type": "application/json", "accesstoken": '$token'},
//   //       body: body
//   //   );
//   //
//   //   var res = json.decode(response.body);
//   //   Logger.apiLogging(map, url, response);
//   //   EPODResponse result = EPODResponse.fromMap(res);
//   //
//   //   Logger.apiLogging(map, url, response);
//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     // viewModel.setResponse(result);
//   //   }
//   //
//   //   return result;
//   // }

//   // static Future<LRInfoResponse> getPDF(Map map, ViewLRViewModel viewModel, String lrNumber) async {
//   //   var url = BASE_URL + DEALER_PDF_DOWNLOAD_API+lrNumber;
//   //   //encode Map to JSON
//   //   var body = json.encode(map);
//   //
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   var token = prefs.getString('accessToken');
//   //
//   //   var response = await http.get(Uri.parse(url),
//   //     headers: {"Content-Type": "application/json", "accesstoken": '$token'},
//   //     // body: body
//   //   );
//   //
//   //   var res = json.decode(response.body);
//   //   LRInfoResponse result = LRInfoResponse.fromMap(res);
//   //
//   //   Logger.apiLogging(map, url, response);
//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     // viewModel.setResponse(result);
//   //   }
//   //
//   //   return result;
//   // }

//   // static Future<PDIResponse> getProductDetails(Map map, PDIViewModel viewModel) async {
//   //   var url = BASE_URL + DEALER_SEARCH_PDI_API;
//   //   //encode Map to JSON
//   //   var body = json.encode(map);
//   //
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   var token = prefs.getString('accessToken');
//   //
//   //   var response = await http.post(Uri.parse(url),
//   //       headers: {"Content-Type": "application/json", "accesstoken": '$token'},
//   //       body: body
//   //   );
//   //
//   //   var res = json.decode(response.body);
//   //   Logger.apiLogging(map, url, response);
//   //   PDIResponse result = PDIResponse.fromMap(res);
//   //
//   //   Logger.apiLogging(map, url, response);
//   //   if (response.statusCode == 201 || response.statusCode == 200) {
//   //     // viewModel.setResponse(result);
//   //   }
//   //
//   //   return result;
//   // }

//   static Future<LRInfoResponse> getTrips(
//       Map map, String status, TripsViewModel viewModel) async {
//     var url = "";

//     if (status == "INTRANSIT") {
//       url = DEALER_INTRANSIT_API;
//     } else if (status == "BOOKED") {
//       url = DEALER_BOOKED_API;
//     } else if (status == "DELIVERED") {
//       url = DEALER_DELIVERD_API;
//     } else if (status == "PENDING_PDI") {
//       url = DEALER_PENDING_PDI_API;
//     }

//     LRInfoResponse result = await requestApiCall<LRInfoResponse>(
//         url, "GET", map,
//         fromMap: (json) => LRInfoResponse.fromMap(json));
//     // viewModel.setResponse(result);
//     return result;
//   }

//   static Future<RecordDeliveryResponse> getRecordDelivery(
//       Map map, RecordDeliveryViewModel viewModel) async {
//     var url = DEALER_RECORD_DELIVERY_API;

//     RecordDeliveryResponse result =
//         await requestApiCall<RecordDeliveryResponse>(url, "POST", map,
//             fromMap: (json) => RecordDeliveryResponse.fromMap(json));

//     return result;
//   }

//   static Future<DefectTypesResponse> getDefectTypes(
//       Map map, PDIViewModel viewModel) async {
//     var url = DEALER_DEFECT_TYPE_API;

//     DefectTypesResponse result = await requestApiCall<DefectTypesResponse>(
//         url, "GET", map,
//         fromMap: (json) => DefectTypesResponse.fromMap(json));

//     return result;
//   }

//   static Future<EPODResponse> getEpod(Map map, EPODViewModel viewModel) async {
//     var url = DEALER_EPOD_IMAGE_API;

//     EPODResponse result = await requestApiCall<EPODResponse>(url, "POST", map,
//         fromMap: (json) => EPODResponse.fromMap(json));

//     return result;
//   }

//   static Future<DefectTypesResponse> submitPDI(
//       Map map, PDIViewModel viewModel) async {
//     var url = DEALER_EPOD_UPDATE_API;

//     DefectTypesResponse result = await requestApiCall<DefectTypesResponse>(
//         url, "POST", map,
//         fromMap: (json) => DefectTypesResponse.fromMap(json));

//     return result;
//   }

//   static Future<DefectTypesResponse> savePDI(
//       Map map, DefectTypeViewModel viewModel) async {
//     var url = DEALER_EPOD_UPDATE_API;

//     DefectTypesResponse result = await requestApiCall<DefectTypesResponse>(
//         url, "POST", map,
//         fromMap: (json) => DefectTypesResponse.fromMap(json));

//     return result;
//   }

//   static Future<EPODResponse> confirmEPOD(
//       Map map, EPODViewModel viewModel) async {
//     var url = DEALER_EPOD_CONFIRM_API;

//     EPODResponse result = await requestApiCall<EPODResponse>(url, "POST", map,
//         fromMap: (json) => EPODResponse.fromMap(json));

//     return result;
//   }

//   static Future<PDIResponse> getProductDetails(
//       Map map, PDIViewModel viewModel) async {
//     var url = DEALER_SEARCH_PDI_API;

//     PDIResponse result = await requestApiCall<PDIResponse>(url, "POST", map,
//         fromMap: (json) => PDIResponse.fromMap(json));

//     return result;
//   }

//   static Future<EPODResponse> uploadSignature(Map map, File file, String key,
//       String lrNumber, SignatureViewModel viewModel) async {
//     var url = BASE_URL + DEALER_EPOD_SIGNATURE_API;
//     //encode Map to JSON
//     var body = json.encode(map);

//     String filename = "image.jpeg";
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var token = prefs.getString('accessToken');
//     var savedCookies = prefs.getString('savedCookies');

//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse(url),
//     );
//     Map<String, String> headers = {
//       "Content-Type": "application/json",
//       "accesstoken": '$token',
//       "Authorization": '$token',
//       "Cookie": '$savedCookies'
//     };
//     request.files.add(
//       http.MultipartFile(
//         'file',
//         file.readAsBytes().asStream(),
//         file.lengthSync(),
//         filename: filename,
//       ),
//     );
//     request.headers.addAll(headers);
//     request.fields.addAll({
//       "lrNumber": lrNumber,
//       "label": key,
//     });

//     var send = await request.send();
//     var response = await http.Response.fromStream(send);

//     var res = json.decode(response.body);
//     Logger.apiLogging(map, url, response);
//     EPODResponse result = EPODResponse.fromMap(res);

//     if (response.statusCode == 201 || response.statusCode == 200) {
//       // viewModel.setResponse(result);
//     }

//     return result;
//   }

//   static Future<DefectTypesResponse> uploadDefectImage(Map map, File file,
//       String lrNumber, DefectTypeViewModel viewModel) async {
//     var url = BASE_URL + DEALER_EPOD_DEFECT_IMAGE_API;
//     //encode Map to JSON
//     var body = json.encode(map);

//     String filename = "image.jpeg";
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var token = prefs.getString('accessToken');
//     var savedCookies = prefs.getString('savedCookies');

//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse(url),
//     );
//     Map<String, String> headers = {
//       "Content-Type": "application/json",
//       "accesstoken": '$token',
//       "Authorization": '$token',
//       "Cookie": '$savedCookies'
//     };
//     request.files.add(
//       http.MultipartFile(
//         'file',
//         file.readAsBytes().asStream(),
//         file.lengthSync(),
//         filename: filename,
//       ),
//     );
//     request.headers.addAll(headers);
//     request.fields.addAll({
//       "LRNumber": lrNumber,
//     });

//     var send = await request.send();
//     var response = await http.Response.fromStream(send);

//     var res = json.decode(response.body);
//     Logger.apiLogging(map, url, response);
//     DefectTypesResponse result = DefectTypesResponse.fromMap(res);

//     if (response.statusCode == 201 || response.statusCode == 200) {
//       // viewModel.setResponse(result);
//     }

//     return result;
//   }

//   static Future<DefectTypesResponse> uploadDefectImageInbound(
//       Map map, File file, String lrNumber, PDIViewModel viewModel) async {
//     var url = BASE_URL + DEALER_EPOD_DEFECT_IMAGE_API;
//     //encode Map to JSON
//     var body = json.encode(map);

//     String filename = "image.jpeg";
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var token = prefs.getString('accessToken');
//     var savedCookies = prefs.getString('savedCookies');

//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse(url),
//     );
//     Map<String, String> headers = {
//       "Content-Type": "application/json",
//       "accesstoken": '$token',
//       "Authorization": '$token',
//       "Cookie": '$savedCookies'
//     };
//     request.files.add(
//       http.MultipartFile(
//         'file',
//         file.readAsBytes().asStream(),
//         file.lengthSync(),
//         filename: filename,
//       ),
//     );
//     request.headers.addAll(headers);
//     request.fields.addAll({
//       "LRNumber": lrNumber,
//     });

//     var send = await request.send();
//     var response = await http.Response.fromStream(send);

//     var res = json.decode(response.body);
//     Logger.apiLogging(map, url, response);
//     DefectTypesResponse result = DefectTypesResponse.fromMap(res);

//     if (response.statusCode == 201 || response.statusCode == 200) {
//       // viewModel.setResponse(result);
//     }

//     return result;
//   }

//   static requestApiCall<T>(String endpoint, String method, Map request,
//       {required T Function(Map<String, dynamic>) fromMap}) async {
//     bool status = await CheckInternet.isInternet();
//     if (!status) {
//       return fromMap({'error': 'No Internet Connection'});
//     }

//     final url = BASE_URL + endpoint;
//     final body = json.encode(request);

//     // Retrieve token
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//     final savedCookies = prefs.getString('savedCookies') ?? '';

//     // Prepare headers
//     final headers = {
//       "Content-Type": "application/json",
//       "accesstoken": token,
//       "Authorization": '$token',
//       "Cookie": '$savedCookies'
//     };

//     try {
//       // Perform HTTP POST
//       final http.Response response;
//       switch (method.toUpperCase()) {
//         case "GET":
//           response = await http
//               .get(Uri.parse(url), headers: headers)
//               .timeout(const Duration(seconds: 15));
//           break;
//         case "POST":
//           response = await http
//               .post(Uri.parse(url), headers: headers, body: body)
//               .timeout(const Duration(seconds: 15));
//           break;
//         case "PUT":
//           response = await http
//               .put(Uri.parse(url), headers: headers, body: body)
//               .timeout(const Duration(seconds: 15));
//           break;
//         case "DELETE":
//           response = await http
//               .delete(Uri.parse(url), headers: headers)
//               .timeout(const Duration(seconds: 15));
//           break;
//         default:
//           return fromMap({'error': 'HTTP method $method is not supported'});
//       }

//       // Log API request and response
//       Logger.apiLogging(request, url, response);

//       // Handle response
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var jsonResponse = json.decode(response.body);
//         return fromMap(jsonResponse);
//       } else {
//         // Handle non-successful status codes
//         return fromMap({
//           'error':
//               'API call failed: ${response.statusCode} - ${response.reasonPhrase}'
//         });
//       }
//     } on TimeoutException catch (e) {
//       // Handles Timeout failures
//       return fromMap({'error': 'Timeout Error: ${e.message}'});
//     } on SocketException catch (e) {
//       // Handles SSL/TLS issues like certificate validation failures
//       return fromMap({'error': 'SocketException: SSL/TLS Error: ${e.message}'});
//     } on HandshakeException catch (e) {
//       // This can be triggered for SSL handshake failures
//       return fromMap(
//           {'error': 'HandshakeException: SSL Handshake error: ${e.message}'});
//     } catch (e) {
//       // Handles other types of errors
//       return fromMap({'error': 'Unexpected error: $e'});
//     }
//   }

//   // static requestApiCall<T>( String endpoint, String method, Map request, {required T Function(Map<String, dynamic>) fromMap}) async {
//   //
//   //   bool status = await CheckInternet.isInternet();
//   //   if(!status){
//   //     return fromMap({'error' : 'No Internet Connection'});
//   //   }
//   //
//   //   final url = BASE_URL + endpoint;
//   //   final body = json.encode(request);
//   //
//   //   // Retrieve token
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   final token = prefs.getString('accessToken') ?? '';
//   //
//   //   // Prepare headers
//   //   final headers = {
//   //     "Content-Type": "application/json",
//   //     "accesstoken": token,
//   //   };
//   //
//   //   try {
//   //     // Perform DIO CALL
//   //     Dio dio = Dio();
//   //     dio.options.headers['Content-Type'] = 'application/json';
//   //     dio.options.headers["accesstoken"] = token;
//   //     Response response;
//   //     switch (method.toUpperCase()) {
//   //       case "GET":
//   //         response = await dio
//   //             .getUri(Uri.parse(url))
//   //             .timeout(const Duration(seconds: 15));
//   //         break;
//   //       case "POST":
//   //         response = await dio
//   //             .postUri(Uri.parse(url), data: body)
//   //             .timeout(const Duration(seconds: 15));
//   //       case "PUT":
//   //         response = await dio
//   //             .putUri(Uri.parse(url), data: body)
//   //             .timeout(const Duration(seconds: 15));
//   //       case "DELETE":
//   //         response = await dio
//   //             .deleteUri(Uri.parse(url), data: body)
//   //             .timeout(const Duration(seconds: 15));
//   //         break;
//   //       default:
//   //         return fromMap({'error' : 'HTTP method $method is not supported'});
//   //     }
//   //
//   //     // Log API request and response
//   //     Logger.apiLoggingMap(request, url, response);
//   //
//   //
//   //     // Handle response
//   //     if (response.statusCode == 200 || response.statusCode == 201) {
//   //       var jsonResponse = json.decode(response.toString());
//   //       return fromMap(jsonResponse);
//   //     } else {
//   //       // Handle non-successful status codes
//   //       return fromMap({'error' : 'API call failed: ${response.statusCode} - ${response.toString()}'});
//   //     }
//   //   }on TimeoutException catch (e) {
//   //     // Handles Timeout failures
//   //     return fromMap({'error' : 'Timeout Error: ${e.message}'});
//   //   } on SocketException catch (e) {
//   //     // Handles SSL/TLS issues like certificate validation failures
//   //     return fromMap({'error' : 'SocketException: SSL/TLS Error: ${e.message}'});
//   //   } on HandshakeException catch (e) {
//   //     // This can be triggered for SSL handshake failures
//   //     return fromMap({'error' : 'HandshakeException: SSL Handshake error: ${e.message}'});
//   //   } catch (e) {
//   //     // Handles other types of errors
//   //     return fromMap({'error' : 'Unexpected error: $e'});
//   //   }
//   // }
// }









// //=========>to check cerificate is valid or not
//  // HttpClient client = await createHttpClientWithCertificate();
//     // final request = await client
//     //     // .getUrl(Uri.parse('https://dealerportal.mllqa.com'));
//     //     .getUrl(Uri.parse('https://logifreightapp.mahindralogistics.com'));
//     // // .getUrl(Uri.parse('https://safetyapi.mahindralogistics.com'));
//     // // .getUrl(Uri.parse('https://dealerportal.mllqa.com'));
//     // // .getUrl(Uri.parse('http://testing.whizzard.in'));
//     // final response = await request.close();
//     // print('check resp \\\\\\\\====> ${response.statusCode}');

//     //  await ApiService.certificateCheck();