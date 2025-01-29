import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stockproject/stock_edit.dart';
import 'package:stockproject/widget/route.dart';
import 'package:stockproject/widgets/stock_enter.dart';
import 'dart:convert';

// Update with your actual file name

class StockListPage extends StatefulWidget {
  @override
  _StockListPageState createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  List stocks = [];
  final String apiUrl = '$url/api/stock';

  @override
  void initState() {
    super.initState();
    fetchStocks();
  }

  Future<void> fetchStocks() async {
    final box = GetStorage();
    String? token = box.read('token');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data);
        setState(() {
          stocks = data['data']['products'] ?? [];
        });
      } else {
        Get.snackbar('Error', 'Failed to load stocks');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  void _showDeleteConfirmationDialog(int stockId) {
    Get.defaultDialog(
      title: "Confirm Deletion",
      middleText: "Are you sure you want to delete this record?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await _deleteStock(stockId);
        Get.back(); // Close dialog
        Navigator.pop(context);
      },
    );
  }

  Future<void> _deleteStock(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$userId'),
        headers: {
          'Authorization': 'Bearer ${GetStorage().read('token')}',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Record deleted successfully");
        fetchStocks(); // Refresh the list
      } else {
        Get.snackbar("Error", "Failed to delete record");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stocks')),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.blueGrey[800],
        child: stocks.isEmpty
            ? Text("No Stock Available ")
            // Center(
            //     child: CircularProgressIndicator(
            //       color: Colors.white,
            //     ),
            //   )
            : ListView.builder(
                itemCount: stocks.length,
                itemBuilder: (context, index) {
                  var stock = stocks[index];
                  var school = stock['school'] ?? {};

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
                                stock['product_name'] ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Type: ${stock['type'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Category: ${stock['category'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Quantity: ${stock['quantity'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Price: ${stock['price'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'School: ${school['name'] ?? 'N/A'} (${school['type'] ?? 'N/A'})',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Size: ${stock['size'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Location: ${stock['location'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  Get.to(() => StockEditPage(stock: stock));
                                },
                              ),
                              IconButton(
                                onPressed: () =>
                                    _showDeleteConfirmationDialog(stock['id']),
                                icon: Icon(Icons.delete, color: Colors.red),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StockCreationPage(onStockAdded: fetchStocks)),
          );
        },
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
