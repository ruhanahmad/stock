import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stockproject/widget/route.dart';

class StockEditPage extends StatefulWidget {
  final Map<String, dynamic> stock;
  StockEditPage({required this.stock});

  @override
  _StockEditPageState createState() => _StockEditPageState();
}

class _StockEditPageState extends State<StockEditPage> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final String apiUrl = '$url/api/stock';
  final String schoolApiUrl = '$url/api/school';

  String selectedType = 'Own Stock';
  String selectedCategory = 'Primary School';
  String selectedLocation = 'Stock';
  String? selectedSchoolId;
  List<Map<String, dynamic>> schools = [];
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    productNameController.text = widget.stock['product_name'] ?? '';
    sizeController.text = widget.stock['size'] ?? '';
    priceController.text = widget.stock['price']?.toString() ?? '';
    quantityController.text = widget.stock['quantity']?.toString() ?? '';
    selectedType = widget.stock['type'] ?? 'Own Stock';
    selectedCategory = widget.stock['category'] ?? 'Primary School';
    selectedLocation = widget.stock['location'] ?? 'Stock';
    selectedSchoolId = widget.stock['school_id']?.toString();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    final token = box.read('token');
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

  Future<void> updateStock() async {
    final token = box.read('token');
    final response = await http.put(
      Uri.parse('$apiUrl/${widget.stock['id']}'),
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
        'location': selectedLocation,
      }),
    );

    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Stock updated successfully');
      Navigator.pop(context, true);
    } else {
      Get.snackbar('Error', 'Failed to update stock');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Stock')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Product Name', productNameController),
              SizedBox(height: 10),
              _buildDropdown('Type', ['Own Stock', 'Shared Stock'],
                  selectedType, (val) => setState(() => selectedType = val)),
              SizedBox(height: 10),
              _buildDropdown(
                  'Category',
                  ['Primary School', 'Secondary School'],
                  selectedCategory,
                  (val) => setState(() => selectedCategory = val)),
              SizedBox(height: 10),
              _buildSchoolDropdown(),
              SizedBox(height: 10),
              _buildTextField('Size', sizeController),
              SizedBox(height: 10),
              _buildTextField('Price', priceController),
              SizedBox(height: 10),
              _buildTextField('Quantity', quantityController),
              SizedBox(height: 10),
              _buildDropdown(
                  'Location',
                  ['Stock', 'On Road Stock'],
                  selectedLocation,
                  (val) => setState(() => selectedLocation = val)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateStock,
                child: Text('Update Stock'),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String value,
      Function(String) onSelected) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (newValue) => onSelected(newValue!),
    );
  }

  Widget _buildSchoolDropdown() {
    return DropdownButtonFormField<String>(
      value: schools.any((s) => s['id'].toString() == selectedSchoolId)
          ? selectedSchoolId
          : null,
      decoration: InputDecoration(
        labelText: 'School',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: schools.map((school) {
        return DropdownMenuItem(
          value: school['id'].toString(),
          child: Text(school['name']),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedSchoolId = value),
    );
  }
}
