import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchoolController extends GetxController {
  var schools = [].obs; // Observable list of schools
  final String apiUrl = 'http://127.0.0.1:8000/api/school';

  // Fetch all schools
  Future<void> fetchSchools() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print(response);
        var data = json.decode(response.body);
        schools.value = data['data']['schools'];
      } else {
        Get.snackbar('Error', 'Failed to load schools');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An error occurred');
    }
  }

  @override
  void onInit() {
    super.onInit();
    print("Controller Initialized");
    fetchSchools();
  }
  // Add a new school
}
