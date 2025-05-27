import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockScreen extends StatefulWidget {
  final int schoolId;

  StockScreen({required this.schoolId});

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<dynamic> stockList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStock();
  }

  void fetchStock() async {
    final url = Uri.parse(
        'https://metrogarments.metrogarments.mu/api/stocks-by-school?school_id=${widget.schoolId}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        // Update to use stocks instead of products
        stockList = jsonData['data'] != null && jsonData['data']['stocks'] != null
            ? List.from(jsonData['data']['stocks'])
            : [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        stockList = [];
      });
      // Optionally: show a toast or dialog with error info
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stock for School ID: ${widget.schoolId}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stockList.length,
              itemBuilder: (context, index) {
                final item = stockList[index];
                // Get stock types and categories
                List<String> types = (item['stock_types'] as List)
                    .map((type) => type['type_name'].toString())
                    .toList();
                List<String> categories = (item['stock_categories'] as List)
                    .map((cat) => cat['category_name'].toString())
                    .toList();
                
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['product_name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Size: ${item['size']}'),
                        Text('Quantity: ${item['quantity']}'),
                        Text('Price: ${item['price']}'),
                        Text('Location: ${item['location']}'),
                        if (item['start_date'] != null && item['end_date'] != null)
                          Text('Period: ${item['start_date']} to ${item['end_date']}'),
                        SizedBox(height: 4),
                        Text('Types: ${types.join(", ")}'),
                        Text('Categories: ${categories.join(", ")}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
