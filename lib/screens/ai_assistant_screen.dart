import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AiAssistantScreen extends StatefulWidget {
  final NeoThemeData theme;

  const AiAssistantScreen({super.key, required this.theme});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<Map<String, String>> _messages = [
    {'sender': 'bot', 'text': 'Halo Zaki! Aku Naoo Helper AI. Ada yang bisa aku bantu seputar coding atau website kamu?'}
  ];
  final _inputController = TextEditingController();
  bool _typing = false;

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _typing) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _typing = true;
    });
    _inputController.clear();

    final reply = await ApiService.askAi(text);

    if (mounted) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': reply});
        _typing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.primary,
        title: Text(
          'NAOO HELPER AI',
          style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser ? t.primary : t.cardBg,
                      border: Border.all(color: t.primary, width: 2),
                      boxShadow: [
                        BoxShadow(color: t.primary, offset: const Offset(3, 3)),
                      ],
                    ),
                    child: Text(
                      m['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? t.accent : t.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_typing) LinearProgressIndicator(color: t.primary),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.cardBg,
              border: Border(top: BorderSide(color: t.primary, width: 3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: t.primary),
                    decoration: InputDecoration(
                      hintText: 'Tanya Naoo Helper AI...',
                      hintStyle: TextStyle(color: t.primary.withValues(alpha: 0.4), fontSize: 11),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: t.primary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
