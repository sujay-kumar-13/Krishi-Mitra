import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krishi_mitra/data_helper.dart';
import 'package:krishi_mitra/demand_trend_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropsDemand extends StatefulWidget {
  final String selectedState;
  final String language;

  const CropsDemand({super.key, required this.selectedState, required this.language});

  @override
  State<CropsDemand> createState() => _CropsDemandState();
}

class _CropsDemandState extends State<CropsDemand> {
  String? selectedState;
  String? language;
  bool isLoading = false;

  final List<String> states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
  ];

  List<Map<String, dynamic>> demandData = [];

  @override
  void initState() {
    super.initState();
    selectedState = widget.selectedState;
    language = widget.language;
    _fetchCropData();
  }

  // Function to fetch crops data from the Python API
  Future<List<Map<String, dynamic>>> fetchCropsData(
    String selectedState,
    String previousMonth,
    String nextMonth,
  ) async {
    final apiUrl =
        'https://krishi-mitra-1080111382250.asia-south1.run.app/cropsCollection'; // Replace with your Flask API URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'selectedState': selectedState,
        'previousMonth': previousMonth,
        'nextMonth': nextMonth,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> cropsData = jsonDecode(response.body)['crops'];
      return cropsData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch crops data: ${response.body}');
    }
  }

  // Function to calculate percentage change and determine if the change is positive
  List<Map<String, dynamic>> processCropsDemandData(
    List<Map<String, dynamic>> cropsData,
  ) {
    List<Map<String, dynamic>> processedCrops = [];

    for (final crop in cropsData) {
      final double previousMonthDemand = crop['previousMonthDemand'].toDouble();
      final double nextMonthDemand = crop['nextMonthDemand'].toDouble();

      // Calculate percentage change
      final change =
          (nextMonthDemand - previousMonthDemand) / previousMonthDemand * 100;
      final isPositive = nextMonthDemand >= previousMonthDemand;

      processedCrops.add({
        'name': crop['name'],
        'previousMonthDemand': previousMonthDemand.round(),
        'nextMonthDemand': nextMonthDemand.round(),
        'change': change.round(),
        'positive': isPositive,
      });
    }

    return processedCrops;
  }

  Future<void> _fetchCropData() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    if (selectedState == null) return;

    try {
      final state = selectedState!;
      // final state = 'Maharashtra';
      // final previousMonth = '01-2023';
      // final nextMonth = '02-2023';
      final now = DateTime.now();
      final DateFormat formatter = DateFormat('MM-yyyy'); // Format as MM-YYYY
      final DateTime previousMonthDate = DateTime(now.year, now.month - 1);
      final DateTime nextMonthDate = DateTime(now.year, now.month + 1);
      final previousMonth = formatter.format(previousMonthDate);
      final nextMonth = formatter.format(nextMonthDate);
      // print(previousMonth);
      // print(nextMonth);

      // Fetch crops data from the API
      final cropsData = await fetchCropsData(state, previousMonth, nextMonth);

      // Process the fetched crops data
      final processedDemand = processCropsDemandData(cropsData);

      // Add processed crops data to the existing list
      // cropsCollectionData.addAll(processedCrops);
      setState(() {
        demandData = processedDemand;
        isLoading = false; // Set loading state to false
      });

      // Print the updated crops list in terminal
      // for (final crop in demandData) {
      //   print(crop);
      // }
      // if(cropsData.isEmpty) print("List is empty");
    } catch (e) {
      print('Error fetching crop data: $e');
      setState(() {
        isLoading = false; // Set loading state to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          getTranslatedValue("Crop Demand", language!) ?? "Crops Demand",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      backgroundColor: Colors.lightGreen[100],
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${getTranslatedValue("Crops in", language!) ?? 'Crops in'} ",
                  // "Crops in ",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                // Dropdown for selecting state
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.brown[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedState,
                      isExpanded: false,
                      onChanged: (newValue) async {
                        await saveData('selectedState', newValue!);
                        setState(() {
                          selectedState = newValue;
                          _fetchCropData(); // Fetch data when the selected state changes
                        });
                      },
                      items:
                          states.map((state) {
                            return DropdownMenuItem(
                              value: state,
                              child: Text(getTranslatedValue(state, language!) ?? state),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Loading Indicator or List View
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : demandData.isEmpty
                      ? Center(
                        child: Text(
                          getTranslatedValue("No Crop Data", language!) ?? 'No crop data available for this state.',
                          style: TextStyle(fontSize: 18, color: Colors.brown),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          // Adjust number of columns and aspect ratio based on screen width
                          double width = constraints.maxWidth;
                          int crossAxisCount = width > 1080 ? 2 : 1;
                          double aspectRatio;
                          if (width < 350) {
                            aspectRatio = 2.4;
                          } else if (width < 450) {
                            aspectRatio = 3;
                          } else if (width < 600) {
                            aspectRatio = 4;
                          } else if (width < 700) {
                            aspectRatio = 5;
                          } else if (width < 850) {
                            aspectRatio = 6;
                          } else if (width < 1080) {
                            aspectRatio = 7;
                          } else if (width < 1280) {
                            aspectRatio = 5;
                          } else {
                            aspectRatio = 6;
                          }
                          return GridView.builder(
                            itemCount: demandData.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio:
                                  aspectRatio, // Adjust for card height/width balance
                            ),
                            itemBuilder: (context, index) {
                              final crop = demandData[index];

                              return Center(
                                // Center + ConstrainedBox for fixed max width
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 700,
                                    // maxHeight: 115,
                                  ),
                                  child: DemandCard(
                                    state: selectedState!,
                                    name: crop["name"],
                                    previousMonthDemand: crop["previousMonthDemand"],
                                    nextMonthDemand: crop["nextMonthDemand"],
                                    change: crop["change"],
                                    isPositive: crop["positive"],
                                    language: language!,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class DemandCard extends StatelessWidget {
  final String state;
  final String name;
  final String language;
  final int previousMonthDemand;
  final int nextMonthDemand;
  final int change;
  final bool isPositive;

  const DemandCard({
    super.key,
    required this.state,
    required this.name,
    required this.language,
    required this.previousMonthDemand,
    required this.nextMonthDemand,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    DemandTrendPage(selectedState: state, cropName: name, language: language),
          ),
        );
      },
      child: Card(
        color: Colors.lightGreen[50],
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          // side: BorderSide(color: Colors.green[700]!),
          side: BorderSide(color: Colors.black),
        ),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslatedValue(name, language) ?? name,
                    // name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                      "${getTranslatedValue("This Month", language) ?? 'This Month'} : $previousMonthDemand Q",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    "${getTranslatedValue("Next Month", language) ?? 'Next Month'} : $nextMonthDemand Q",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  Text(
                    "$change %",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
