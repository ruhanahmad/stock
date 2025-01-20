import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stockproject/salesperson/items_salesperson.dart';
import 'package:stockproject/salesperson/showProducts.dart';
import 'package:stockproject/salesperson/showSchools.dart';
import 'package:stockproject/widget/route.dart';

class salesPersonController extends GetxController {
  List products = [].obs;
  List schools = [].obs;
  List selectedProducts = [].obs;
  //double totalPrice = 0.0;
  var totalPrice = 0.0.obs;
  Future<void> fetchSchools(String schoolType) async {
    final box = GetStorage();
    String? token = box.read('token');

    try {
      final response = await http.get(
        Uri.parse('$schoolApiUrl$schoolType'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data);
        schools.addAll(data['data']['schools']);

        // Schools
        // Get.to(() => ShowSchools());
        // Show products in the bottom sheet
        // showProductSelector(data['data']['products']);
      } else {
        Get.snackbar('Error', 'Failed to load products');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> fetchProducts(int schoolId) async {
    products.clear();
    final box = GetStorage();
    String? token = box.read('token');

    try {
      final response = await http.get(
        Uri.parse('$stockApiUrl$schoolId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Show products in the bottom sheet
        // showProductSelector(data['data']['products']);
        products.addAll(data['data']['products']);
        // Get.to(() => ShowProducts());
        // ShowSchools
        update();
        print(products);
      } else {
        Get.snackbar('Error', 'Failed to load products');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  void addToCart(product) {
    int availableQuantity =
        int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;

    if (availableQuantity > 0) {
      var existingProduct = selectedProducts.firstWhere(
        (p) => p['product']['id'] == product['id'],
        orElse: () => null,
      );

      if (existingProduct != null) {
        existingProduct['quantity'] += 1;
      } else {
        selectedProducts.add({
          'product': product,
          'quantity': 1,
        });
      }
      update();
      print(selectedProducts);
      updateTotalPrice();
    } else {
      Get.snackbar('Error', 'Product quantity is not available');
    }
  }

  // void updateTotalPrice() {
  //   double total = 0;
  //   for (var item in selectedProducts) {
  //     var product = item['product'];
  //     total += (product['price'] as double) * item['quantity'];
  //   }

  //   totalPrice = total;
  //   update();
  // }

  void updateTotalPrice() {
    double total = 0;
    for (var item in selectedProducts) {
      var product = item['product'];
      // Ensure the price is treated as a double
      double price = double.tryParse(product['price'].toString()) ?? 0.0;
      int quantity = item['quantity'] as int; // Assuming quantity is an integer
      total += price * quantity;
    }

    totalPrice.value = total; // Or `totalPrice = total;` if not using .obs
    print(totalPrice.value);
  }

  void incrementQuantity(int index) {
    selectedProducts[index]['quantity'] += 1;
    update();
    updateTotalPrice();
  }

  void decrementQuantity(int index) {
    if (selectedProducts[index]['quantity'] > 1) {
      selectedProducts[index]['quantity'] -= 1;
    }
    update();
    updateTotalPrice();
  }

  void removeProduct(int index) {
    selectedProducts.removeAt(index);
    update();
    updateTotalPrice();
  }

  void navigateToCart() {
    Get.to(() => CartScreen(
          cartItems: selectedProducts,
          totalPrice: totalPrice.value,
          incrementQuantity: incrementQuantity,
          decrementQuantity: decrementQuantity,
          removeProduct: removeProduct,
        ));
  }
}
