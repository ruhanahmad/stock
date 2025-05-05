import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:stockproject/widget/route.dart';

class StockCreationPage extends StatefulWidget {
  final Function onStockAdded;

  StockCreationPage({required this.onStockAdded});

  @override
  _StockCreationPageState createState() => _StockCreationPageState();
}

class _StockCreationPageState extends State<StockCreationPage> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final String apiUrl = '$url/api/stock';
  final String schoolApiUrl = '$url/api/school';
  final String roleUsersApiUrl = '$url/api/role-users'; // New API endpoint for role users

  List<String> selectedTypes = []; // Multiple stock types
  List<String> selectedCategories = []; // Multiple categories
  List<String> selectedSchoolIds = []; // Multiple school IDs
  List<String> selectedSizes = []; // Multiple sizes
  List<String> selectedAssignedTo = []; // Multiple assigned users
  String selectedLocation = 'Stock';
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> schools = [];
  List<Map<String, dynamic>> roleUsers = []; // List of users with specific role
  final box = GetStorage();

  Future<void> createStock(BuildContext context) async {
    final token = GetStorage().read('token');
    final userId = GetStorage().read('users');

    Map<String, dynamic> requestBody = {
      'product_name': productNameController.text,
      'category': selectedCategories,
      'stock_types': selectedTypes,
      'school_id': selectedSchoolIds,
      'size': selectedSizes,
      'price': priceController.text,
      'quantity': quantityController.text,
      'location': selectedLocation,
      'user_id': userId
    };

    // Add additional fields if location is "on Road Stock"
    if (selectedLocation == 'on Road Stock') {
      requestBody.addAll({
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'assigned_to': selectedAssignedTo,
      });
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    print(response.body);

    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Stock created successfully');
      widget.onStockAdded();
      Navigator.pop(context);
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

  Future<void> fetchRoleUsers() async {
    final token = GetStorage().read('token');
    final response = await http.get(
      Uri.parse(roleUsersApiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        roleUsers = List<Map<String, dynamic>>.from(data['data']['users']);
      });
    } else {
      Get.snackbar('Error', 'Failed to fetch users');
    }
  }

  void showSchoolSelectionSheet() async {
    await fetchSchools();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                AppBar(
                  title: Text('Select Schools'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Done'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: schools.length,
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      final isSelected = selectedSchoolIds.contains(school['id'].toString());
                      return CheckboxListTile(
                        title: Text(school['name']),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedSchoolIds.add(school['id'].toString());
                            } else {
                              selectedSchoolIds.remove(school['id'].toString());
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showRoleUsersSelectionSheet() async {
    await fetchRoleUsers();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                AppBar(
                  title: Text('Select Users'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Done'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: roleUsers.length,
                    itemBuilder: (context, index) {
                      final user = roleUsers[index];
                      final isSelected = selectedAssignedTo.contains(user['id'].toString());
                      return CheckboxListTile(
                        title: Text(user['name']),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedAssignedTo.add(user['id'].toString());
                            } else {
                              selectedAssignedTo.remove(user['id'].toString());
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
              _buildMultiSelectionField(
                label: 'Type',
                selectedItems: selectedTypes,
                options: ['Own Stock', 'Shared Stock'],
                onSelectionChanged: (List<String> newSelection) {
                  setState(() {
                    selectedTypes = newSelection;
                  });
                },
              ),
              SizedBox(height: 10),
              _buildMultiSelectionField(
                label: 'Category',
                selectedItems: selectedCategories,
                options: ['Primary School', 'Secondary School'],
                onSelectionChanged: (List<String> newSelection) {
                  setState(() {
                    selectedCategories = newSelection;
                  });
                },
              ),
              SizedBox(height: 10),
              _buildSchoolSelectionField(),
              SizedBox(height: 10),
              _buildSizeSelectionField(),
              SizedBox(height: 10),
              _buildTextField('Price', priceController),
              SizedBox(height: 10),
              _buildTextField('Quantity', quantityController),
              SizedBox(height: 10),
              _buildLocationField(),
              if (selectedLocation == 'on Road Stock') ...[
                SizedBox(height: 10),
                _buildDateField('Start Date', startDate, (date) {
                  setState(() {
                    startDate = date;
                  });
                }),
                SizedBox(height: 10),
                _buildDateField('End Date', endDate, (date) {
                  setState(() {
                    endDate = date;
                  });
                }),
                SizedBox(height: 10),
                _buildAssignedToField(),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  createStock(context);
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

  Widget _buildMultiSelectionField({
    required String label,
    required List<String> selectedItems,
    required List<String> options,
    required Function(List<String>) onSelectionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: selectedItems.contains(option),
              onSelected: (bool selected) {
                final newSelection = List<String>.from(selectedItems);
                if (selected) {
                  newSelection.add(option);
                } else {
                  newSelection.remove(option);
                }
                onSelectionChanged(newSelection);
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedItems.contains(option) ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSchoolSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schools',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: showSchoolSelectionSheet,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedSchoolIds.isEmpty
                        ? 'Select Schools'
                        : '${selectedSchoolIds.length} schools selected',
                  ),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: ['Stock', 'on Road Stock'].map((location) {
            return FilterChip(
              label: Text(location),
              selected: selectedLocation == location,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    selectedLocation = location;
                  });
                }
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedLocation == location ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('yyyy-MM-dd').format(date)
                        : 'Select $label',
                  ),
                ),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignedToField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign To',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: showRoleUsersSelectionSheet,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedAssignedTo.isEmpty
                        ? 'Select Users'
                        : '${selectedAssignedTo.length} users selected',
                  ),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: [
            'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', '4XL', '5XL', '6XL'
          ].map((size) {
            return FilterChip(
              label: Text(size),
              selected: selectedSizes.contains(size),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedSizes.add(size);
                  } else {
                    selectedSizes.remove(size);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedSizes.contains(size) ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
