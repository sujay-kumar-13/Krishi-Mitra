import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'data_helper.dart';

class PriceTrendPage extends StatefulWidget {
  final String selectedState;
  final String cropName;
  final String language;

  const PriceTrendPage({
    super.key,
    required this.selectedState,
    required this.cropName,
    required this.language,
  });

  @override
  State<PriceTrendPage> createState() => _PriceTrendPageState();
}

class _PriceTrendPageState extends State<PriceTrendPage> {
  String? selectedState;
  String? cropName;
  String? language;
  String selectedPeriod = "Next Month";
  List<String> periodOptions = [
    "Next Month",
    "Next 3 Months",
    "Next 6 Months",
    "Next 1 Year",
  ];
  List<Map<String, dynamic>> monthlyPredictions = [];
  List<Map<String, dynamic>> pastPredictions = [];
  final oCcy = NumberFormat('##,##,##0');
  bool _isLoading = false; // Added to track loading state

  @override
  void initState() {
    super.initState();
    selectedState = widget.selectedState;
    cropName = widget.cropName;
    language = widget.language;
    updatePredictions("Next Month");
  }

  void updatePredictions(String period) async {
    setState(() {
      _isLoading = true; // Start loading
    });
    selectedPeriod = period;
    try {
      List<Map<String, dynamic>> predictions = await generateMonthlyPredictions(
        selectedState!,
        cropName!,
        period,
      );
      List<Map<String, dynamic>> past = await pastMonthsData(
        selectedState!,
        cropName!,
        period,
      );

      // Sort the data here, after it's fetched
      predictions.sort((a, b) {
        int aYear = _getYearFromMonth(a['month'] ?? '');
        int aMonth = _getMonthNumber(a['month'] ?? '');
        int bYear = _getYearFromMonth(b['month'] ?? '');
        int bMonth = _getMonthNumber(b['month'] ?? '');
        if (aYear != bYear) {
          return aYear.compareTo(bYear);
        }
        return aMonth.compareTo(bMonth);
      });
      past.sort((a, b) {
        int aYear = _getYearFromMonth(a['month'] ?? '');
        int aMonth = _getMonthNumber(a['month'] ?? '');
        int bYear = b['year'] ?? DateTime.now().year;
        int bMonth = _getMonthNumber(b['month'] ?? '01-2025');
        if (aYear != bYear) {
          return aYear.compareTo(bYear);
        }
        return aMonth.compareTo(bMonth);
      });

      setState(() {
        monthlyPredictions = predictions;
        pastPredictions = past;
        _isLoading = false; // Stop loading
      });
    } catch (e) {
      print("Error in updatePredictions: $e"); //important
      setState(() {
        _isLoading = false;
      });
      //show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> generateMonthlyPredictions(
    String state,
    String crop,
    String period,
  ) async {
    int months;
    if (period == "Next Month") {
      months = 1;
    } else if (period == "Next 3 Months") {
      months = 3;
    } else if (period == "Next 6 Months") {
      months = 6;
    } else {
      months = 12;
    }

    List<Map<String, dynamic>> predictions = [];
    DateTime now = DateTime.now();
    DateTime month = DateTime(now.year, now.month + 1);
    DateTime periodMonth = DateTime(now.year, now.month + months);
    predictions.addAll(await predictPrice(state, crop, month, periodMonth));

    return predictions;
  }

  Future<List<Map<String, dynamic>>> pastMonthsData(
    String state,
    String crop,
    String period,
  ) async {
    List<Map<String, dynamic>> past = [];
    DateTime now = DateTime.now();
    DateTime month = DateTime(now.year, now.month);
    past.addAll(await fetchPastPrices(state, crop, month));
    return past;
  }

  Future<List<Map<String, dynamic>>> predictPrice(
    String state,
    String crop,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final apiURL = 'https://krishi-mitra-1080111382250.asia-south1.run.app/predict';

    try {
      final response = await http.post(
        Uri.parse(apiURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'state': state,
          'crop': crop,
          'startMonth': startDate.month,
          'startYear': startDate.year,
          'endMonth': endDate.month,
          'endYear': endDate.year,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> pastPricesData = jsonDecode(response.body);
        return pastPricesData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to predict price: ${response.statusCode}');
      }
    } catch (e) {
      print('Error predicting price: $e');
      throw e; // rethrow the error to be caught in updatePredictions
      //return []; //changed
    }
  }

  Future<List<Map<String, dynamic>>> fetchPastPrices(
    String state,
    String crop,
    DateTime month,
  ) async {
    final apiUrl = 'https://krishi-mitra-1080111382250.asia-south1.run.app/pastPrices';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'state': state,
          'crop': crop,
          'year': month.year,
          'month': month.month,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> pastPricesData = jsonDecode(response.body);
        return pastPricesData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch past prices: ${response.body}');
      }
    } catch (e) {
      print('Error fetching past prices: $e');
      throw e; //rethrow
      //return []; //changed
    }
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> allSpots = [];
    List<String> allMonths = [];

    // Combine past and predicted data, ensuring consistent sorting
    List<Map<String, dynamic>> combinedData = [
      ...pastPredictions,
      ...monthlyPredictions,
    ];
    combinedData.sort((a, b) {
      // Parse month and year for accurate comparison
      int aYear = _getYearFromMonth(a['month'] ?? '');
      int aMonth = _getMonthNumber(a['month'] ?? '');
      int bYear = _getYearFromMonth(b['month'] ?? '');
      int bMonth = _getMonthNumber(b['month'] ?? '');

      if (aYear != bYear) {
        return aYear.compareTo(bYear);
      }
      return aMonth.compareTo(bMonth);
    });

    // Create FlSpot data for the graph
    for (int i = 0; i < combinedData.length; i++) {
      double price = combinedData[i]["price"]?.toDouble() ?? 0.0;
      allSpots.add(FlSpot(i.toDouble(), price));
      allMonths.add(combinedData[i]["month"] ?? "");
    }
    double minY =
        allSpots.isNotEmpty
            ? allSpots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) -
                10
            : 0;
    double maxY =
        allSpots.isNotEmpty
            ? allSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) +
                10
            : 100;

    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${getTranslatedValue(cropName!, language!) ?? cropName} ${getTranslatedValue("Price Trend", language!) ?? 'Price Trend'}",
          // "$cropName Price Trend",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   "${widget.cropName} Price Trend",
              //   style: const TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.brown,
              //   ),
              // ),
              // const SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${getTranslatedValue('Prediction Period', language!) ?? 'Prediction Period'} ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.brown[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPeriod,
                        isExpanded: false,
                        onChanged: (String? newValue) {
                          if (newValue != null) updatePredictions(newValue);
                        },
                        items: periodOptions.map((String period) {
                          return DropdownMenuItem<String>(
                            value: period,
                            child: Text(getTranslatedValue(period, language!) ?? period),
                          );
                        }).toList(),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.brown),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              Container(
                height: 300,
                color: Colors.green[50],
                padding: const EdgeInsets.all(8),
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.brown),
                        ) // Loading indicator for graph
                        : allSpots.isNotEmpty
                        ? LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              drawHorizontalLine: true,
                              getDrawingHorizontalLine: (value) {
                                return const FlLine(
                                  color: Colors.lightGreen,
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return const FlLine(
                                  color: Colors.lightGreen,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 0 &&
                                        index < allMonths.length) {
                                      return Text(
                                        translateMonthYear(allMonths[index], language!),
                                        // allMonths[index],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.brown,
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  interval: 1,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '₹ ${oCcy.format(value.toInt())}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.brown,
                                      ),
                                    );
                                  },
                                  reservedSize: 40,
                                  interval:
                                      (maxY - minY) > 5
                                          ? ((maxY - minY) / 5).roundToDouble()
                                          : 1,
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.brown, width: 2),
                            ),
                            minX: 0,
                            maxX: allSpots.length.toDouble() - 1,
                            minY: minY,
                            maxY: maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: allSpots,
                                isCurved: true,
                                color: Colors.brown,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.brown.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        )
                        : Center(
                          child: Text(
                            getTranslatedValue("No Price Data", language!) ?? "No price data available to display.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
              ),
              const SizedBox(height: 15),

              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWideScreen = constraints.maxWidth > 1080;

                  Widget pastPricesWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${getTranslatedValue('Past 6 months prices', language!) ?? "Past 6 months prices"}:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWideScreen ? constraints.maxWidth / 2 - 20 : double.infinity),
                        child: _isLoading
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: SizedBox(
                            height: 40,
                            child: Center(child: CircularProgressIndicator(color: Colors.brown)),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pastPredictions.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.yellow[200],
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(
                                  translateMonthYear(pastPredictions[index]["month"], language!),
                                  // pastPredictions[index]["month"],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                                ),
                                trailing: Text(
                                  "₹ ${oCcy.format(pastPredictions[index]["price"])}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );

                  Widget futurePricesWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${getTranslatedValue('Future Price Predictions', language!) ?? "Future Price Predictions"}:",
                        // "Future Price Predictions:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWideScreen ? constraints.maxWidth / 2 - 20 : double.infinity),
                        child: _isLoading
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: SizedBox(
                            height: 40,
                            child: Center(child: CircularProgressIndicator(color: Colors.brown)),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: monthlyPredictions.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.yellow[100],
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(
                                  translateMonthYear(monthlyPredictions[index]["month"], language!),
                                  // monthlyPredictions[index]["month"],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                                ),
                                trailing: Text(
                                  "₹ ${oCcy.format(monthlyPredictions[index]["price"])}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );

                  if (isWideScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        pastPricesWidget,
                        const SizedBox(width: 16),
                        futurePricesWidget,
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        pastPricesWidget,
                        const SizedBox(height: 16),
                        futurePricesWidget,
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to convert month name to number
  int _getMonthNumber(String month) {
    try {
      // Attempt to parse the month string as "MM substring"
      List<String> parts = month.split(' ');
      if (parts.length == 2) {
        String monthName = parts[0].trim().toLowerCase();
        Map<String, int> monthMap = {
          'january': 1,
          'february': 2,
          'march': 3,
          'april': 4,
          'may': 5,
          'june': 6,
          'july': 7,
          'august': 8,
          'september': 9,
          'october': 10,
          'november': 11,
          'december': 12,
        };
        int? monthNumber = monthMap[monthName];
        if (monthNumber != null) {
          return monthNumber;
        }
      }
    } catch (e) {
      // Handle any parsing errors
      print("Error parsing month: $e");
    }
    // If the month is not in "MM substring" format, or parsing fails, return 1.
    return 1;
  }

  // Helper function to extract the year from the month string
  int _getYearFromMonth(String month) {
    try {
      List<String> parts = month.split(' ');
      if (parts.length == 2) {
        int? year = int.tryParse(parts[1].trim());
        if (year != null) {
          return year;
        }
      }
    } catch (e) {
      print("Error parsing year: $e");
    }
    // Default year
    return DateTime.now().year;
  }
}
