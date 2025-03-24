import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:facial_attendance/utility/FooterButton.dart';
import '../../utility/Utils.dart';
import '../userDetails/UserDetailsScreen.dart';
import '/utility/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utility/Colors.dart';
import '/model/request/LoginRequest.dart';
import 'package:http/http.dart' as http;

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUsersList();
    searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users
          .where((user) => user['user_name'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> getUsersList() async {
    http.Response response;
    var apiURL = 'https://fr.whizzard.in/users';

    try {
      response = await http.get(Uri.parse(apiURL),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final mapResponse = json.decode(response.body);
        if (mapResponse["status"] == "success") {
          print('resp====>${mapResponse['users']}');
          setState(() {
            users = List<Map<String, dynamic>>.from(mapResponse['users']);
            filteredUsers = users;
          });
        }
      } else {
        final mapResponse = json.decode(response.body);
        _showSnackBar(mapResponse['message'], context, false);
      }
    } catch (e) {
      _showSnackBar("Error fetching users", context, false);
    }
  }

  Future<void> getUserDetails(userId) async {
    http.Response response;
    var apiURL =
        'https://fr.whizzard.in/attendance?user_id=${userId}&date=2025-02-28';

    print('apiURL====>${apiURL}');

    try {
      response = await http.get(Uri.parse(apiURL),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final mapResponse = json.decode(response.body);
        if (mapResponse["status"] == "success") {
          print('resp====>${mapResponse}');
        }
      } else {
        final mapResponse = json.decode(response.body);
        _showSnackBar(mapResponse['message'], context, false);
      }
    } catch (e) {
      _showSnackBar("Error fetching users", context, false);
    }
  }

  void _showSnackBar(String message, BuildContext context, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User List")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Users",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredUsers[index]['user_name']),
                  leading: CircleAvatar(
                    child: Text(filteredUsers[index]['user_name'][0]),
                  ),
                  onTap: () {
                    print('selectd user===${filteredUsers[index]}');
                    // getUserDetails(filteredUsers[index]['id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(
                            userId: filteredUsers[index]['id'],
                            userName: filteredUsers[index]['user_name']),
                      ),
                    );
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //       content: Text(
                    //           "Selected: ${filteredUsers[index]['user_name']} (ID: ${filteredUsers[index]['id']})")),
                    // );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
