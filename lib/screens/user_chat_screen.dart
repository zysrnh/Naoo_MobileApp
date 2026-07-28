import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UserChatScreen extends StatelessWidget {
  final NeoThemeData theme;

  const UserChatScreen({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.primary,
        title: Text(
          'DIRECT USER CHAT',
          style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BrutalCard(
            bgColor: t.cardBg,
            borderColor: t.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 52, color: t.primary),
                const SizedBox(height: 14),
                Text(
                  'OBROLAN USER 1-ON-1',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: t.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fitur chat langsung terhubung ke sistem pesan 1-on-1 backend Laravel portofolio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.primary.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
