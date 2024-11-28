import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockproject/dashboard_screen.dart';
import 'package:stockproject/login_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stockproject/salesperson/salespersonshop_dashboard.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Role-Based Flutter Web App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController()); // Register controller
      }),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginScreen()),
        GetPage(
            name: '/dashboard', page: () => DashboardScreen()), // Admin screen
        GetPage(
            name: '/SalespersonShop', page: () => SalesPersonDashboardScreen()),
        GetPage(name: '/manager', page: () => DashboardScreen()),
      ],
    );
  }
}
