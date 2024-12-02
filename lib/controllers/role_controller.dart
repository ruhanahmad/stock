import 'dart:convert';
import 'dart:ui_web';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stockproject/widget/route.dart';

class RoleController extends GetxController {
  final box = GetStorage(); // Access stored token

  // Function to create a user
  Future<void> createUser(
      String name, String email, String password, String role) async {
    var token = box.read('token'); // Retrieve token from storage

    try {
      final response = await http.post(
        Uri.parse('$url/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Pass the token in headers
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.snackbar(
            'Success', 'User Created: ${data['data']['user']['email']}');
      } else {
        Get.snackbar('Error', 'Failed to create user: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    }
  }
}
