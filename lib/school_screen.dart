import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stockproject/widget/route.dart';

class SchoolCreationPage extends StatefulWidget {
  @override
  _SchoolCreationPageState createState() => _SchoolCreationPageState();
}

class _SchoolCreationPageState extends State<SchoolCreationPage> {
  List schools = []; // Initialize school list
  final String apiUrl = '$url/api/school';

  @override
  void initState() {
    super.initState();
    fetchSchools(); // Fetch school data on screen load
  }

  Future<void> fetchSchools() async {
    final box = GetStorage(); // Access GetStorage
    String? token = box.read('token'); // Retrieve the stored token

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add Bearer token to headers
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          // Update UI with fetched data
          schools = data['data']['schools'];
        });
      } else {
        Get.snackbar('Error', 'Failed to load schools');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
    }
  }

  final TextEditingController nameController = TextEditingController();
  String selectedType = 'Primary School'; // Default selected type

  Future<void> createSchool() async {
    final token = GetStorage().read('token'); // Retrieve stored token

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': nameController.text,
        'type': selectedType,
      }),
    );

    if (response.statusCode == 200) {
      Get.snackbar('Success', 'School created successfully');
      fetchSchools(); // Refresh the school list after creation
      nameController.clear(); // Clear the form field
    } else {
      Get.snackbar('Error', 'Failed to create school');
    }
    await fetchSchools();
  }

  Future<void> updateUser(int id, String name, String type) async {
    final box = GetStorage();
    String? token = box.read('token');
    print(token);
    print(id);
    print(selectedType + "whyyyyyyyyyyyyyyyyy");
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'type': selectedType,
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
        fetchSchools(); // Refresh the list after update
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
    TextEditingController typeController =
        TextEditingController(text: user['type']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update School'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                enabled: false,
                controller: typeController,
                decoration: InputDecoration(labelText: 'type'),
              ),
              GestureDetector(
                  onTap: () {
                    _showTypeBottomSheet();
                  },
                  child: Container(
                      height: 20,
                      width: 200,
                      color: Colors.black,
                      child: Text(
                        "Change School",
                        style: TextStyle(color: Colors.white),
                      )))
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
                updateUser(user['id'], nameController.text, typeController.text
                    // passwordController.text,
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
        fetchSchools(); // Refresh the list
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
      appBar: AppBar(title: Text('Create School')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            // height: 400,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('School Name', nameController),
                SizedBox(height: 20),
                ListTile(
                  title: Text(
                    'Selected Type: $selectedType',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(Icons.arrow_drop_down, color: Colors.white),
                  onTap: () => _showTypeBottomSheet(),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: createSchool,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  child: Container(
                    height: 300,
                    child: schools.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            // scrollDirection: Axis.vertical,
                            itemCount: schools.length,
                            itemBuilder: (context, index) {
                              var school = schools[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.white, // White background
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 4, // Adds a shadow effect
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              school['name'],
                                              style: TextStyle(
                                                color:
                                                    Colors.black, // Black text
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              school['type'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors
                                                    .black87, // Slightly dim black
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () =>
                                                    _showUpdateDialog(school),
                                                icon: Icon(Icons.edit)),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  _showDeleteConfirmationDialog(
                                                      school['id']),
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
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
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.blueGrey[800],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.blueGrey[700],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  void _showTypeBottomSheet() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: schoolTypes.map((type) {
            return ListTile(
              title: Text(type),
              onTap: () {
                setState(() {
                  selectedType = type;
                });
                print(selectedType);
                Get.back();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  final List<String> schoolTypes = ['Primary School', 'Secondary School'];
}
