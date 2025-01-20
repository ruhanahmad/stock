import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockproject/controllers/salespersonController.dart';
import 'package:stockproject/salesperson/items_salesperson.dart';

class ShowSchools extends GetView<salesPersonController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width - 900,
      height: MediaQuery.sizeOf(context).height,
      padding: EdgeInsets.all(16),
      color: Colors.purple,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select School',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 16),
            // Wrap conditional logic in Obx
            Obx(() {
              if (controller.products.isEmpty) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.schools.length,
                    itemBuilder: (context, index) {
                      var school = controller.schools[index];

                      return GestureDetector(
                        onTap: () {
                          controller.fetchProducts(school["id"]);
                        },
                        child: Card(
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
                                      school['id'].toString() ?? 'N/A',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Price: ${school['name']}',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      'Stock: ${school['type']}',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Container(
                  height: MediaQuery.of(context).size.height - 400,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              controller.products.clear();
                              // Get.to(() => ItemSalesPerson());
                            },
                            child: Container(
                              height: 3,
                              width: 30,
                              color: Colors.black,
                            ),
                          )),
                      Expanded(
                        flex: 5,
                        child: ListView.builder(
                          itemCount: controller.products.length,
                          itemBuilder: (context, index) {
                            var product = controller.products[index];
                            return Card(
                              color: Colors.blueGrey[700],
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style:
                                              TextStyle(color: Colors.white70),
                                        ),
                                        Text(
                                          'Stock: ${product['quantity']}',
                                          style:
                                              TextStyle(color: Colors.white70),
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
                    ],
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
