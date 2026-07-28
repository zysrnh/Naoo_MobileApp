import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class UserChatScreen extends StatefulWidget {
  final NeoThemeData theme;
  final Map<String, dynamic>? currentUser;

  const UserChatScreen({
    super.key,
    required this.theme,
    this.currentUser,
  });

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  List<dynamic> _userList = [];
  Map<String, dynamic>? _selectedUser;
  List<dynamic> _messages = [];
  bool _loadingUsers = true;
  bool _loadingChat = false;
  bool _sending = false;

  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    final users = await ApiService.fetchDirectUsers();
    if (mounted) {
      setState(() {
        _userList = users;
        _loadingUsers = false;
      });
    }
  }

  Future<void> _loadChatHistory(Map<String, dynamic> user) async {
    setState(() {
      _selectedUser = user;
      _loadingChat = true;
    });
    final receiverId = user['id'] as int;
    final currentUserId = widget.currentUser != null ? (widget.currentUser!['id'] as int?) : null;
    final history = await ApiService.fetchDirectHistory(receiverId, currentUserId: currentUserId);
    if (mounted) {
      setState(() {
        _messages = history;
        _loadingChat = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _selectedUser == null || _sending) return;

    final receiverId = _selectedUser!['id'] as int;
    final currentUserId = widget.currentUser != null ? (widget.currentUser!['id'] as int?) : null;

    _msgController.clear();
    setState(() {
      _sending = true;
      // Instant local optimism append (No blank / No refresh flicker!)
      _messages.add({
        'sender_id': currentUserId ?? 9999,
        'receiver_id': receiverId,
        'message': text,
        'created_at': DateTime.now().toString(),
      });
    });

    final ok = await ApiService.sendDirectMessage(receiverId, text, senderId: currentUserId);
    if (mounted) {
      setState(() => _sending = false);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan direct.')),
        );
      }
    }
  }

  void _simulatedAttachment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lampiran file/foto dari galeri HP terhubung.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    final myName = widget.currentUser != null ? (widget.currentUser!['name'] ?? 'PENGUNJUNG').toString().toUpperCase() : 'TAMU PORTFOLIO';
    final myEmail = widget.currentUser != null ? (widget.currentUser!['email'] ?? 'pengunjung@naoo.id').toString() : 'guest@naoo.id';
    final myRole = widget.currentUser != null ? (widget.currentUser!['role'] ?? 'User').toString().toUpperCase() : 'GUEST';

    // SCENARIO 1: PRIVATE 1-ON-1 CHAT ROOM
    if (_selectedUser != null) {
      final targetName = (_selectedUser!['name'] ?? 'User').toString().toUpperCase();
      final targetEmail = (_selectedUser!['email'] ?? '').toString();

      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(
          backgroundColor: t.primary,
          elevation: 2,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: t.accent),
            onPressed: () => setState(() => _selectedUser = null),
          ),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: t.accent,
                  border: Border.all(color: t.bg, width: 2),
                ),
                child: Center(
                  child: Text(
                    targetName.substring(0, 1),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: t.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      targetName,
                      style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    Text(
                      targetEmail,
                      style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: t.accent),
              onPressed: () => _loadChatHistory(_selectedUser!),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _loadingChat
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
                                    'Belum ada riwayat pesan 1-on-1.',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: t.primary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kirim pesan pertama kamu ke $targetName.',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.primary.withValues(alpha: 0.6)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: _messages.length,
                          itemBuilder: (ctx, i) {
                            final m = Map<String, dynamic>.from(_messages[i]);
                            final content = (m['message'] ?? '').toString();
                            final date = (m['created_at'] ?? '').toString();
                            final receiverId = m['receiver_id'] as int?;
                            final targetId = _selectedUser!['id'] as int;
                            final isUserMsg = receiverId == targetId;

                            return Align(
                              alignment: isUserMsg ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width * 0.78),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUserMsg ? t.accent : t.cardBg,
                                  border: Border.all(color: t.primary, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: t.primary,
                                      offset: const Offset(3, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: isUserMsg ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: t.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      date.length > 16 ? date.substring(0, 16) : date,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: t.primary.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        hintText: 'Ketik pesan private 1-on-1...',
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

    // SCENARIO 2: DIRECT USER CONTACTS LIST WITH CURRENT LOGGED IN USER BADGE
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
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _loadingUsers
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // LOGGED IN USER ACCOUNT CARD
                  BrutalCard(
                    bgColor: t.accent,
                    borderColor: t.primary,
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: t.primary,
                            border: Border.all(color: t.primary, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              myName.substring(0, 1),
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: t.accent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'AKUN KAMU: ',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: t.primary.withValues(alpha: 0.6)),
                                  ),
                                  Text(
                                    myName,
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: t.primary),
                                  ),
                                ],
                              ),
                              Text(
                                myEmail,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: t.primary.withValues(alpha: 0.8)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: t.primary,
                          ),
                          child: Text(
                            myRole,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: t.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'PILIH USER TERDAFTAR UNTUK DIAJAK CHAT',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5, color: t.primary),
                    ),
                  ),

                  if (_userList.isEmpty)
                    BrutalCard(
                      bgColor: t.cardBg,
                      borderColor: t.primary,
                      child: Center(
                        child: Text(
                          'Belum ada user terdaftar di database.',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: t.primary),
                        ),
                      ),
                    )
                  else
                    ..._userList.map((u) {
                      final userMap = Map<String, dynamic>.from(u);
                      final name = (userMap['name'] ?? 'User').toString().toUpperCase();
                      final email = (userMap['email'] ?? '').toString();
                      final role = (userMap['role'] ?? 'User').toString().toUpperCase();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: () => _loadChatHistory(userMap),
                          child: BrutalCard(
                            bgColor: t.cardBg,
                            borderColor: t.primary,
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: t.accent,
                                    border: Border.all(color: t.primary, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      name.substring(0, 1),
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: t.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: t.primary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: t.primary,
                                            ),
                                            child: Text(
                                              role,
                                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: t.accent),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: t.primary.withValues(alpha: 0.7)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.chevron_right_rounded, color: t.primary),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
