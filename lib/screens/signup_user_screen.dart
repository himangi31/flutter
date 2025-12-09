import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupUserScreen extends StatefulWidget {
  const SignupUserScreen({Key? key}) : super(key: key);

  @override
  _SignupUserScreenState createState() => _SignupUserScreenState();
}

class _SignupUserScreenState extends State<SignupUserScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool showPassword = false;
  bool loading = false;

  void handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    final url = Uri.parse('http://16.171.188.189:3000/api/visitors/usersignup');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "number": numberController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Success"),
            content: Text(data['message']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        showError(data['message'] ?? 'Signup failed');
      }
    } catch (e) {
      showError('Server error');
    }

    setState(() {
      loading = false;
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7C9), Color(0xFFFFE58A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "User Registration",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Name is required" : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: numberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Mobile number is required" : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Email is required" : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Password is required" : null,
                  ),
                  SizedBox(height: 20),
                  loading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            backgroundColor: Color(0xFFFFD84D),
                          ),
                          onPressed: handleSignup,
                          child: Text(
                            "SIGN UP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Back to "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/user_log');
                        },
                        child: Text(
                          "Log in",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF460066),
                          ),
                        ),
                      )
                    ],
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
