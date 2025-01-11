import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class UpdateUserScreen extends StatefulWidget {
  final int userId; // ID pengguna yang akan diperbarui

  UpdateUserScreen({required this.userId});

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _userController =
      TextEditingController(); // Controller untuk nama pengguna
  final TextEditingController _usernameController =
      TextEditingController(); // Controller untuk username
  final TextEditingController _passwordController =
      TextEditingController(); // Controller untuk password
  String _role = 'customer'; // Default role

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data saat halaman ditampilkan
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userController.text = prefs.getString('user') ?? ''; // Ambil user
    _usernameController.text =
        prefs.getString('username') ?? ''; // Ambil username
    _passwordController.text =
        prefs.getString('password') ?? ''; // Ambil password
    _role = prefs.getString('role') ?? 'customer'; // Ambil role
  }

  Future<void> _updateUser() async {
    try {
      bool success = await _apiService.updateUser(
        widget.userId,
        _userController.text,
        _usernameController.text,
        _passwordController.text,
        _role, // Kirim role yang dipilih
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                  labelText: 'Name'), // Field untuk nama pengguna
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Dropdown untuk memilih role
            DropdownButton<String>(
              value: _role,
              onChanged: (String? newValue) {
                setState(() {
                  _role = newValue!; // Update role saat dipilih
                });
              },
              items: <String>['customer', 'admin']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateUser,
              child: const Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}
