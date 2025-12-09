import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  List<dynamic> visitors = [];
  String searchText = '';

  Map<String, dynamic> loggedUser = {};

  @override
  void initState() {
    super.initState();
    loadUserAndFetch();   // fixed function
  }

  /// 🟢 FIX: user load होने के बाद ही visitors fetch होंगे
  Future<void> loadUserAndFetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString("user");

    if (userString != null) {
      loggedUser = jsonDecode(userString);
    }

    /// now fetch visitors
    await fetchVisitors();
  }

  Future<void> fetchVisitors() async {
    if (loggedUser.isEmpty) return;

    try {
      final userId = loggedUser["id"];
      final url =
          "http://16.171.188.189:3000/api/visitors/user/$userId";

      print("FETCHING: $url");

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          visitors = data["visitors"] ?? [];
        });
      }
    } catch (e) {
      print("FETCH ERROR: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load visitors")));
    }
  }

  List<dynamic> get filteredVisitors {
    return visitors
        .where((v) => v['name']
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();
  }

  Future<void> exportVisitors(List<dynamic> data) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Visitors'];

      sheet.appendRow([
        'Name',
        'Email',
        'Phone',
        'Company',
        'Remark',
        'CreatedAt',
        'UserID',
        'Event',
        'Requirement',
        'Address'
      ]);

      for (var v in data) {
        sheet.appendRow([
          v['name'] ?? '',
          v['email'] ?? '',
          v['phone'] ?? '',
          v['company'] ?? '',
          v['designation'] ?? '',
          v['created_at'] ?? '',
          loggedUser['id'] ?? '',
          v['program'] ?? '',
          v['requirement'] ?? '',
          v['address'] ?? ''
        ]);
      }

      var dir = await getTemporaryDirectory();
      String filePath = '${dir.path}/visitors_export.xlsx';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      await Share.shareXFiles([XFile(filePath)],
          text: 'Here is the visitor data in Excel format.');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Export failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text("Visitors"),
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "🔍 Search by name...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => searchText = val),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => exportVisitors(visitors),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF0B820),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text("📁 Export & Share Excel",
                  style: TextStyle(color: Colors.white)),
            ),

            SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: filteredVisitors.length,
                itemBuilder: (c, i) {
                  final v = filteredVisitors[i];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${v['name']}",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text("Event: ${v['program']}"),
                            Text("📧 ${v['email']}"),
                            Text("📞 ${v['phone']}"),
                            Text("Requirement: ${v['requirement']}"),
                            Text("Address: ${v['address']}"),
                          ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
