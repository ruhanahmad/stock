import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockproject/login_screen.dart';
import 'package:stockproject/role_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stockproject/school_screen.dart';
import 'package:stockproject/stock_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Center(child: Text("Dashboard Content")),
    RoleScreen(),
    SchoolCreationPage(),
    StockListPage(),
    //  RoleScreen(),
  ];
  final box = GetStorage();
  Future<void> _logout() async {
    final token = box.read('token'); // Retrieve the token from storage
    print(token);
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/logout'),
      headers: {
        'Authorization': 'Bearer $token', // Send token for authentication
        'Content-Type': 'application/json',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      box.remove('token');
      Get.offAll(() => LoginScreen());
      Get.snackbar('Logout', 'Successfully logged out',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      // Handle logout failure
      Get.snackbar('Error', 'Failed to log out',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final role = Get.arguments['role']; // Get role from arguments

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call the logout function
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
              backgroundColor: Colors.blueAccent),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Roles',
              backgroundColor: Colors.blueAccent),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Add School',
              backgroundColor: Colors.blueAccent),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Add Stock',
              backgroundColor: Colors.blueAccent),
        ],
      ),
    );
  }
}
