import 'package:flutter/material.dart';

class AdminBottomNav extends StatelessWidget {
  final Function(String) onNavigate;

  const AdminBottomNav({super.key, required this.onNavigate});

  void handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onNavigate("Login");
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          height: 75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home
              GestureDetector(
                onTap: () => onNavigate("/admin_home"),
                child: const Text(
                  "Home",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),

              // Stats
              GestureDetector(
                onTap: () => onNavigate("/admin_stat"),
                child: const Text(
                  "Stats",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),

              // Center Button
              GestureDetector(
                onTap: () => onNavigate("ScanCard"),
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFC840),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "+",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              // Profile
              GestureDetector(
                onTap: () => onNavigate("Profile"),
                child: const Text(
                  "Profile",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),

              // Logout
              GestureDetector(
                onTap: () => handleLogout(context),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
