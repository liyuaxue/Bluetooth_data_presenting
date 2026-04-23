import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  final String name;
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;

  const AppTheme({
    required this.name,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
  });
}

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';

  final List<AppTheme> themes = [
    // 基础主题
    AppTheme(
      name: '蓝色主题',
      primaryColor: const Color(0xFF1677FF),
      backgroundColor: const Color(0xFFB3EAFF),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF0D47A1),
    ),
    AppTheme(
      name: '绿色主题',
      primaryColor: const Color(0xFF00C853),
      backgroundColor: const Color(0xFFE8F5E8),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF1B5E20),
    ),
    AppTheme(
      name: '橙色主题',
      primaryColor: const Color(0xFFFF6D00),
      backgroundColor: const Color(0xFFFFECB3),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFFE65100),
    ),
    AppTheme(
      name: '紫色主题',
      primaryColor: const Color(0xFF7B1FA2),
      backgroundColor: const Color(0xFFE1BEE7),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF4A148C),
    ),

    // 新增红色系主题
    AppTheme(
      name: '红色主题',
      primaryColor: const Color(0xFFF44336),
      backgroundColor: const Color(0xFFFFEBEE),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFFB71C1C),
    ),
    AppTheme(
      name: '深红主题',
      primaryColor: const Color(0xFFC62828),
      backgroundColor: const Color(0xFFFFCDD2),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF7F0000),
    ),

    // 新增粉色系主题
    AppTheme(
      name: '粉色主题',
      primaryColor: const Color(0xFFE91E63),
      backgroundColor: const Color(0xFFFCE4EC),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF880E4F),
    ),
    AppTheme(
      name: '玫红主题',
      primaryColor: const Color(0xFFAD1457),
      backgroundColor: const Color(0xFFF8BBD0),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF4A148C),
    ),

    // 新增青色系主题
    AppTheme(
      name: '青色主题',
      primaryColor: const Color(0xFF00BCD4),
      backgroundColor: const Color(0xFFE0F7FA),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF006064),
    ),
    AppTheme(
      name: '蓝绿主题',
      primaryColor: const Color(0xFF009688),
      backgroundColor: const Color(0xFFE0F2F1),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF004D40),
    ),

    // 新增深色系主题
    AppTheme(
      name: '深蓝主题',
      primaryColor: const Color(0xFF1976D2),
      backgroundColor: const Color(0xFFE3F2FD),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF0D47A1),
    ),
    AppTheme(
      name: '深紫主题',
      primaryColor: const Color(0xFF512DA8),
      backgroundColor: const Color(0xFFEDE7F6),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF311B92),
    ),

    // 新增大地色系主题
    AppTheme(
      name: '棕色主题',
      primaryColor: const Color(0xFF795548),
      backgroundColor: const Color(0xFFEFEBE9),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF3E2723),
    ),
    AppTheme(
      name: '卡其主题',
      primaryColor: const Color(0xFF8D6E63),
      backgroundColor: const Color(0xFFF5F5F5),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF4E342E),
    ),

    // 新增鲜艳色系主题
    AppTheme(
      name: '黄色主题',
      primaryColor: const Color(0xFFFFEB3B),
      backgroundColor: const Color(0xFFFFFDE7),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFFF57F17),
    ),
    AppTheme(
      name: '亮橙主题',
      primaryColor: const Color(0xFFFF9800),
      backgroundColor: const Color(0xFFFFF3E0),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFFE65100),
    ),

    // 新增冷色调主题
    AppTheme(
      name: '冰蓝主题',
      primaryColor: const Color(0xFF03A9F4),
      backgroundColor: const Color(0xFFE1F5FE),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF01579B),
    ),
    AppTheme(
      name: '薄荷主题',
      primaryColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFFE8F5E9),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF1B5E20),
    ),

    // 新增渐变风格主题
    AppTheme(
      name: '海洋主题',
      primaryColor: const Color(0xFF2196F3),
      backgroundColor: const Color(0xFFE3F2FD),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF0D47A1),
    ),
    AppTheme(
      name: '森林主题',
      primaryColor: const Color(0xFF388E3C),
      backgroundColor: const Color(0xFFE8F5E9),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF1B5E20),
    ),

    // 新增专业风格主题
    AppTheme(
      name: '商务蓝',
      primaryColor: const Color(0xFF1565C0),
      backgroundColor: const Color(0xFFE3F2FD),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF0D47A1),
    ),
    AppTheme(
      name: '石墨灰',
      primaryColor: const Color(0xFF455A64),
      backgroundColor: const Color(0xFFECEFF1),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF263238),
    ),

    // 新增节日主题
    AppTheme(
      name: '圣诞红绿',
      primaryColor: const Color(0xFFD32F2F),
      backgroundColor: const Color(0xFFE8F5E9),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF1B5E20),
    ),
    AppTheme(
      name: '情人节',
      primaryColor: const Color(0xFFE91E63),
      backgroundColor: const Color(0xFFFCE4EC),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF880E4F),
    ),

    // 新增自然主题
    AppTheme(
      name: '天空蓝',
      primaryColor: const Color(0xFF42A5F5),
      backgroundColor: const Color(0xFFE3F2FD),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF1565C0),
    ),
    AppTheme(
      name: '草地绿',
      primaryColor: const Color(0xFF66BB6A),
      backgroundColor: const Color(0xFFE8F5E9),
      cardColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF2E7D32),
    ),
  ];

  int _selectedThemeIndex = 0;

  AppTheme get currentTheme => themes[_selectedThemeIndex];
  int get selectedThemeIndex => _selectedThemeIndex;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedThemeIndex = prefs.getInt(_themeKey) ?? 0;
    notifyListeners();
  }

  Future<void> setTheme(int index) async {
    if (index >= 0 && index < themes.length) {
      _selectedThemeIndex = index;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, index);
      notifyListeners();
    }
  }

  ThemeData get themeData {
    final theme = currentTheme;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: theme.primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: theme.backgroundColor,
      cardColor: theme.cardColor,
      appBarTheme: AppBarTheme(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: theme.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 按颜色分类获取主题
  List<AppTheme> get blueThemes => themes.where((theme) {
    final color = theme.primaryColor;
    return color.red < 100 && color.blue > 150 && color.green < 150;
  }).toList();

  List<AppTheme> get greenThemes => themes.where((theme) {
    final color = theme.primaryColor;
    return color.green > 150 && color.red < 100 && color.blue < 100;
  }).toList();

  List<AppTheme> get redThemes => themes.where((theme) {
    final color = theme.primaryColor;
    return color.red > 150 && color.green < 100 && color.blue < 100;
  }).toList();

  List<AppTheme> get purpleThemes => themes.where((theme) {
    final color = theme.primaryColor;
    return color.blue > 100 && color.red > 100 && color.green < 100;
  }).toList();

  // 获取热门主题（前8个）
  List<AppTheme> get popularThemes => themes.sublist(0, 8);

  // 获取最新主题（后8个）
  List<AppTheme> get newThemes => themes.sublist(themes.length - 8);
}
