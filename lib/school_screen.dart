import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchoolCreationPage extends StatefulWidget {
  @override
  _SchoolCreationPageState createState() => _SchoolCreationPageState();
}

class _SchoolCreationPageState extends State<SchoolCreationPage> {
  List schools = []; // Initialize school list
  final String apiUrl = 'http://127.0.0.1:8000/api/school';

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
                      backgroundColor: Colors.blueGrey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Submit'),
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
                              return ListTile(
                                title: Text(
                                  school['name'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  school['type'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
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
