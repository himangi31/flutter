import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  void handleSignup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final dio = Dio();
      final res = await dio.post(
        'http://16.171.188.189:3000/api/visitors/signup',
        data: {'email': email, 'password': password},
      );

      if (res.data['success'] == true) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: Text(res.data['message']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on DioError catch (err) {
      if (err.response?.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email already registered")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.response?.data['message'] ?? 'Server error')),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Hello\nAdmin Sign up!",
                    style: TextStyle(
                      color: Color(0xFFDBEB00),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: loading ? null : handleSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B0C04),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "SIGN UP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Back to ", style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF460066),
                                ),
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
        ],
      ),
    );
  }
}
