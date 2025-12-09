import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart'; // For sharing the Excel file

class AdminVisitor extends StatefulWidget {
  final Function(String route)? onNavigate; // <-- add this
  const AdminVisitor({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<AdminVisitor> createState() => _AdminVisitorState();
}

class _AdminVisitorState extends State<AdminVisitor> {
  List visitors = [];
  List filteredVisitors = [];
  List users = [];
  String searchText = '';
  String selectedUser = 'all';
  bool showUserList = false;

  List selectedVisitors = [];
  bool selectionMode = false;
  bool selectAll = false;

  final String BASE_URL = 'http://16.171.188.189:3000/api/visitors';

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchVisitors();
  }

  Future<void> fetchUsers() async {
    try {
      final res = await http.get(Uri.parse('$BASE_URL/fetch'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          users = data['users'] ?? [];
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> fetchVisitors() async {
    try {
      final res = await http.get(Uri.parse('$BASE_URL/allvisitor'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          visitors = data['visitors'] ?? [];
        });
        applyFilters();
      }
    } catch (e) {
      print('Error fetching visitors: $e');
    }
  }

  void applyFilters() {
    List temp = [...visitors];
    if (selectedUser != 'all') {
      temp = temp.where((v) => v['user_id'].toString() == selectedUser.toString()).toList();
    }
    temp = temp.where((v) => v['name'].toString().toLowerCase().contains(searchText.toLowerCase())).toList();
    setState(() {
      filteredVisitors = temp;
    });
  }

  void toggleSelection(int id) {
    setState(() {
      if (selectedVisitors.contains(id)) {
        selectedVisitors.remove(id);
      } else {
        selectedVisitors.add(id);
      }
      selectionMode = selectedVisitors.isNotEmpty;
      selectAll = selectedVisitors.length == filteredVisitors.length;
    });
  }

  void toggleSelectAll() {
    setState(() {
      if (selectAll) {
        selectedVisitors = [];
        selectionMode = false;
        selectAll = false;
      } else {
        selectedVisitors = filteredVisitors.map((v) => v['idvisitors']).toList();
        selectionMode = true;
        selectAll = true;
      }
    });
  }

  Future<void> deleteSelected() async {
    try {
      for (var id in selectedVisitors) {
        await http.delete(Uri.parse('$BASE_URL/$id'));
      }
      setState(() {
        visitors.removeWhere((v) => selectedVisitors.contains(v['idvisitors']));
        selectedVisitors = [];
        selectionMode = false;
        selectAll = false;
        applyFilters();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected visitors deleted'))
      );
    } catch (e) {
      print('Error deleting visitors: $e');
    }
  }

  // Export and share Excel
  Future<void> exportAndShareExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Visitors'];
      sheet.appendRow([
        'Name','Email','Phone','Company','Remark','Event','UserID','CreatedAt','Requirement','Address'
      ]);

      for (var v in filteredVisitors) {
        sheet.appendRow([
          v['name'], v['email'], v['phone'], v['company'], v['designation'], v['program'],
          v['user_id'], v['created_at'], v['requirement'], v['address']
        ]);
      }

      // Save in app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/admin_visitors.xlsx";
      final fileBytes = excel.encode();

      if (fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate Excel'))
        );
        return;
      }

      final file = File(path);
      await file.writeAsBytes(fileBytes, flush: true);

      // Share the file
      await Share.shareXFiles([XFile(path)], text: "Here is the visitors list!");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel exported and ready to share!'))
      );

      print('Excel exported to: $path');
    } catch (e) {
      print('Error exporting Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error exporting Excel'))
      );
    }
  }

  Widget buildVisitorCard(Map v) {
    bool isSelected = selectedVisitors.contains(v['idvisitors']);
    return GestureDetector(
      onLongPress: () => toggleSelection(v['idvisitors']),
      onTap: selectionMode ? () => toggleSelection(v['idvisitors']) : null,
      child: Card(
        color: isSelected ? Colors.blue[100] : Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(v['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
              Text('Event: ${v['program']}'),
              Text('Email: ${v['email']}'),
              Text('Phone: ${v['phone']}'),
              Text('Address: ${v['address']}'),
              Text('User ID: ${v['user_id']}'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Visitors')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search visitors',
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) { searchText = val; applyFilters(); },
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () { setState(() { showUserList = !showUserList; }); },
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Text(selectedUser == 'all' ? 'All Users' : 'User: $selectedUser'),
              ),
            ),
            if (showUserList)
              Container(
                color: Colors.white,
                height: 150,
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('All Users'),
                      onTap: () { setState(() { selectedUser='all'; showUserList=false; applyFilters(); }); },
                    ),
                    ...users.map((u) => ListTile(
                      title: Text('${u['name']} (${u['email']})'),
                      onTap: () { setState(() { selectedUser=u['id'].toString(); showUserList=false; applyFilters(); }); },
                    ))
                  ],
                ),
              ),
            const SizedBox(height: 10),
            if (selectionMode)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: toggleSelectAll,
                      child: Text(selectAll ? 'Deselect All' : 'Select All')
                    )
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: deleteSelected,
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                      child: const Text('Delete Selected')
                    )
                  ),
                ],
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: exportAndShareExcel,
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),
              child: const Text('Export & Share Excel')
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredVisitors.length,
                itemBuilder: (context, index) => buildVisitorCard(filteredVisitors[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
