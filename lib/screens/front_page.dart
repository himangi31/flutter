import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class FrontPage extends StatefulWidget {
  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateToUserLog() {
  Navigator.pushNamed(context, '/user_log');  // Use the route name '/user_log'
}


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // TOP SHAPES
          Positioned(
            top: -width * 0.15,
            left: -width * 0.1,
            child: Container(
              width: width * 0.5,
              height: width * 0.5,
              decoration: BoxDecoration(
                color: Color(0xFF6CD067),
                borderRadius: BorderRadius.circular(width * 0.25),
              ),
            ),
          ),
          Positioned(
            top: width * 0.05,
            left: -width * 0.15,
            child: Container(
              width: width * 0.35,
              height: width * 0.35,
              decoration: BoxDecoration(
                color: Color(0xFFFFD257),
                borderRadius: BorderRadius.circular(width * 0.175),
              ),
            ),
          ),

          // BOTTOM SHAPES
          Positioned(
            bottom: -width * 0.15,
            right: -width * 0.1,
            child: Container(
              width: width * 0.45,
              height: width * 0.45,
              decoration: BoxDecoration(
                color: Color(0xFF6CD067),
                borderRadius: BorderRadius.circular(width * 0.225),
              ),
            ),
          ),
          Positioned(
            bottom: width * 0.05,
            right: -width * 0.15,
            child: Container(
              width: width * 0.35,
              height: width * 0.35,
              decoration: BoxDecoration(
                color: Color(0xFFFFD257),
                borderRadius: BorderRadius.circular(width * 0.175),
              ),
            ),
          ),

          // MAIN CONTENT
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // PULSE LOGO
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Image.asset(
                        'assets/logo.png',
                        width: 230,
                        height: 70,
                      ),
                    ),

                    SizedBox(height: 20),

                    // LOCATION ICON
                    Image.asset(
                      'assets/a.png',
                      width: 65,
                      height: 65,
                    ),

                    SizedBox(height: 15),

                    // TITLE
                    Text(
                      'BPE Konnect',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 20),

                    // BUTTON
                    GestureDetector(
                      onTap: navigateToUserLog,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 90),
                        decoration: BoxDecoration(
                          color: Color(0xFF6CD067),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 18),
                    Text(
                      'click here',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
