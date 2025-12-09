import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPass = false;
  bool loading = false;

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse('http://16.171.188.189:3000/api/visitors/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        // Save credentials locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('@user_email', emailController.text);
        await prefs.setString('@user_password', passwordController.text);

        // Navigate to Admin Home
        if (mounted) Navigator.pushReplacementNamed(context, '/admin_home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7C9), Color(0xFFFFE58A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome \nBPE Admin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF010B16)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please Sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 30),

                  // Form Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        // Email Field
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        Stack(
                          children: [
                            TextField(
                              controller: passwordController,
                              obscureText: !showPass,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              ),
                            ),
                            Positioned(
                              right: 15,
                              top: 12,
                              child: GestureDetector(
                                onTap: () => setState(() => showPass = !showPass),
                                child: Text(showPass ? '🙈' : '👁️', style: const TextStyle(fontSize: 18)),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 15),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/Signup'),
                            child: Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Login Button
                        GestureDetector(
                          onTap: handleLogin,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD84D), Color(0xFFFFC700)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                loading ? 'Logging in...' : 'LOG IN',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Sign up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("New here? ", style: TextStyle(color: Colors.grey[700])),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/Signup'),
                              child: const Text(
                                "Sign up",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF460066)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
