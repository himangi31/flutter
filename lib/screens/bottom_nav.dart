import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final Function(int)? onTap;
  final int selectedIndex;

  BottomNav({this.onTap, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // BOTTOM BAR
        Container(
          margin: EdgeInsets.only(bottom: 20),
          width: width,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    navItem(context, "Home", 0),
                    navItem(context, "Stats", 1),
                    SizedBox(width: 65), // Empty space for center button
                    navItem(context, "Visitors", 2),
                    navItem(context, "Profile", 3),
                  ],
                ),
              ),
              // CENTER BUTTON
              Positioned(
                top: -32,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "ScanCard");
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFC840),
                      borderRadius: BorderRadius.circular(32.5),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                    ),
                    child: Center(
                      child: Text(
                        "+",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget navItem(BuildContext context, String label, int index) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case "Home":
            Navigator.pushNamed(context, "Home");
            break;
          case "Stats":
            Navigator.pushNamed(context, "EventStats");
            break;
          case "Visitors":
            Navigator.pushNamed(context, "VisitorList");
            break;
          case "Profile":
            Navigator.pushNamed(context, "User");
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
