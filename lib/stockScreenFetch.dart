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
        'https://metrogarments.metrogarments.mu/api/school-stock?school_id=${widget.schoolId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        // Safely check if products is null
        stockList =
            jsonData['data'] != null && jsonData['data']['products'] != null
                ? List.from(jsonData['data']['products'])
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
                return ListTile(
                  title: Text(item['product_name']),
                  subtitle: Text(
                      "Category: ${item['category']}\nPrice: ${item['price']}"),
                );
              },
            ),
    );
  }
}
