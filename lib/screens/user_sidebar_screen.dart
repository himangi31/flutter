import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserSidebarScreen extends StatefulWidget {
  const UserSidebarScreen({super.key});

  @override
  State<UserSidebarScreen> createState() => _UserSidebarScreenState();
}

class _UserSidebarScreenState extends State<UserSidebarScreen> {
  Map<String, dynamic> userData = {};
  bool showPass = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString('user');
    if (userString != null) {
      setState(() {
        userData = json.decode(userString);
      });
    }
  }

  Widget renderRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value ?? '', style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
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
    final username = userData['email'] != null
        ? userData['email'].split("@")[0]
        : 'user';
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // HEADER
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 35),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: AssetImage('assets/k.jpg'),
                      ),
                      const SizedBox(height: 15),
                      Text(userData['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 5),
                      Text(
                        '@$username',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Edit Profile
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F7CFE),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                        ),
                        child: const Text('Edit Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                // DETAILS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: [
                      renderRow("Email", userData['email']),
                      renderRow("Mobile Number", userData['phone']),
                      // PASSWORD ROW
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Password',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                            Row(
                              children: [
                                Text(
                                  showPass
                                      ? userData['password'] ?? ''
                                      : '********',
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.grey),
                                ),
                                IconButton(
                                  icon: Icon(showPass
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () =>
                                      setState(() => showPass = !showPass),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),

                      // LOGOUT
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushReplacementNamed(
                              context, '/user_login');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Log out',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red)),
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

          // 🔥 BOTTOM NAVIGATION BAR
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
              ),  ),
          ),
        ],
      ),
    );
  }
}
