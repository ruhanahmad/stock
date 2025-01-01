import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stockproject/widget/route.dart';

//final box = GetStorage();
// var token = data['data']['token'];

//       // Store the token in GetStorage
//       box.write('token', token);

class AuthController extends GetxController {
  final box = GetStorage();
  var isLoading = false.obs;
  var role = ''.obs;

  // Function to log in and handle the API response
  Future<void> login(String email, String password) async {
    isLoading.value = true; // Show loader
    try {
      final response = await http.post(
        Uri.parse('$url/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data'); // Print the full API response

        // Extract role from response data
        var roles = data['data']['roles'];
        var token = data['data']['token'];
        var users = data['data']['user']['id'];

        // var roleId = data['data']['user']['id'];
        // Store the token in GetStorage
        box.write('token', token);
        box.write('users', users);
        // box.write('roleId', roleId);
        if (roles.isNotEmpty) {
          role.value = roles[0]['name']; // Assuming the first role is primary
          // role.value = roles[0]['id'];
          print('User Role: ${role.value}');

          // Navigate based on the role
          switch (role.value) {
            case 'Admin':
              Get.offNamed(
                '/dashboard',
              );
              break;
            case 'Salesperson Shop':
              Get.offNamed(
                '/SalespersonShop',
              );
              break;
            case 'Manager':
              Get.offNamed(
                '/manager',
              );
              break;
            default:
              Get.snackbar('Error', 'Unauthorized role');
              break;
          }
        } else {
          Get.snackbar('Login Failed', 'No role assigned to this user');
        }
      } else {
        // Handle errors, e.g., invalid credentials
        print('Error: ${response.body}');
        Get.snackbar('Login Failed', 'Invalid credentials or server error');
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading.value = false; // Hide loader
    }
  }
}
