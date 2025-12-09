import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> adminData = {
    'email': '',
    'password': '',
    'totalVisitors': 0,
  };

  bool showPass = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Load admin info from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString('admin');

      if (data != null) {
        final parsed = jsonDecode(data);
        setState(() {
          adminData['email'] = parsed['email'] ?? '';
          adminData['password'] = parsed['password'] ?? '';
        });
      }

      // Fetch total visitors from API
      final res = await http.get(Uri.parse('http://16.171.188.189:3000/api/visitors/total'));
      final result = jsonDecode(res.body);
      if (result['success'] == true) {
        setState(() {
          adminData['totalVisitors'] = result['total'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login'); // Adjust route name if needed
  }

  Widget renderRow(String title, dynamic value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value.toString(), style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = adminData['email'] != ''
        ? adminData['email'].split("@")[0]
        : 'admin';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: EdgeInsets.symmetric(vertical: 35),
              alignment: Alignment.center,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: AssetImage('assets/k.jpg'), // Make sure you have this image
                  ),
                  SizedBox(height: 15),
                  Text("Admin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("@$username", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),

            // DETAILS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  renderRow("Email", adminData['email']),
                  renderRow("Total Visitors", adminData['totalVisitors']),

                  // PASSWORD
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Text(
                              showPass ? adminData['password'] : "********",
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => showPass = !showPass),
                              child: Icon(Icons.remove_red_eye, size: 22),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // LOGOUT
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: handleLogout,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.red)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Log out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red)),
                          Icon(Icons.arrow_forward_ios, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
