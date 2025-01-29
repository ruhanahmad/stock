import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  final Map<String, dynamic> user;

  UserProfile({required this.user});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name']);
    _emailController = TextEditingController(text: widget.user['email']);
    _passwordController = TextEditingController(text: widget.user['password']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the user data
                setState(() {
                  widget.user['name'] = _nameController.text;
                  widget.user['email'] = _emailController.text;
                  widget.user['password'] = _passwordController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${widget.user['id']}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Name: ${widget.user['name']}'),
            SizedBox(height: 4),
            Text('Email: ${widget.user['email']}'),
            SizedBox(height: 4),
            Text('Password: ${widget.user['password']}'),
            SizedBox(height: 4),
            Text('Role: ${widget.user['roles'][0]['name']}'),
            SizedBox(height: 16),
            IconButton(
              onPressed: _showEditDialog,
              icon: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserProfile(user: {
      'id': 1,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'password': 'password123',
      'roles': [
        {'name': 'Admin'}
      ],
    }),
  ));
}
