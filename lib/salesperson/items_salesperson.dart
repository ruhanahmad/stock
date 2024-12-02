import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stockproject/widget/route.dart';

class ItemSalesPerson extends StatefulWidget {
  @override
  _ItemSalesPersonState createState() => _ItemSalesPersonState();
}

class _ItemSalesPersonState extends State<ItemSalesPerson> {
  List selectedProducts = []; // Persistent cart
  double totalPrice = 0.0;
  final String stockApiUrl = '$url/api/stock?school_type=';

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchProducts(String schoolType) async {
    final box = GetStorage();
    String? token = box.read('token');

    try {
      final response = await http.get(
        Uri.parse('$stockApiUrl$schoolType'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Show products in the bottom sheet
        showProductSelector(data['data']['products']);
      } else {
        Get.snackbar('Error', 'Failed to load products');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  void showProductSelector(List products) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Products',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    return Card(
                      color: Colors.blueGrey[700],
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['product_name'] ?? 'N/A',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Price: ${product['price']}',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Stock: ${product['quantity']}',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                addToCart(product);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void addToCart(product) {
    int availableQuantity =
        int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;

    if (availableQuantity > 0) {
      setState(() {
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
      });
      updateTotalPrice();
    } else {
      Get.snackbar('Error', 'Product quantity is not available');
    }
  }

  void updateTotalPrice() {
    double total = 0;
    for (var item in selectedProducts) {
      var product = item['product'];
      total += (product['price'] as double) * item['quantity'];
    }
    setState(() {
      totalPrice = total;
    });
  }

  void incrementQuantity(int index) {
    setState(() {
      selectedProducts[index]['quantity'] += 1;
    });
    updateTotalPrice();
  }

  void decrementQuantity(int index) {
    setState(() {
      if (selectedProducts[index]['quantity'] > 1) {
        selectedProducts[index]['quantity'] -= 1;
      }
    });
    updateTotalPrice();
  }

  void removeProduct(int index) {
    setState(() {
      selectedProducts.removeAt(index);
    });
    updateTotalPrice();
  }

  void navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cartItems: selectedProducts,
          totalPrice: totalPrice,
          incrementQuantity: incrementQuantity,
          decrementQuantity: decrementQuantity,
          removeProduct: removeProduct,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schools and Products')),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.blueGrey[800],
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                fetchProducts('Primary School');
              },
              child: Text('Primary School'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                fetchProducts('Secondary School');
              },
              child: Text('Secondary School'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: navigateToCart,
              child: Text('View Cart (${selectedProducts.length})'),
            ),
          ],
        ),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final List cartItems;
  final double totalPrice;
  final Function incrementQuantity;
  final Function decrementQuantity;
  final Function removeProduct;

  const CartScreen({
    required this.cartItems,
    required this.totalPrice,
    required this.incrementQuantity,
    required this.decrementQuantity,
    required this.removeProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: cartItems.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item = cartItems[index];
                        var product = item['product'];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product['product_name'] ?? 'N/A'),
                                    Text('Price: ${product['price']}'),
                                    Text('Quantity: ${item['quantity']}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () => decrementQuantity(index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () => incrementQuantity(index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => removeProduct(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    'Total Price: $totalPrice',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Checkout'),
                  ),
                ],
              ),
            ),
    );
  }
}
