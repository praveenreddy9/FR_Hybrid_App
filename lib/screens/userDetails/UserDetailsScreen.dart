import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserDetailsScreen(
      {Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> attendance = [];
  bool isLoading = false; // New: Tracks loading state

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    setState(() {
      isLoading = true;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    var apiURL =
        'https://fr.whizzard.in/attendance?user_id=${widget.userId}&date=$formattedDate';

    print('Fetching attendance from: $apiURL');

    try {
      final response = await http.get(Uri.parse(apiURL),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final mapResponse = json.decode(response.body);
        if (mapResponse["status"] == "success") {
          print('detail ===>${mapResponse['attendance']}');
          setState(() {
            attendance =
                List<Map<String, dynamic>>.from(mapResponse['attendance']);
          });
        }
      } else {
        final mapResponse = json.decode(response.body);
        _showSnackBar(mapResponse['message'], false);
      }
    } catch (e) {
      _showSnackBar("Error fetching attendance", false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      getUserDetails();
    }
  }

  String capitalizeName(String name) {
    return name
        .split(' ') // Split by space
        .map((word) =>
            toBeginningOfSentenceCase(word) ?? '') // Capitalize each word
        .join(' '); // Join back with space
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${capitalizeName(widget.userName)}'s Attendance"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Selected Date:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _selectDate,
                  icon: Icon(Icons.calendar_today, size: 18),
                  label: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child:
                        CircularProgressIndicator()) // New: Show loader while fetching data
                : attendance.isEmpty
                    ? Center(
                        child: Text("No attendance records found",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: attendance.length,
                        itemBuilder: (context, index) {
                          var record = attendance[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                            child: ListTile(
                              leading:
                                  Icon(Icons.access_time, color: Colors.blue),
                              title: Text(
                                "Check-in: ${formatDateTime(record['check_in'])}",
                              ),
                              subtitle: Text(
                                "Check-out: ${formatDateTime(record['check_out'])}\n"
                                "Duration: ${record['shift_time']?.toString() ?? '--'}",
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '--';
    try {
      DateTime parsedDate = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
