import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stockproject/role_dialog.dart';

import 'widget/route.dart';

class RolesscreenMain extends StatefulWidget {
  @override
  _RolesscreenMainState createState() => _RolesscreenMainState();
}

class _RolesscreenMainState extends State<RolesscreenMain> {
  List stocks = [];
  final String apiUrl = '$url/api/users';
  final String apiUrl2 = '$url/api/stocks-by-school?school_id=1';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUserss() async {
    final box = GetStorage();
    String? token = box.read('token');

    try {
      final response = await http.get(
        Uri.parse(apiUrl2),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data);
        // setState(() {
        //   stocks = data['data']['users'] ?? [];

        //   // print(stocks);
        // });
      } else {
        print('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> fetchUsers() async {
    final box = GetStorage();
    String? token = box.read('token');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // print(data);
        setState(() {
          stocks = data['data']['users'] ?? [];

          // print(stocks);
        });
      } else {
        print('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> updateUser(
      int id, String name, String email, String password) async {
    final box = GetStorage();
    String? token = box.read('token');
    print(token);
    print(id);
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        fetchUsers(); // Refresh the list after update
      } else {
        print('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void _showUpdateDialog(Map<String, dynamic> user) {
    print("$user + fadfsadas");
    TextEditingController nameController =
        TextEditingController(text: user['name']);
    TextEditingController emailController =
        TextEditingController(text: user['email']);
    TextEditingController passwordController =
        TextEditingController(text: user['password']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
              ),
            ],
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
                updateUser(
                  user['id'],
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                );

                print(nameController.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int stockId) {
    Get.defaultDialog(
      title: "Confirm Deletion",
      middleText: "Are you sure you want to delete this record?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await _deleteStock(stockId);
        Get.back(); // Close dialog
        Navigator.pop(context);
      },
    );
  }

  Future<void> _deleteStock(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$userId'),
        headers: {
          'Authorization': 'Bearer ${GetStorage().read('token')}',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Record deleted successfully");
        fetchUsers(); // Refresh the list
      } else {
        Get.snackbar("Error", "Failed to delete record");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.blueGrey[800],
        child: stocks.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : ListView.builder(
                itemCount: stocks.length,
                itemBuilder: (context, index) {
                  final user = stocks[index];

                  return GestureDetector(
                    onTap: () => _showUpdateDialog(user),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${user['id']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Name: ${user['name']}'),
                                SizedBox(height: 4),
                                Text('Email: ${user['email']}'),
                                SizedBox(height: 4),
                                Text('Password: ${user['password']}'),
                                SizedBox(height: 4),
                                Text('Role: ${user['roles'][0]['name']}'),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () => _showUpdateDialog(user),
                                    icon: Icon(Icons.edit)),
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _showDeleteConfirmationDialog(user['id']),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        focusColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RoleScreen(onStockAdded: fetchUsers)),
          );
        },
        backgroundColor: Colors.blueGrey[700],
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
