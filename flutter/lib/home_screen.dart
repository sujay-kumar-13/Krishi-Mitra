import 'package:flutter/material.dart';
import 'package:krishi_mitra/fert_calculator.dart';
import 'package:krishi_mitra/select_state.dart';
import 'package:krishi_mitra/settings_screen.dart';

import 'data_helper.dart';
import 'disease_detection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variable to hold the current language
  String _currentLanguage = 'English'; // Default initial value

  @override
  void initState() {
    super.initState();
    _loadLanguage(); // Load the language when the widget is initialized
  }

  // Asynchronous method to load the saved language
  Future<void> _loadLanguage() async {
    // getData() is now expected to return a non-nullable String (e.g., 'English')
    final String loadedLanguage = await getData('language') ?? 'English';
    if (mounted) { // Check if the widget is still in the widget tree before calling setState
      setState(() {
        _currentLanguage = loadedLanguage; // Update the state and trigger a rebuild
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3E4),
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0), // Half of the assumed width/height (30/2 = 15)
            child: Image.asset(
              'assets/app_icon.png', // Replace with your actual app icon path
              width: 30,
              height: 30,
              fit: BoxFit.cover, // Important to maintain aspect ratio and fill the circle
            ),
          ),
        ),
        title: Text(getTranslatedValue("Krishi Mitra", _currentLanguage) ?? 'Krishi Mitra', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async { // Make the onPressed callback async
              // Navigate to settings page and await the result from pop
              final bool? settingsChanged = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );

              // If settingsChanged is true (meaning we popped with true), reload the language
              if (settingsChanged == true) {
                _loadLanguage(); // This will fetch the new language and call setState, rebuilding the UI.
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1080 ? 4 : 2;

            return GridView.builder(
              itemCount: 4, // Adjust if you add more tiles
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final tiles = [
                  _buildHomeTile(
                    context: context,
                    title: getTranslatedValue("Crop Price", _currentLanguage) ?? 'Crop Price',
                    icon: Icons.info_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectStateScreen(function: "cropPrice", language: _currentLanguage),
                        ),
                      );
                    },
                  ),
                  _buildHomeTile(
                    context: context,
                    title: getTranslatedValue("Crop Demand", _currentLanguage) ?? 'Crop Demand',
                    icon: Icons.store,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectStateScreen(function: "cropDemand", language: _currentLanguage),
                        ),
                      );
                    },
                  ),
                  _buildHomeTile(
                    context: context,
                    title: "Fertilizer Calculator",
                    icon: Icons.calculate,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FertCalculator(language: _currentLanguage)),
                      );
                    },
                  ),
                  _buildHomeTile(
                    context: context,
                    title: getTranslatedValue("Pest Disease Detection", _currentLanguage) ?? "Pest & Disease Detection",
                    icon: Icons.bug_report,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DiseaseDetectionScreen(language: _currentLanguage,)
                        ),
                      );
                    },
                  ),
                ];
                return tiles[index];
              },
            );
          },
        ),

        // child: GridView.count(
        //   crossAxisCount: 2,
        //   crossAxisSpacing: 16.0,
        //   mainAxisSpacing: 16.0,
        //   children: <Widget>[
        //     _buildHomeTile(
        //       context: context,
        //       title: getTranslatedValue("Crop Price", _currentLanguage) ?? 'Crop Price',
        //       icon: Icons.info_outline,
        //       onTap: () async {
        //         // Navigate to Crop Information page
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               // builder: (context) => const CropInfoScreen()),
        //             builder: (context) => SelectStateScreen(function: "cropPrice", language: _currentLanguage, savedState: savedState)),
        //         );
        //       },
        //     ),
        //     _buildHomeTile(
        //       context: context,
        //       title: getTranslatedValue("Crop Demand", _currentLanguage) ?? 'Crop Demand',
        //       icon: Icons.store,
        //       onTap: () async {
        //         // Navigate to Market Prices page
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               // builder: (context) => const MarketPricesScreen()),
        //               builder: (context) => SelectStateScreen(function: "cropDemand", language: _currentLanguage, savedState: savedState)),
        //         );
        //       },
        //     ),
        //     _buildHomeTile(
        //       context: context,
        //       title: "Weather Forecast",
        //       icon: Icons.cloud,
        //       onTap: () async {
        //         // Navigate to Weather Forecast page
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               // builder: (context) => const WeatherForecastScreen()),
        //               builder: (context) => SelectStateScreen(function: "weatherForecast", language: _currentLanguage, savedState: savedState)),
        //         );
        //       },
        //     ),
        //     _buildHomeTile(
        //       context: context,
        //       title: "Pest & Disease Detection",
        //       icon: Icons.bug_report,
        //       onTap: () {
        //         // Navigate to Pest & Disease Detection page
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               // builder: (context) => const PestDetectionScreen()),
        //               builder: (context) => const DiseaseDetectionScreen()),
        //         );
        //       },
        //     ),
        //     // Add more tiles as needed
        //   ],
        // ),
      ),
      // bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHomeTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 40.0,
              color: Colors.green[900],
            ),
            const SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildBottomNavBar(BuildContext context) {
  //   return BottomNavigationBar(
  //     backgroundColor: Colors.green[900],
  //     selectedItemColor: Colors.white,
  //     unselectedItemColor: Colors.white70,
  //     items: const [
  //       BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
  //       BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "Chat Bot"),
  //       BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
  //     ],
  //     onTap: (index) {
  //       if (index == 0) {
  //         // Already on Home Screen
  //       } else if (index == 1) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => const ChatBotScreen()),
  //         );
  //       } else if (index == 2) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => const ProfileScreen()),
  //         );
  //       }
  //     },
  //   );
  // }
}