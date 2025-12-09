import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminHome extends StatefulWidget {
  final Function(String route)? onNavigate;

  const AdminHome({super.key, this.onNavigate});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int currentIndex = 0;
  PageController bannerController = PageController();
  int totalVisitors = 0;
  String userName = "Admin";

  @override
  void initState() {
    super.initState();
    autoSlideBanner();
    fetchTotalVisitors();
  }

  void autoSlideBanner() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (bannerController.hasClients) {
        currentIndex = (currentIndex + 1) % 1;
        bannerController.animateToPage(
          currentIndex,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> fetchTotalVisitors() async {
    try {
      final res = await http.get(
        Uri.parse("http://16.171.188.189:3000/api/visitors/total"),
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        setState(() {
          totalVisitors = data["total"];
        });
      }
    } catch (e) {
      print("Error fetching total visitors: $e");
    }
  }

  void handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onNavigate?.call("login");
            },
            child: Text("Logout"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome,", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                            Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),

                        GestureDetector(
                          onTap: handleLogout,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text("👤", style: TextStyle(fontSize: 20))),
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 170,
                    child: PageView.builder(
                      controller: bannerController,
                      itemCount: 1,
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              "assets/logo.png",
                              width: width * 0.95,
                              height: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Container(
                    width: width * 0.9,
                    margin: EdgeInsets.only(top: 20, left: 20),
                    padding: EdgeInsets.symmetric(vertical: 25),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9D853).withOpacity(0.65),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text("Total Visitors",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(height: 5),
                        Text(
                          "$totalVisitors",
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 22, top: 25),
                    child: Text("Main Actions",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        actionButton("Sales User", "/user_detail"),
                        actionButton("Scan Visiting Card", "/scan_card"),
                        actionButton("Add event", "/add_program"),
                        actionButton("Preview Visitors", "/admin_visitor"),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),



          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: bottomNav(width),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomNav(double width) {
    return Container(
      width: width * 0.92,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem("Home", "/admin_home"),
          navItem("Stats", "/admin_stat"),

          GestureDetector(
            onTap: () => widget.onNavigate?.call("/scan_card"),
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Color(0xFFFFC840),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Text("+",
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          navItem("Profile", "profile"),
          navItem("Logout", "login", onLogout: true),
        ],
      ),
    );
  }

  Widget actionButton(String title, String route) {
    return GestureDetector(
      onTap: () => widget.onNavigate?.call(route),
      child: Container(
        width: (MediaQuery.of(context).size.width * 0.9 - 20) / 2,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Center(
          child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget navItem(String label, String route, {bool onLogout = false}) {
    return GestureDetector(
      onTap: () {
        if (onLogout) {
          handleLogout();
        } else {
          widget.onNavigate?.call(route);
        }
      },
      child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}
