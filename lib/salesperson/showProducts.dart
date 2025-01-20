import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockproject/controllers/salespersonController.dart';

class ShowProducts extends GetView<salesPersonController> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.sizeOf(context).width - 200,
        height: MediaQuery.sizeOf(context).height,
        padding: EdgeInsets.all(16),
        color: Colors.purple,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Products',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 16),
              Obx(
                () => Expanded(
                  child: ListView.builder(
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      print(controller.products.length);
                      var product = controller.products[index];
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
                                  controller.addToCart(product);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        ));
  }
}
