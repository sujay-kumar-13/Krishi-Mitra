import 'package:flutter/material.dart';
import 'package:krishi_mitra/home_screen.dart';
import 'package:krishi_mitra/data_helper.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // @override
  // State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen> {
  // ‑‑‑ Supported languages shown to the user ‑‑‑
  final List<_LangOption> _langs = const [
    _LangOption('English', 'English'),
    _LangOption('Hindi', 'हिंदी'),
    _LangOption('Tamil', 'தமிழ்'),
    _LangOption('Telugu', 'తెలుగు'),
    _LangOption('Marathi', 'मराठी'),
    _LangOption('Bengali', 'বাংলা'),
    _LangOption('Gujarati', 'ગુજરાતી'),
    _LangOption('Kannada', 'ಕನ್ನಡ'),
    _LangOption('Malayalam', 'മലയാളം'),
    _LangOption('Punjabi', 'ਪੰਜਾਬੀ'),
    _LangOption('Oria', 'ଓଡ଼ିଆ'),
    _LangOption('Urdu', 'اردو'),
  ];

  // @override
  // void initState() {
  //   super.initState();
  // }

  // Save language + first‑run flag, then go Home.
  Future<void> _goHome(BuildContext ctx, {String code = 'English'}) async {
    // language = code;
    await saveData('language', code); // remember choice / default
    await saveData('shownWelcome', 'true'); // don’t show again

    Navigator.pushReplacement(
      ctx,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 1080 ? 2 : 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3E4),
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              'assets/app_icon.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Text(
          'Welcome to Krishi Mitra',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _goHome(context),
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Farmer Image
                Center(child: Image.asset('assets/farmer_image.png', height: 160)),

                const SizedBox(height: 20),

                Text(
                  "Choose Language",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),

                const SizedBox(height: 10),

                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 80),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 3.2,
                  ),
                  itemCount: _langs.length,
                  itemBuilder: (_, i) {
                    final lang = _langs[i];
                    return _LangTile(
                      option: lang,
                      onTap: () => _goHome(context, code: lang.code),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────── Helper data class ─────────────────
class _LangOption {
  final String name; // Native‑script label
  final String code; // ISO locale code
  const _LangOption(this.name, this.code);
}

// ───────────────── Language tile widget ─────────────────
class _LangTile extends StatelessWidget {
  final _LangOption option;
  final VoidCallback onTap;
  const _LangTile({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            option.code,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
