import 'package:flutter/material.dart';
import 'package:krishi_mitra/data_helper.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Display names are written in the native script of each language.
  static const Map<String, String> _languages = {
    'English': 'English',
    'हिंदी': 'हिंदी',
    'தமிழ்': 'தமிழ்',
    'తెలుగు': 'తెలుగు',
    'বাংলা': 'বাংলা',
    'ગુજરાતી': 'ગુજરાતી',
    'मराठी': 'मराठी',
    'ਪੰਜਾਬੀ': 'ਪੰਜਾਬੀ',
    'اردو': 'اردو',
    'ಕನ್ನಡ': 'ಕನ್ನಡ',
    'മലയാളം': 'മലയാളം',
    'ଓଡ଼ିଆ': 'ଓଡ଼ିଆ',
  };

  String _selectedLang = 'English';

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final saved = await getData('language');
    if (mounted) {
      setState(() => _selectedLang = saved ?? 'English');
    }
    // final saved = await getData('language'); // null if never saved
    // if (saved != null) {
    //   // jump straight to the feature screen
    //   _selectedLang = saved;
    // }
  }

  Future<void> _onLangChanged(String? code) async {
    if (code == null) return;
    setState(() => _selectedLang = code);
    // _selectedLang = code;
    await saveData('language', code);
    // print("Language changed to $code");
    // Update the running app’s locale immediately.
    // MyApp.setLocale(context, Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          getTranslatedValue("Settings", _selectedLang) ?? 'Settings',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTranslatedValue("Language", _selectedLang) ?? 'Language',
              // AppLocalizations.of(context)?.language ?? 'Language',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLang,
                  isExpanded: true,
                  icon: const SizedBox.shrink(), // hides the arrow
                  onChanged: _onLangChanged,
                  items: _languages.entries
                      .map(
                        (e) => DropdownMenuItem<String>(
                      value: e.key,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Text(e.value, style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // const Center(child: Text('Settings Page Content')),
          ],
        ),
      ),
    );
  }
}
