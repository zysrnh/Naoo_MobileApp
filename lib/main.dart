import 'package:flutter/material.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/quick_post_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/user_chat_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NaooMobileApp());
}

class NaooMobileApp extends StatefulWidget {
  const NaooMobileApp({super.key});

  @override
  State<NaooMobileApp> createState() => _NaooMobileAppState();
}

class _NaooMobileAppState extends State<NaooMobileApp> {
  NeoThemeData _currentTheme = AppThemes.allThemes[0]; // Default Classic Blue
  bool _showSplash = true;
  bool _isLoggedIn = true;
  String _userEmail = 'yusron@dev.com';

  void _changeTheme(NeoThemeData newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  void _handleLogin(String email, String password) {
    setState(() {
      _userEmail = email;
      _isLoggedIn = true;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naoo Mobile Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _currentTheme.bg,
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: _currentTheme.primary,
          primary: _currentTheme.primary,
          secondary: _currentTheme.accent,
        ),
      ),
      home: _showSplash
          ? SplashScreen(
              theme: _currentTheme,
              onFinish: () => setState(() => _showSplash = false),
            )
          : _isLoggedIn
              ? MainNavigationScreen(
                  theme: _currentTheme,
                  userEmail: _userEmail,
                  onThemeChanged: _changeTheme,
                  onLogout: _handleLogout,
                )
              : LoginScreen(
                  theme: _currentTheme,
                  onLoginSuccess: _handleLogin,
                ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final NeoThemeData theme;
  final String userEmail;
  final Function(NeoThemeData) onThemeChanged;
  final VoidCallback onLogout;

  const MainNavigationScreen({
    super.key,
    required this.theme,
    required this.userEmail,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _showThemeSelector() {
    final t = widget.theme;

    showModalBottomSheet(
      context: context,
      backgroundColor: t.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.bg,
            border: Border(top: BorderSide(color: t.primary, width: 4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PILIH TEMA WARNA (7 PALETTE)',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: t.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: t.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppThemes.allThemes.map((themeItem) {
                  final isSelected = widget.theme.id == themeItem.id;
                  return InkWell(
                    onTap: () {
                      widget.onThemeChanged(themeItem);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeItem.bg,
                        border: Border.all(
                          color: isSelected ? themeItem.accent : themeItem.primary,
                          width: isSelected ? 3.5 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeItem.primary,
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: themeItem.accent,
                              border: Border.all(color: themeItem.primary, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            themeItem.label.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: themeItem.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('LOGOUT AKUN ADMIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onLogout();
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    final List<Widget> screens = [
      DashboardScreen(
        theme: t,
        onNavigateTab: (index) => setState(() => _currentIndex = index),
      ),
      QuickPostScreen(theme: t),
      UserChatScreen(theme: t),
      AiAssistantScreen(theme: t),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: t.primary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: t.accent,
                border: Border.all(color: t.bg, width: 2),
              ),
              child: Text(
                'NAOO.MOBILE',
                style: TextStyle(
                  color: t.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.palette_rounded, color: t.accent),
            tooltip: 'Ganti Tema / Control',
            onPressed: _showThemeSelector,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: t.primary,
          border: Border(top: BorderSide(color: t.primary, width: 4)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: t.primary,
          selectedItemColor: t.accent,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_rounded),
              label: 'POST PROJECT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'USER CHAT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              label: 'AI HELPER',
            ),
          ],
        ),
      ),
    );
  }
}
