import 'package:flutter/material.dart';
import 'ui/theme_data.dart';
import 'ui/calculator_screen.dart';

void main() {
  runApp(const CalculatorApp());
}

/// The root application widget supporting dynamic light and dark theme toggling.
class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  // Theme state: dark mode by default for high readability
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
      child: MaterialApp(
        title: 'Calculator State Lab',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: CalculatorScreen(
          isDarkMode: _isDarkMode,
          onToggleTheme: _toggleTheme,
        ),
      ),
    );
  }
}
