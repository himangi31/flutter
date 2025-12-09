import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class UserDetailScreen extends StatefulWidget {
   final Function(String route)? onNavigate;
 const UserDetailScreen({super.key, this.onNavigate});
  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  List users = [];
  bool loading = false;
  bool showPasswordTable = false;
  TextEditingController searchController = TextEditingController();

  // Edit Form
  Map<String, dynamic>? editingUser;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPassword = false;

  final dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      setState(() => loading = true);
      final response = await dio.get('http://16.171.188.189:3000/api/auth/users');
      setState(() {
        users = response.data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteUser(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await dio.delete('http://16.171.188.189:3000/api/auth/users/$id');
      fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  Future<void> updateUser() async {
    if (editingUser == null) return;
    try {
      await dio.put(
        'http://16.171.188.189:3000/api/auth/users/${editingUser!['id']}',
        data: {
          "name": nameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "password": passwordController.text,
        },
      );
      setState(() {
        editingUser = null;
        showPassword = false;
      });
      fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((u) {
      final search = searchController.text.toLowerCase();
      return u['name'].toString().toLowerCase().contains(search) ||
          u['email'].toString().toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup_user'); // User signup screen
                    },
                    child: const Text('Registered User'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showPasswordTable = !showPasswordTable;
                      });
                    },
                    child: Text(showPasswordTable ? 'Hide Passwords' : 'Show Passwords'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Search
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or email',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            // Edit Form
            if (editingUser != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                      TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                      TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => showPassword = !showPassword),
                          ),
                        ),
                        obscureText: !showPassword,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(onPressed: updateUser, child: const Text('Save')),
                          ElevatedButton(
                            onPressed: () => setState(() => editingUser = null),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                            child: const Text('Cancel'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 10),
            // User Table
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Password')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: filteredUsers.map((user) {
                          return DataRow(cells: [
                            DataCell(Text(user['name'] ?? '')),
                            DataCell(Text(user['email'] ?? '')),
                            DataCell(Text(user['phone'] ?? '')),
                            DataCell(Text(showPasswordTable
                                ? (user['password'] ?? '')
                                : '•' * ((user['password'] ?? '').length.clamp(0, 8)))),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.amber),
                                  onPressed: () {
                                    setState(() {
                                      editingUser = user;
                                      nameController.text = user['name'] ?? '';
                                      emailController.text = user['email'] ?? '';
                                      phoneController.text = user['phone'] ?? '';
                                      passwordController.text = user['password'] ?? '';
                                      showPassword = false;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteUser(user['id'].toString()),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
