import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final NeoThemeData theme;
  final VoidCallback onFinish;

  const SplashScreen({
    super.key,
    required this.theme,
    required this.onFinish,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  int _progress = 0;
  String _statusText = 'INITIALIZING SYSTEM...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _animController.forward();

    // Progress counter timer (0% -> 100%)
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_progress < 100) {
        setState(() {
          _progress += 2;
          if (_progress == 30) _statusText = 'LOADING NEO THEME SYSTEM...';
          if (_progress == 65) _statusText = 'CONNECTING LARAVEL BACKEND...';
          if (_progress == 90) _statusText = 'NAOO CONTROL CORE READY!';
        });
      } else {
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) widget.onFinish();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return Scaffold(
      backgroundColor: t.bg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Logo Card
                  BrutalCard(
                    bgColor: t.primary,
                    borderColor: t.primary,
                    borderWidth: 4.0,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: t.accent,
                                border: Border.all(color: t.bg, width: 3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'NAOO.MOBILE',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                color: t.accent,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'CONTROL SYSTEM v1.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: t.bg.withValues(alpha: 0.85),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Progress Bar & Percentage Box
                  BrutalCard(
                    bgColor: t.cardBg,
                    borderColor: t.primary,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _statusText,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                color: t.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '$_progress%',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: t.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Loading Bar Container
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: t.bg,
                            border: Border.all(color: t.primary, width: 2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress / 100,
                            child: Container(
                              color: t.accent,
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
        ),
      ),
    );
  }
}
