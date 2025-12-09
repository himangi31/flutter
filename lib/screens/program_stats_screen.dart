import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProgramStatsScreen extends StatefulWidget {
  const ProgramStatsScreen({Key? key}) : super(key: key);

  @override
  _ProgramStatsScreenState createState() => _ProgramStatsScreenState();
}

class _ProgramStatsScreenState extends State<ProgramStatsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> programData = [];
  int total = 0;
  int displayValue = 0;

  late AnimationController _controller;
  late Animation<int> _animation;

  final BASE_URL = "http://16.171.188.189:3000/api/visitors";

  @override
  void initState() {
    super.initState();
    fetchData();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedUser = prefs.getString('user');
      final user = storedUser != null ? jsonDecode(storedUser) : null;

      if (user == null || user['id'] == null) {
        print("User not found in SharedPreferences");
        return;
      }

      final programRes =
          await http.get(Uri.parse('$BASE_URL/program/${user['id']}'));
      final programJson = jsonDecode(programRes.body);

      if (programJson['success'] == true && programJson['data'] != null) {
        setState(() {
          programData = List<Map<String, dynamic>>.from(programJson['data']);
        });
      }

      final totalRes =
          await http.get(Uri.parse('$BASE_URL/total/${user['id']}'));
      final totalJson = jsonDecode(totalRes.body);

      if (totalJson['success'] == true && totalJson['total'] != null) {
        setState(() {
          total = totalJson['total'];
          animateNumber();
        });
      }
    } catch (e) {
      print("Fetch Error: $e");
    }
  }

  void animateNumber() {
    _animation = IntTween(begin: 0, end: total).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    )..addListener(() {
        setState(() {
          displayValue = _animation.value;
        });
      });

    _controller.forward();
  }

  List<PieChartSectionData> getPieData() {
    final colors = [
      Colors.yellow,
      Colors.orange,
      Colors.redAccent,
      Colors.blue,
      Colors.teal,
      Colors.purple,
    ];

    return programData
        .where((item) => (item['count'] ?? 0) > 0)
        .toList()
        .asMap()
        .entries
        .map((entry) {
      int idx = entry.key;
      final item = entry.value;
      return PieChartSectionData(
        color: colors[idx % colors.length],
        value: (item['count'] ?? 0).toDouble(),
        title: item['program'] ?? 'Other',
        titleStyle: const TextStyle(color: Colors.white, fontSize: 14),
      );
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  Widget bottomNavItem(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d0e0cd8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Visitor Statistics",
                        style: TextStyle(
                          color: Color(0xFFFFD029),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$displayValue",
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFD029),
                                ),
                              ),
                              const Text(
                                "Total Visitors",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Programs: ${programData.length}",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                              Text(
                                "Total Entries: $total",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // PIE CHART
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Program Distribution",
                        style: TextStyle(
                            color: Color(0xFFFFD029),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      programData.isNotEmpty
                          ? SizedBox(
                              height: 260,
                              child: PieChart(
                                PieChartData(
                                  sections: getPieData(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 0,
                                ),
                              ),
                            )
                          : const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  "No program data found",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔥 BOTTOM NAVIGATION BAR ADDED HERE
          Positioned(
            bottom: 40,
            left: width * 0.04,
            right: width * 0.04,
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  bottomNavItem("Home", () => navigateTo("/home")),
                  bottomNavItem("Stats", () => navigateTo("/program_stats")),
                  GestureDetector(
                    onTap: () => navigateTo("/scan_card"),
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFC840),
                          borderRadius: BorderRadius.circular(40)),
                      alignment: Alignment.center,
                      child: const Text("+",
                          style: TextStyle(
                              fontSize: 34, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  bottomNavItem("Visitors", () => navigateTo("/visitor_list")),
                  bottomNavItem("Profile", () => navigateTo("/userprofile")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
