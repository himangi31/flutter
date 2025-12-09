import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManualEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? routeParams;

  const ManualEntryScreen({this.routeParams, Key? key}) : super(key: key);

  @override
  _ManualEntryScreenState createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? ocrText;
  List<dynamic> programs = [];
  dynamic selectedProgram;

  final List<Map<String, dynamic>> requirements = [
    {'id': 1, 'name': 'UPS'},
    {'id': 2, 'name': 'Li-Ion battery'},
    {'id': 3, 'name': 'BESS'},
    {'id': 4, 'name': 'Solar Transformer'},
    {'id': 5, 'name': 'Others'},
  ];
  dynamic selectedRequirement;

  Map<String, dynamic>? loggedUser;

  @override
  void initState() {
    super.initState();
    loadLoggedUser();
    fetchPrograms();
    prefillFields();
  }

  void prefillFields() {
    if (widget.routeParams != null) {
      final params = widget.routeParams!;
      nameController.text = params['name'] ?? '';
      emailController.text = params['email'] ?? '';
      phoneController.text = params['phone'] ?? '';
      companyController.text = params['company'] ?? '';
      designationController.text = params['designation'] ?? '';
      addressController.text = params['address'] ?? '';
      ocrText = params['scannedText'];
      if (params['program'] != null) selectedProgram = {'name': params['program']};
    }
  }

  Future<void> loadLoggedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('user');
    if (storedUser != null) {
      setState(() {
        loggedUser = jsonDecode(storedUser);
      });
    }
  }

  Future<void> fetchPrograms() async {
    try {
      final res = await http.get(Uri.parse('http://16.171.188.189:3000/api/visitors/select'));
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        setState(() => programs = data['programs']);
      } else {
        showMessage('Failed to fetch programs');
      }
    } catch (e) {
      showMessage('Error fetching programs');
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> handleSubmit() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedProgram == null ||
        selectedRequirement == null) {
      showMessage("Please fill all required fields including Program & Requirement.");
      return;
    }

    if (loggedUser == null || loggedUser!['id'] == null) {
      showMessage("User not loaded. Login again.");
      return;
    }

    final payload = {
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'company': companyController.text,
      'designation': designationController.text,
      'address': addressController.text,
      'program': selectedProgram['name'],
      'requirement': selectedRequirement['name'],
      'image': ocrText,
      'user_id': loggedUser!['id'],
    };

    try {
      final res = await http.post(
        Uri.parse('http://16.171.188.189:3000/api/visitors/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        showMessage('Visitor Saved Successfully ✅');
        clearForm();
      } else {
        showMessage(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      showMessage('Could not connect to the server');
    }
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    companyController.clear();
    designationController.clear();
    addressController.clear();
    setState(() {
      selectedProgram = null;
      selectedRequirement = null;
      ocrText = null;
    });
  }

  Future<void> showSelectionModal(List<dynamic> items, Function(dynamic) onSelect) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Container(
          height: 300,
          child: Column(
            children: [
              SizedBox(height: 10),
              Text('Select', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['name']),
                      onTap: () {
                        onSelect(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTextField(String hint, TextEditingController controller, {bool optional = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
    );
  }

  Widget buildDropdown(String label, dynamic selected, List<dynamic> items, Function(dynamic) onSelect) {
    return GestureDetector(
      onTap: () => showSelectionModal(items, onSelect),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selected != null ? selected['name'] : 'Select $label', style: TextStyle(fontSize: 15)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    designationController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Manual Visitor Entry', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 20),
              if (ocrText != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                  height: 120,
                  child: SingleChildScrollView(child: Text(ocrText!)),
                )
              else
                Text('No Text Scanned', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
              SizedBox(height: 15),
              buildTextField('Full Name', nameController),
              SizedBox(height: 10),
              buildTextField('Email', emailController),
              SizedBox(height: 10),
              buildTextField('Phone', phoneController),
              SizedBox(height: 10),
              buildTextField('Company (Optional)', companyController, optional: true),
              SizedBox(height: 10),
              buildTextField('Remarks (Optional)', designationController, optional: true),
              SizedBox(height: 10),
              buildTextField('Address (Optional)', addressController, optional: true),
              SizedBox(height: 15),
              buildDropdown('Event', selectedProgram, programs, (item) => setState(() => selectedProgram = item)),
              SizedBox(height: 10),
              buildDropdown('Requirement', selectedRequirement, requirements, (item) => setState(() => selectedRequirement = item)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleSubmit,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Save Visitor', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
