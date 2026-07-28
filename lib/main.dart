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
  Map<String, dynamic>? _user = {
    'name': 'Zaki Yusron',
    'email': 'yusron@dev.com',
    'role': 'admin',
    'is_admin': true,
  };

  void _changeTheme(NeoThemeData newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  void _handleLogin(Map<String, dynamic> user) {
    setState(() {
      _user = user;
      _isLoggedIn = true;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _user = null;
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
                  user: _user,
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
  final Map<String, dynamic>? user;
  final Function(NeoThemeData) onThemeChanged;
  final VoidCallback onLogout;

  const MainNavigationScreen({
    super.key,
    required this.theme,
    required this.user,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final int _unreadNotifications = 2; // Real-time notification badge counter

  void _showThemeSelector() {
    final t = widget.theme;
    final userName = widget.user?['name'] ?? 'User';
    final userRole = (widget.user?['role'] ?? 'user').toString().toUpperCase();

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: t.primary),
                      ),
                      Text(
                        'ROLE: $userRole',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: t.primary.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: t.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'PILIH TEMA WARNA (7 PALETTE)',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: t.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppThemes.allThemes.map((themeItem) {
                  final isSelected = widget.theme.id == themeItem.id;
                  return InkWell(
                    onTap: () {
                      widget.onThemeChanged(themeItem);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeItem.bg,
                        border: Border.all(
                          color: isSelected ? themeItem.accent : themeItem.primary,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeItem.primary,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: themeItem.accent,
                              border: Border.all(color: themeItem.primary, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            themeItem.label.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              color: themeItem.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('LOGOUT AKUN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
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
    final bool isAdmin = widget.user?['is_admin'] == true || widget.user?['role'] == 'admin';

    final List<Widget> screens = isAdmin
        ? [
            DashboardScreen(
              theme: t,
              onNavigateTab: (index) => setState(() => _currentIndex = index),
            ),
            QuickPostScreen(theme: t),
            UserChatScreen(theme: t, currentUser: widget.user),
            AiAssistantScreen(theme: t),
          ]
        : [
            DashboardScreen(
              theme: t,
              onNavigateTab: (index) => setState(() => _currentIndex = index),
            ),
            UserChatScreen(theme: t, currentUser: widget.user),
            AiAssistantScreen(theme: t),
          ];

    final List<BottomNavigationBarItem> navItems = isAdmin
        ? [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'DASHBOARD',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_box_rounded),
              label: 'POST PROJECT',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('$_unreadNotifications', style: const TextStyle(fontWeight: FontWeight.w900)),
                isLabelVisible: _unreadNotifications > 0,
                child: const Icon(Icons.chat_bubble_rounded),
              ),
              label: 'USER CHAT',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              label: 'AI HELPER',
            ),
          ]
        : [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('$_unreadNotifications', style: const TextStyle(fontWeight: FontWeight.w900)),
                isLabelVisible: _unreadNotifications > 0,
                child: const Icon(Icons.chat_bubble_rounded),
              ),
              label: 'CHAT ADMIN',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              label: 'AI HELPER',
            ),
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
                isAdmin ? 'NAOO.ADMIN' : 'NAOO.MOBILE',
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
            tooltip: 'Ganti Tema / Profile',
            onPressed: _showThemeSelector,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Logout Akun',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: screens[_currentIndex < screens.length ? _currentIndex : 0],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: t.primary,
          border: Border(top: BorderSide(color: t.primary, width: 4)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex < navItems.length ? _currentIndex : 0,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: t.primary,
          selectedItemColor: t.accent,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
          items: navItems,
        ),
      ),
    );
  }
}
