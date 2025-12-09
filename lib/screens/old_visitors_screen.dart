import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OldVisitorsScreen extends StatefulWidget {
  const OldVisitorsScreen({Key? key}) : super(key: key);

  @override
  _OldVisitorsScreenState createState() => _OldVisitorsScreenState();
}

class _OldVisitorsScreenState extends State<OldVisitorsScreen> {
  List<Map<String, dynamic>> oldVisitors = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchOldVisitors();
  }

  Future<void> fetchOldVisitors() async {
    try {
      setState(() => loading = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedUser = prefs.getString("user");
      final user = storedUser != null ? jsonDecode(storedUser) : null;

      if (user == null || user['id'] == null) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("User not logged in")));
        return;
      }

      final res = await http
          .get(Uri.parse("http://16.171.188.189:3000/api/visitors/old/${user['id']}"));
      final data = jsonDecode(res.body);

      final visitors = (data['oldVisitors'] ?? []).map<Map<String, dynamic>>((v) {
        return {...v, 'seen': false};
      }).toList();

      final clearedKey = "clearedVisitors_${user['id']}";
      final cleared = prefs.getString(clearedKey);
      final clearedIds = cleared != null ? jsonDecode(cleared) : [];

      final filteredVisitors =
          visitors.where((v) => !clearedIds.contains(v['idvisitors'])).toList();

      setState(() => oldVisitors = filteredVisitors);
    } catch (e) {
      print("Error fetching old visitors: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to fetch old visitors")));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> handleFollowUp(int visitorId, String visitorName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    final user = storedUser != null ? jsonDecode(storedUser) : null;
    if (user == null || user['id'] == null) return;

    final clearedKey = "clearedVisitors_${user['id']}";
    final cleared = prefs.getString(clearedKey);
    final clearedIds = cleared != null ? jsonDecode(cleared) : [];

    final newCleared = [...clearedIds, visitorId];
    await prefs.setString(clearedKey, jsonEncode(newCleared));

    setState(() {
      oldVisitors.removeWhere((v) => v['idvisitors'] == visitorId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Follow-up marked for $visitorName")),
    );
  }

  Future<void> clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear All"),
        content: const Text("Are you sure you want to clear all notifications?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Clear All")),
        ],
      ),
    );

    if (confirm != true) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString("user");
    final user = storedUser != null ? jsonDecode(storedUser) : null;
    if (user == null || user['id'] == null) return;

    final clearedKey = "clearedVisitors_${user['id']}";
    final allIds = oldVisitors.map((v) => v['idvisitors']).toList();
    await prefs.setString(clearedKey, jsonEncode(allIds));

    setState(() => oldVisitors.clear());
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Old Visitors")),
      body: oldVisitors.isEmpty
          ? const Center(child: Text("No old visitors found."))
          : Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: clearAll,
                      child: const Text("Clear All"),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: oldVisitors.length,
                    itemBuilder: (_, index) {
                      final item = oldVisitors[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("Email: ${item['email'] ?? ''}"),
                              Text("Phone: ${item['phone'] ?? ''}"),
                              Text("Company: ${item['company'] ?? ''}"),
                              Text("Designation: ${item['designation'] ?? ''}"),
                              Text("Program: ${item['program'] ?? ''}"),
                              Text("Requirement: ${item['requirement'] ?? ''}"),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => handleFollowUp(item['idvisitors'], item['name']),
                                child: const Text("Did you follow up?"),
                              ),
                            ],
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
}
