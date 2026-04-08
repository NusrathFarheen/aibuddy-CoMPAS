import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/creations_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/about_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';
import 'widgets/sidebar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..loadAll(),
      child: const AIBuddyApp(),
    ),
  );
}

class AIBuddyApp extends StatelessWidget {
  const AIBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIBuddy (CoM-PAS)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00D9FF),
          surface: Color(0xFF1A1F3A),
          error: Color(0xFFFF6B6B),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const MainShell(),
        '/auth': (context) => const AuthScreen(),
      },
      initialRoute: '/',
    );
  }
}

// Removed mid-file imports

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    GoalsScreen(),
    HabitsScreen(),
    JournalScreen(),
    CreationsScreen(),
    ChatScreen(),
    ConnectScreen(), // 6: Connect
    Placeholder(), // 7: History
    Placeholder(), // 8: Notifications
    ArchiveScreen(), // 9: Archive
    RecommendationsScreen(), // 10: Recommended
    AiSettingsScreen(), // 11: Control Center
    AboutScreen(), // 12: About
  ];

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              if (index < _screens.length) {
                setState(() => _selectedIndex = index);
              }
            },
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
