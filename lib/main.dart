import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/browse_screen.dart';

void main() {
  runApp(const DogBreedDiaryApp());
}

class DogBreedDiaryApp extends StatefulWidget {
  const DogBreedDiaryApp({super.key});

  @override
  State<DogBreedDiaryApp> createState() => _DogBreedDiaryAppState();
}

class _DogBreedDiaryAppState extends State<DogBreedDiaryApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // read theme preference on startup
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = prefs.getBool('isDarkMode') ?? false);
  }

  // save theme preference and update ui
  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() => _isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Breed Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: BrowseScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}
