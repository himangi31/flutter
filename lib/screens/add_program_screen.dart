import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AddProgramScreen extends StatefulWidget {
  const AddProgramScreen({super.key});

  @override
  State<AddProgramScreen> createState() => _AddProgramScreenState();
}

class _AddProgramScreenState extends State<AddProgramScreen> {
  final TextEditingController programController = TextEditingController();
  List<Map<String, dynamic>> programs = [];
  int? editingId;

  final String baseUrl = "http://16.171.188.189:3000/api/visitors";

  @override
  void initState() {
    super.initState();
    fetchPrograms();
  }

  @override
  void dispose() {
    programController.dispose();
    super.dispose();
  }

  Future<void> fetchPrograms() async {
    try {
      final res = await Dio().get("$baseUrl/programs");
      if (!mounted) return;
      setState(() {
        programs = List<Map<String, dynamic>>.from(res.data);
      });
    } catch (e) {
      showMessage("Error", "Unable to load programs");
    }
  }

  void showMessage(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  Future<void> saveProgram() async {
    if (programController.text.trim().isEmpty) {
      showMessage("Required", "Program name cannot be empty");
      return;
    }

    try {
      if (editingId != null) {
        await Dio().put(
          "$baseUrl/program/$editingId",
          data: {"program": programController.text},
        );
        showMessage("Updated", "Program updated successfully");
      } else {
        await Dio().post(
          "$baseUrl/programonly",
          data: {"program": programController.text},
        );
        showMessage("Success", "Program saved successfully");
      }

      programController.clear();
      editingId = null;
      fetchPrograms();
    } catch (e) {
      showMessage("Error", "Something went wrong");
    }
  }

  void editProgram(Map<String, dynamic> item) {
    programController.text = item["program"];
    editingId = item["idprogram"];
    setState(() {});
  }

  void deleteProgram(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Program"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Dio().delete("$baseUrl/program/$id");
                fetchPrograms();
              } catch (e) {
                showMessage("Error", "Failed to delete program");
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF4F6F9),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            const Text(
              "Event Manager",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),

            const Text(
              "Create, edit or delete available Event",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: programController,
                    decoration: InputDecoration(
                      hintText: "Enter Event Name",
                      filled: true,
                      fillColor: const Color(0xffF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: saveProgram,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff040f1d),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: Center(
                        child: Text(
                          editingId != null ? "Update Program" : "Save Event",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Available Event",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: programs.length,
                itemBuilder: (context, index) {
                  final item = programs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item["program"],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        Row(
                          children: [
                            // Edit
                            InkWell(
                              onTap: () => editProgram(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Edit",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Delete
                            InkWell(
                              onTap: () => deleteProgram(item["idprogram"]),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
