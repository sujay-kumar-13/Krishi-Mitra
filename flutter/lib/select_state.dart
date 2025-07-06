import 'package:flutter/material.dart';
import 'package:krishi_mitra/data_helper.dart'; // <‑‑ add this
import 'package:krishi_mitra/crops_demand.dart';
import 'package:krishi_mitra/crops_price.dart';
import 'package:krishi_mitra/disease_detection_screen.dart';
import 'package:krishi_mitra/fert_calculator.dart';

class SelectStateScreen extends StatefulWidget {
  final String  function; // "cropPrice" | "cropDemand" | "weatherForecast" | "disease"
  final String language;
  const SelectStateScreen({super.key, required this.function, required this.language});

  @override
  State<SelectStateScreen> createState() => _SelectStateScreenState();
}

class _SelectStateScreenState extends State<SelectStateScreen> {
  String? _selectedState;
  final List<String> _indianStates = [
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

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final saved = await getData('selectedState'); // null if never saved
    if (saved != null) {
      // jump straight to the feature screen
      _navigateToNextScreen(context, saved, widget.language, widget.function, replace: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3E4),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          getTranslatedValue("Select State", widget.language) ?? 'Select State',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      body: ListView.builder(
        itemCount: _indianStates.length,
        itemBuilder: (context, index) {
          final state = _indianStates[index];
          return ListTile(
            title: Text(getTranslatedValue(state, widget.language) ?? state),
            onTap: () async {
              setState(() => _selectedState = state);
              // save selected state
              await saveData('selectedState', state);
              _navigateToNextScreen(context, state, widget.language, widget.function);
            },
            selected: _selectedState == state,
            selectedTileColor: Colors.green[100],
          );
        },
      ),
    );
  }

  void _navigateToNextScreen(
    BuildContext context,
    String state,
    String language,
    String feature, {
    bool replace = false,
  }) {
    late final Widget nextPage;
    switch (feature) {
      case "cropPrice":
        nextPage = CropsPrice(selectedState: state, language: language);
        break;
      case "cropDemand":
        nextPage = CropsDemand(selectedState: state, language: language);
        break;
      default:
        nextPage = const Scaffold(
          body: Center(child: Text("Error: Unknown function")),
        );
    }

    final route = MaterialPageRoute(builder: (_) => nextPage);
    replace
        ? Navigator.pushReplacement(context, route) // used when we auto‑skip
        : Navigator.push(context, route); // normal flow after tap
  }
}

