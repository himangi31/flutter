import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  const HomeScreen({this.user, super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  List<String> banners = ['assets/banner.png'];

  int totalVisitors = 0;
  int displayVisitors = 0;

  int notifications = 3;

  Map<String, dynamic> loggedUser = {};

  late Timer bannerTimer;
  late AnimationController _controller;
  late Animation<double> _animation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: currentIndex);

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    )..addListener(() {
        setState(() => displayVisitors = _animation.value.round());
      });

    _controller.forward();

    bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % banners.length;
        _pageController.animateToPage(currentIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut);
      });
    });

    loadUserAndFetchVisitorsCount();

    if (notifications > 0) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("🔔 New Notification"),
            content: Text("You have $notifications new notifications!"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"))
            ],
          ),
        );
      });
    }
  }

  Future<void> loadUserAndFetchVisitorsCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString('user');

    if (userString != null) {
      loggedUser = jsonDecode(userString);
      print("Logged User: $loggedUser");

      await fetchVisitorsCount();
    }
  }

  /// FETCH VISITOR COUNT API
  Future<void> fetchVisitorsCount() async {
    if (loggedUser.isEmpty) return;

    final userId = loggedUser['id'];
    final url = "http://16.171.188.189:3000/api/visitors/user/$userId";

    print("Fetching → $url");

    try {
      final res = await http.get(Uri.parse(url));

      print("Status: ${res.statusCode}");
      print("Response: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        List list = data['visitors'] ?? [];

        setState(() => totalVisitors = list.length);

        _animation = Tween<double>(begin: 0, end: totalVisitors.toDouble())
            .animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutExpo,
        ));

        _controller.forward(from: 0);
      }
    } catch (e) {
      print("Visitor Count Error: $e");
    }
  }

  @override
  void dispose() {
    bannerTimer.cancel();
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/logo.png', width: 160, height: 40),
                      Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.notifications,
                                      size: 30)),
                              if (notifications > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "$notifications",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                              onPressed: () => navigateTo("/user_log"),
                              icon: const Icon(Icons.person, size: 30)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Banner Slider
                SizedBox(
                  height: 170,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: banners.length,
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(banners[index], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),

                // Visitor Count Card
                Container(
                  width: width * 0.9,
                  height: 100,
                  margin: EdgeInsets.symmetric(
                      vertical: 15, horizontal: width * 0.05),
                  decoration: BoxDecoration(
                    color: const Color(0xA6F9D853),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Total Visitors",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      Text(
                        "$displayVisitors",
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),

                // Main Actions
                const Padding(
                  padding: EdgeInsets.only(left: 22, top: 25, bottom: 10),
                  child: Text(
                    "Main Actions",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      for (var action in [
                        {"label": "Scan Visiting Card", "route": "/scan_card"},
                        {"label": "Manual Entry", "route": "/manual_entry"},
                        {"label": "Check-In History", "route": "/program_stats"},
                        {"label": "Add Event", "route": "/add_program"},
                      ])
                        SizedBox(
                          width: (width - 20 - 20 - 15) / 2,
                          child: actionBox(
                              action['label']!, action['route']!),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 50,
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
                  bottomNavItem(
                      "Visitors", () => navigateTo("/visitor_list")),
                  bottomNavItem("Profile", () => navigateTo("/userprofile")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget actionBox(String label, String route) {
    return GestureDetector(
      onTap: () => navigateTo(route),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow:
              const [BoxShadow(color: Colors.black12, blurRadius: 3)],
        ),
        alignment: Alignment.center,
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ),
    );
  }
}
