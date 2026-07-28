import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final NeoThemeData theme;
  final Function(Map<String, dynamic> user) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.theme,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'yusron@dev.com');
  final _passwordController = TextEditingController(text: 'password');
  bool _loading = false;

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password wajib diisi!')),
      );
      return;
    }

    setState(() => _loading = true);

    final user = await ApiService.login(email, pass);

    setState(() => _loading = false);

    if (mounted) {
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat datang, ${user['name']}! (${user['role'] ?? 'User'})')),
        );
        widget.onLoginSuccess(user);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal Login: Email/Password salah atau server tidak terhubung.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return Scaffold(
      backgroundColor: t.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Box
              BrutalCard(
                bgColor: t.primary,
                borderColor: t.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: t.accent,
                        border: Border.all(color: t.bg, width: 2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'NAOO.MOBILE CONTROL',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: t.accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Login Form Card
              BrutalCard(
                bgColor: t.cardBg,
                borderColor: t.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOGIN AKUN PORTOFOLIO',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: t.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masukan akun terdaftar dari website (Admin atau User). Hak akses akan otomatis diselaraskan.',
                      style: TextStyle(
                        fontSize: 11,
                        color: t.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    Text(
                      'EMAIL AKUN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: t.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: t.primary),
                      decoration: InputDecoration(
                        hintText: 'yusron@dev.com',
                        hintStyle: TextStyle(color: t.primary.withValues(alpha: 0.4), fontSize: 11),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: t.primary, width: 2),
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: t.primary, width: 3),
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password Field
                    Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: t.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: t.primary),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: t.primary.withValues(alpha: 0.4), fontSize: 11),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: t.primary, width: 2),
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: t.primary, width: 3),
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.primary,
                          foregroundColor: t.accent,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: t.primary, width: 2),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'MASUK KE APLIKASI →',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
