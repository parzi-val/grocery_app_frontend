import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:grocery_frontend/utils/auth.dart';
import 'package:grocery_frontend/utils/log_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  AnalyticsPageState createState() => AnalyticsPageState();
}

class AnalyticsPageState extends State<AnalyticsPage> {
  List<CategoryData> _categoryData = [];
  List<SalesData> _salesData = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoryData();
    _fetchSalesData();
  }

  Future<void> _fetchCategoryData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/analytics/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await Auth.getUser()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _categoryData = data.map((e) {
            return CategoryData(e['category'], e['quantity'].toDouble());
          }).toList();
        });
      } else {
        throw Exception('Failed to load category data');
      }
    } catch (error) {
      LogService.i("Error fetching category data: $error");
    }
  }

  Future<void> _fetchSalesData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5000/api/analytics/sales?startDate=2024-01-01&endDate=2024-12-31'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await Auth.getUser()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _salesData = data.map((e) {
            return SalesData(
              DateTime.parse(e['_id']),
              e['totalOrders'],
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load sales data');
      }
    } catch (error) {
      LogService.i("Error fetching sales data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analytics"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Breakdown
              Text(
                "Category Breakdown",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _categoryData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SfCircularChart(
                          legend: Legend(isVisible: true),
                          series: <PieSeries<CategoryData, String>>[
                            PieSeries<CategoryData, String>(
                              dataSource: _categoryData,
                              xValueMapper: (CategoryData data, _) =>
                                  data.category,
                              yValueMapper: (CategoryData data, _) =>
                                  data.quantity,
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true),
                            )
                          ],
                        ),
                      ),
                    ),
              SizedBox(height: 30),

              // Sales Frequency Over Time
              Text(
                "Sales Frequency Over Time",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _salesData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.MMMd(),
                            intervalType: DateTimeIntervalType.days,
                          ),
                          primaryYAxis: NumericAxis(
                            labelFormat: '{value}',
                          ),
                          series: <ChartSeries<SalesData, DateTime>>[
                            LineSeries<SalesData, DateTime>(
                              dataSource: _salesData,
                              xValueMapper: (SalesData data, _) => data.date,
                              yValueMapper: (SalesData data, _) =>
                                  data.totalOrders,
                              markerSettings: MarkerSettings(isVisible: true),
                            )
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model for Category Data (Pie Chart)
class CategoryData {
  final String category;
  final double quantity;

  CategoryData(this.category, this.quantity);
}

// Model for Sales Data (Line Chart)
class SalesData {
  final DateTime date;
  final int totalOrders;

  SalesData(this.date, this.totalOrders);
}
