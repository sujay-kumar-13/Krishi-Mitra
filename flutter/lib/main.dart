import 'package:flutter/material.dart';
import 'package:krishi_mitra/data_helper.dart';
import 'package:krishi_mitra/home_screen.dart';
import 'package:krishi_mitra/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? shownWelcome = await getData('shownWelcome');

  runApp(MyApp(showWelcome: shownWelcome == null,));
}

class MyApp extends StatelessWidget {
  final bool showWelcome;
  const MyApp({super.key, required this.showWelcome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Krishi Mitra',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: showWelcome ? WelcomeScreen() : HomeScreen(),
    );
  }
}
