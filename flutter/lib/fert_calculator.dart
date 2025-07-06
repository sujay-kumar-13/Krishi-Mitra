import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'data_helper.dart';

class FertCalculator extends StatefulWidget {
  final String language;

  const FertCalculator({super.key, required this.language});

  @override
  State<FertCalculator> createState() =>
      _FertCalculatorState();
}

class _FertCalculatorState extends State<FertCalculator> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController cropCtrl  = TextEditingController();
  final TextEditingController areaCtrl  = TextEditingController();
  String soilType = 'loamy';
  String growthStage = 'vegetative';

  bool loading = false;
  Map<String, dynamic>? result;

  @override
  void initState() {
    super.initState();
    _checkAndShowOnceMessage();
  }

  Future<void> _checkAndShowOnceMessage() async {
    final shown = await getData("shownWarning");

    if (shown != "true") {
      await Future.delayed(Duration(milliseconds: 500)); // slight delay so context is ready

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("This page is only available in English"),
            duration: const Duration(milliseconds: 2500),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              top: 16, left: 16, right: 16,
            ),
            backgroundColor: Colors.red[600],
          ),
        );
      }
      // await saveData("shownWarning", "true");
    }
  }


  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { loading = true; result = null; });

    final uri = Uri.parse('https://krishi-mitra-1080111382250.asia-south1.run.app/fertCalculator');
    final body = {
      "crop": cropCtrl.text.trim(),
      "area_ha": double.tryParse(areaCtrl.text.trim()) ?? 1.0,
      "soil_type": soilType,
      "growth_stage": growthStage,
    };

    try {
      final resp = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));

      print(resp.body); // for debugging
      if (resp.statusCode == 200) {
        setState(() => result = jsonDecode(resp.body));
      } else {
        _showError('API Error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      print(e.toString()); // for debugging
      _showError(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          getTranslatedValue("Fertilizer Requirement Calculator", widget.language) ?? "Fertilizer Requirement Calculator",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 720;
          final cardWidth = isNarrow
              ? constraints.maxWidth - 32 // 16 padding on each side
              : constraints.maxWidth * 0.6;

          return Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 6,
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: cropCtrl,
                          decoration: const InputDecoration(labelText: 'Crop name'),
                          validator: (v) => v!.isEmpty ? 'Enter crop' : null,
                        ),
                        TextFormField(
                          controller: areaCtrl,
                          decoration: const InputDecoration(labelText: 'Land area (ha)'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter area';
                            final val = double.tryParse(v);
                            if (val == null || val <= 0) return 'Enter a valid number > 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: soilType,
                          decoration: const InputDecoration(labelText: 'Soil type'),
                          items: ['sandy', 'loamy', 'clay'].map((s) =>
                              DropdownMenuItem(value: s, child: Text(s))
                          ).toList(),
                          onChanged: (v) => setState(() => soilType = v!),
                        ),
                        DropdownButtonFormField<String>(
                          value: growthStage,
                          decoration: const InputDecoration(labelText: 'Growth stage'),
                          items: ['vegetative', 'flowering', 'fruiting'].map((s) =>
                              DropdownMenuItem(value: s, child: Text(s))
                          ).toList(),
                          onChanged: (v) => setState(() => growthStage = v!),
                        ),
                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.center, // or Alignment.centerLeft/right
                          child: ElevatedButton(
                            onPressed: loading ? null : _calculate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: loading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                                'Get Recommendation',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        if (result != null) _buildResultCard(result!),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> r) {
    final fert = r['fertilizer'] as Map<String, dynamic>;
    final products = (fert['products'] as List)
        .map((p) => '${p['name']} – ${p['amount_kg']} kg')
        .join('\n');

    return Card(
      color: Colors.lightGreen[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For ${r['area_ha']} ha of ${r['crop']} (${r['soil_type']})',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('N: ${fert['N_kg']} kg  •  P: ${fert['P_kg']} kg  •  K: ${fert['K_kg']} kg'),
            const SizedBox(height: 8),
            Text('Suggested products:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(products),
            const SizedBox(height: 8),
            Text('Recommendation:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(r['notes']),
          ],
        ),
      ),
    );
  }
}
