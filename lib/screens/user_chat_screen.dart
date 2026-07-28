import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class UserChatScreen extends StatefulWidget {
  final NeoThemeData theme;

  const UserChatScreen({super.key, required this.theme});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  List<dynamic> _messages = [];
  bool _loading = true;
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController(text: 'Pengunjung');
  final TextEditingController _senderEmailController = TextEditingController(text: 'user@naoo.id');

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    final msgs = await ApiService.fetchUserMessages();
    if (mounted) {
      setState(() {
        _messages = msgs;
        _loading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final name = _senderNameController.text.trim().isEmpty ? 'Pengunjung Mobile' : _senderNameController.text.trim();
    final email = _senderEmailController.text.trim().isEmpty ? 'user@naoo.id' : _senderEmailController.text.trim();

    _msgController.clear();

    final ok = await ApiService.sendUserMessage({
      'name': name,
      'email': email,
      'message': text,
    });

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesan berhasil terkirim ke server!')),
        );
      }
      _loadMessages();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan ke server.')),
        );
      }
    }
  }

  void _simulatedAttachment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Lampiran Foto/File terhubung dengan galeri HP.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.primary,
        title: Text(
          'DIRECT USER CHAT (1-ON-1)',
          style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: t.accent),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats Box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: BrutalCard(
              bgColor: t.accent,
              borderColor: t.primary,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: t.primary, border: Border.all(color: t.primary, width: 2)),
                    child: Icon(Icons.chat_bubble_rounded, size: 20, color: t.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SISTEM PESAN DIREK 1-ON-1',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: t.primary),
                        ),
                        Text(
                          '${_messages.length} pesan tersimpan di database',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: t.primary.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Messages List View
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: BrutalCard(
                            bgColor: t.cardBg,
                            borderColor: t.primary,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.forum_outlined, size: 36, color: t.primary),
                                const SizedBox(height: 10),
                                Text(
                                  'Belum ada pesan masuk di database.',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: t.primary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kirim pesan pertama kamu lewat form di bawah ini.',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.primary.withValues(alpha: 0.6)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMessages,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: _messages.length,
                          itemBuilder: (ctx, i) {
                            final m = _messages[i];
                            final senderName = (m['name'] ?? 'Pengunjung').toString();
                            final senderEmail = (m['email'] ?? '').toString();
                            final content = (m['message'] ?? '').toString();
                            final createdAt = (m['created_at'] ?? '').toString();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: BrutalCard(
                                bgColor: t.cardBg,
                                borderColor: t.primary,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(color: t.accent, border: Border.all(color: t.primary, width: 2)),
                                              child: Center(
                                                child: Text(
                                                  senderName.substring(0, 1).toUpperCase(),
                                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              senderName.toUpperCase(),
                                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: t.primary),
                                            ),
                                          ],
                                        ),
                                        if (senderEmail.isNotEmpty)
                                          Text(
                                            senderEmail,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: t.primary.withValues(alpha: 0.6)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      content,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: t.primary.withValues(alpha: 0.95)),
                                    ),
                                    if (createdAt.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          createdAt.length > 16 ? createdAt.substring(0, 16) : createdAt,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: t.primary.withValues(alpha: 0.5)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),

          // Chat Input Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.primary,
              border: Border(top: BorderSide(color: t.primary, width: 4)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file_rounded, color: t.accent),
                  tooltip: 'Lampirkan Foto/File',
                  onPressed: _simulatedAttachment,
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: t.primary),
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan 1-on-1...',
                      hintStyle: TextStyle(color: t.primary.withValues(alpha: 0.5), fontSize: 11),
                      filled: true,
                      fillColor: t.bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderSide: BorderSide(color: t.primary, width: 2), borderRadius: BorderRadius.zero),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: t.accent, width: 3), borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: t.accent,
                      border: Border.all(color: t.bg, width: 2),
                    ),
                    child: Icon(Icons.send_rounded, color: t.primary, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
