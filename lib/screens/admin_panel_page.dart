// admin_panel_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AdminPanelPage extends StatefulWidget {
  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  List<User> users = [];
  List<SalesHistory> salesHistory = [];
  final _formKey = GlobalKey<FormState>();

  TextEditingController userController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchSalesHistory();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(
      Uri.parse('https://api-ppb.vercel.app/api/users'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        users = data.map((json) => User.fromJson(json)).toList();
      });
    }
  }

  Future<void> fetchSalesHistory() async {
    final response = await http.get(
      Uri.parse('https://api-ppb.vercel.app/api/carts/history'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        salesHistory = data.map((json) => SalesHistory.fromJson(json)).toList();
      });
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('https://api-ppb.vercel.app/api/users/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully')),
      );
    }
  }

  Future<void> createUser() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('https://api-ppb.vercel.app/api/users'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user': userController.text,
          'username': usernameController.text,
          'password': passwordController.text,
          'role': 'consumer',
        }),
      );

      if (response.statusCode == 200) {
        fetchUsers();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User created successfully')),
        );
      }
    }
  }

  void showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.user}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('https://api-ppb.vercel.app/api/users/${user.id}'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user': user.user,
        'username': user.username,
        'password': user.password,
        'role': 'consumer',
      }),
    );

    if (response.statusCode == 200) {
      fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User updated successfully')),
      );
    }
  }

  void showEditUserDialog(User user) {
    userController.text = user.user;
    usernameController.text = user.username;
    passwordController.text = user.password;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: userController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                User updatedUser = User(
                  id: user.id,
                  user: userController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                  role: user.role,
                );
                updateUser(updatedUser);
                Navigator.pop(context);
              }
            },
            child: Text('Update User'),
          ),
        ],
      ),
    );
  }

  void showAddUserDialog() {
    userController.clear();
    usernameController.clear();
    passwordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New User'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: userController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: createUser,
            child: Text('Add User'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Management',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton.icon(
                  onPressed: showAddUserDialog,
                  icon: const Icon(Icons.add, color: Colors.purple),
                  label: const Text('Add User', style: TextStyle(color: Colors.purple)),
                ),
              ],
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Actions', style: TextStyle(color: Colors.blue))),
                ],
                columnSpacing: 20,
                horizontalMargin: 12,
                rows: users.map((user) => DataRow(
                  cells: [
                    DataCell(Text(user.user)),
                    DataCell(Text(user.username)),
                    DataCell(Text(user.role.isEmpty ? 'consumer' : user.role)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => showEditUserDialog(user),
                            color: Colors.blue,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => showDeleteConfirmation(user),
                            color: Colors.red,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                        ],
                      ),
                    ),
                  ],
                )).toList(),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Sales History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Subtotal')),
                  DataColumn(label: Text('Date')),
                ],
                rows: salesHistory.map((sale) => DataRow(
                  cells: [
                    DataCell(Text(sale.name)),
                    DataCell(Text(sale.jumlah.toString())),
                    DataCell(Text(NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(sale.price))),
                    DataCell(Text(NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(sale.subtotal))),
                    DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(
                      DateTime.parse(sale.buyTime),
                    ))),
                  ],
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  final int id;
  final String user;
  final String username;
  final String password;
  final String role;

  User({
    required this.id,
    required this.user,
    required this.username,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      user: json['user'],
      username: json['username'],
      password: json['password'],
      role: json['role'] ?? '',
    );
  }
}

class SalesHistory {
  final String name;
  final int jumlah;
  final double price;
  final double subtotal;
  final String buyTime;

  SalesHistory({
    required this.name,
    required this.jumlah,
    required this.price,
    required this.subtotal,
    required this.buyTime,
  });

  factory SalesHistory.fromJson(Map<String, dynamic> json) {
    return SalesHistory(
      name: json['name'],
      jumlah: json['jumlah'],
      price: json['price'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      buyTime: json['buy_time'],
    );
  }
}