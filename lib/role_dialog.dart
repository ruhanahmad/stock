import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/role_controller.dart';

class RoleScreen extends StatefulWidget {
  @override
  _RoleScreenState createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final roleController =
      Get.put(RoleController()); // Register the RoleController
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'Admin'; // Default role

  final List<String> roles = [
    'Salesperson Shop',
    'Salesperson Mobile',
    'Cashier Shop',
    'Cashier Mobile',
    'Delivery Shop',
    'Delivery Mobile'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User Role'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),

            // Role selection using bottom sheet
            ListTile(
              title: Text('Selected Role: $selectedRole'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () => _showRoleBottomSheet(),
            ),

            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  roleController.createUser(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                    selectedRole,
                  );
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the bottom sheet for role selection
  void _showRoleBottomSheet() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: roles.map((role) {
            return ListTile(
              title: Text(role),
              onTap: () {
                setState(() {
                  selectedRole = role; // Update selected role
                });
                Get.back(); // Close bottom sheet
              },
            );
          }).toList(),
        ),
      ),
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
