import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stockproject/widget/route.dart';

class StockCreationPage extends StatefulWidget {
  final Function onStockAdded;

  StockCreationPage({required this.onStockAdded});

  @override
  _StockCreationPageState createState() => _StockCreationPageState();
}

class _StockCreationPageState extends State<StockCreationPage> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final String apiUrl = '$url/api/stock';
  final String schoolApiUrl = '$url/api/school';

  String selectedType = 'Own Stock';
  String selectedCategory = 'Primary School';
  String? selectedSchoolId; // ID of the selected school
  List<Map<String, dynamic>> schools = []; // To store schools data
  final box = GetStorage();

  Future<void> createStock(BuildContext context) async {
    final token = GetStorage().read('token');
    final userId = GetStorage().read('users');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'product_name': productNameController.text,
        'type': selectedType,
        'category': selectedCategory,
        'school_id': selectedSchoolId,
        'size': sizeController.text,
        'price': priceController.text,
        'quantity': quantityController.text,
        'location': locationController.text,
        'user_id': userId
      }),
    );
    print(response.body);

    if (response.statusCode == 200) {
      print(response.statusCode);
      Get.snackbar('Success', 'Stock created successfully');
      widget.onStockAdded();
      Navigator.pop(context); // Go back to the main page
    } else {
      Get.snackbar('Error', 'Failed to create stock');
    }
  }

  Future<void> fetchSchools() async {
    final token = GetStorage().read('token');
    final response = await http.get(
      Uri.parse(schoolApiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        schools = List<Map<String, dynamic>>.from(data['data']['schools']);
      });
    } else {
      Get.snackbar('Error', 'Failed to fetch schools');
    }
  }

  void showSchoolSelectionSheet() async {
    await fetchSchools(); // Fetch schools before displaying the sheet

    List<Map<String, dynamic>> filteredSchools = schools
        .where((school) =>
            school['type'].toLowerCase() == selectedCategory.toLowerCase())
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: filteredSchools
              .map((school) => ListTile(
                    title: Text(school['name']),
                    onTap: () {
                      setState(() {
                        selectedSchoolId = school['id'].toString();
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Stock'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Product Name', productNameController),
              SizedBox(height: 10),
              _buildBottomSheetField(
                label: 'Type',
                value: selectedType,
                options: ['Own Stock', 'Shared Stock'],
                onSelected: (val) {
                  setState(() {
                    selectedType = val;
                  });
                },
              ),
              SizedBox(height: 10),
              _buildBottomSheetField(
                label: 'Category',
                value: selectedCategory,
                options: ['Primary School', 'Secondary School'],
                onSelected: (val) {
                  setState(() {
                    selectedCategory = val;
                  });
                },
              ),
              SizedBox(height: 10),
              _buildSchoolIdField(),
              SizedBox(height: 10),
              _buildTextField('Size', sizeController),
              SizedBox(height: 10),
              _buildTextField('Price', priceController),
              SizedBox(height: 10),
              _buildTextField('Quantity', quantityController),
              SizedBox(height: 10),
              _buildTextField('Location', locationController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  createStock(context);
                  print("bitton pressend");
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        focusColor: Colors.white,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildBottomSheetField({
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView(
              children: options
                  .map((option) => ListTile(
                        title: Text(option),
                        onTap: () {
                          onSelected(option);
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            );
          },
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(value),
      ),
    );
  }

  Widget _buildSchoolIdField() {
    return InkWell(
      onTap: showSchoolSelectionSheet,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'School',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        // Show the name of the selected school
        child: Text(
          schools.firstWhere(
            (school) => school['id'].toString() == selectedSchoolId,
            orElse: () => {'name': 'Select School'},
          )['name'],
        ),
      ),
    );
  }
}
