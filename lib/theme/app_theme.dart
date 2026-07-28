import 'package:flutter/material.dart';

class NeoThemeData {
  final String id;
  final String label;
  final Color bg;
  final Color primary;
  final Color accent;
  final Color cardBg;

  const NeoThemeData({
    required this.id,
    required this.label,
    required this.bg,
    required this.primary,
    required this.accent,
    required this.cardBg,
  });
}

class AppThemes {
  static const List<NeoThemeData> allThemes = [
    NeoThemeData(
      id: 'naoo',
      label: 'Classic Blue',
      bg: Color(0xFFF8F3EA),
      primary: Color(0xFF0B1957),
      accent: Color(0xFF9ECCFA),
      cardBg: Colors.white,
    ),
    NeoThemeData(
      id: 'dark',
      label: 'Deep Sea Dark',
      bg: Color(0xFF0A0E14),
      primary: Color(0xFFF4FEFE),
      accent: Color(0xFF1E3A46),
      cardBg: Color(0xFF14242C),
    ),
    NeoThemeData(
      id: 'retro',
      label: 'Retro Vintage',
      bg: Color(0xFFE8D8C9),
      primary: Color(0xFF4B607F),
      accent: Color(0xFFF3701E),
      cardBg: Color(0xFFFFF7ED),
    ),
    NeoThemeData(
      id: 'christmas',
      label: 'Christmas',
      bg: Color(0xFFF6E8DD),
      primary: Color(0xFF193564),
      accent: Color(0xFFDC3C24),
      cardBg: Colors.white,
    ),
    NeoThemeData(
      id: 'luxe',
      label: 'Luxe Caramel',
      bg: Color(0xFFF7ECE6),
      primary: Color(0xFF0D0D0F),
      accent: Color(0xFFCAA07D),
      cardBg: Colors.white,
    ),
    NeoThemeData(
      id: 'euro',
      label: 'Euro Retro',
      bg: Color(0xFFF4E5B2),
      primary: Color(0xFF253054),
      accent: Color(0xFFDC3C24),
      cardBg: Colors.white,
    ),
    NeoThemeData(
      id: 'cold',
      label: 'Cold Slate',
      bg: Color(0xFFEBEDE0),
      primary: Color(0xFF31394C),
      accent: Color(0xFF7A7F84),
      cardBg: Colors.white,
    ),
  ];
}

class BrutalCard extends StatelessWidget {
  final Widget child;
  final Color bgColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  const BrutalCard({
    super.key,
    required this.child,
    this.bgColor = Colors.white,
    this.borderColor = const Color(0xFF0B1957),
    this.borderWidth = 3.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
