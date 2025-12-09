import 'package:flutter/material.dart';

// Import all your screens
import 'screens/front_page.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/manual_entry_screen.dart';
import 'screens/visitor_list_screen.dart';
import 'screens/program_stats_screen.dart';
import 'screens/add_program_screen.dart';
import 'screens/user_login_screen.dart';
import 'screens/signup_user_screen.dart';
import 'screens/user_detail_screen.dart';
import 'screens/admin_home.dart';
import 'screens/admin_stat.dart';
import 'screens/admin_visitor.dart';
import 'screens/profile_screen.dart';
import 'screens/scan_card_screen.dart';
import 'screens/bottom_nav.dart';
import 'screens/admin_bottomnav.dart';
import 'screens/user_sidebar_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/front',
      routes: {
        // Front & Auth Screens
        '/front': (context) => FrontPage(),
        '/login_screen': (context) => LoginScreen(),
        '/user_log': (context) => UserLoginScreen(),
        '/signup_user': (context) => SignupUserScreen(),

        // User Screens
        '/home': (context) => HomeScreen(),
        '/manual_entry': (context) => ManualEntryScreen(),
        '/visitor_list': (context) => VisitorListScreen(),
        '/program_stats': (context) => ProgramStatsScreen(),
        '/add_program': (context) => AddProgramScreen(),
        '/scan_card': (context) => ScanCardScreen(),
        '/profile': (context) => ProfileScreen(),
       '/userprofile': (context) =>UserSidebarScreen (),
        // Admin Screens
        '/admin_home': (context) => AdminHome(onNavigate: (route) {
              _navigateAdmin(context, route);
            }),
        '/admin_stat': (context) => AdminStat(onNavigate: (route) {
              _navigateAdmin(context, route);
            }),
        '/admin_visitor': (context) => AdminVisitor(onNavigate: (route) {
              _navigateAdmin(context, route);
            }),
        '/user_detail': (context) => UserDetailScreen(onNavigate: (route) {
              _navigateAdmin(context, route);
            }),
      },
    );
  }

  // Central admin navigation
   // Central admin navigation
  static void _navigateAdmin(BuildContext context, String routeName) {
    String targetRoute;
    switch (routeName.toLowerCase()) {
      case 'adminhome':
      case '/admin_home':
        targetRoute = '/admin_home';
        break;
      case 'adminstat':
      case '/admin_stat':
        targetRoute = '/admin_stat';
        break;
      case 'adminvisitor':
      case '/admin_visitor':
        targetRoute = '/admin_visitor';
        break;
      case 'userdetail':
      case '/user_detail':
        targetRoute = '/user_detail';
        break;
      case 'profile':
      case '/profile':
        targetRoute = '/profile';
        break;
      case 'scancard':
      case '/scan_card':
        targetRoute = '/scan_card';
        break;
      case 'logout':
      case '/login_screen':
        targetRoute = '/login_screen';
        break;
      default:
        print("Route not found: $routeName");
        return;
    }

    // Only replace if we are navigating within admin screens
    if (targetRoute.startsWith('/admin')) {
      Navigator.pushReplacementNamed(context, targetRoute);
    } else {
      Navigator.pushNamed(context, targetRoute);
    }
  }

}
