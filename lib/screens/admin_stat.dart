import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class AdminStat extends StatefulWidget {
  final Function(String route)? onNavigate;
const AdminStat({super.key, this.onNavigate});

  

  @override
  State<AdminStat> createState() => _AdminStatState();
}

class _AdminStatState extends State<AdminStat>
    with SingleTickerProviderStateMixin {
  
  List<dynamic> programData = [];
  int total = 0;
  double animatedValue = 0.0;

  final String baseUrl = "http://16.171.188.189:3000/api/visitors";

  late AnimationController _controller;
  late Animation<double> _counterAnimation;

  @override
  void initState() {
    super.initState();
    fetchStats();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _counterAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    )..addListener(() {
        setState(() {
          animatedValue = _counterAnimation.value;
        });
      });
  }

  Future<void> fetchStats() async {
    try {
      /// ---- Program Count API ----
      final res1 = await http.get(Uri.parse("$baseUrl/program"));
      final data1 = jsonDecode(res1.body);

      if (data1["success"] == true) {
        programData = data1["data"];
      }

      /// ---- Total Count API ----
      final res2 = await http.get(Uri.parse("$baseUrl/total"));
      final data2 = jsonDecode(res2.body);

      if (data2["success"] == true) {
        total = data2["total"];
        _counterAnimation = Tween<double>(begin: 0, end: total.toDouble())
            .animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutExpo,
        ));

        _controller.forward(from: 0);
      }

      setState(() {});
    } catch (e) {
      print("Error fetching stats: $e");
    }
  }

  final List<Color> chartColors = [
    Color(0xff4dc9f6),
    Color(0xfff67019),
    Color(0xfff53794),
    Color(0xff537bc4),
    Color(0xffacc236),
    Color(0xff166a8f),
    Color(0xff58595b),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Heading
            const Text(
              "Total Visitors",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            /// Animated Counter
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                animatedValue.toInt().toString(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff00c6ff),
                ),
              ),
            ),

            /// Subheading
            const Text(
              "Program-wise Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            /// Pie Chart
            programData.isNotEmpty
                ? SizedBox(
                    height: 260,
                    child: PieChart(
                      PieChartData(
                        sections: programData.asMap().entries.map((entry) {
                          int index = entry.key;
                          var item = entry.value;

                          return PieChartSectionData(
                            value: double.parse(item["count"].toString()),
                            color: chartColors[index % chartColors.length],
                            title: item["program"] ?? "Other",
                            titleStyle: const TextStyle(
                                fontSize: 12, color: Colors.black),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  )
                : const Text("No data to display"),

            const SizedBox(height: 30),

            const Text(
              "Program-wise Bar Chart",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            /// Bar Chart
            programData.isNotEmpty
                ? SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= programData.length)
                                  return Container();
                                return Text(
                                  programData[index]["program"] ?? "Other",
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: programData.asMap().entries.map((entry) {
                          int index = entry.key;
                          var item = entry.value;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: double.parse(item["count"].toString()),
                                width: 18,
                                color: chartColors[index % chartColors.length],
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  )
                : const Text("No data to display"),
          ],
        ),
      ),
    );
  }
}
