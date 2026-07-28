import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class QuickPostScreen extends StatefulWidget {
  final NeoThemeData theme;

  const QuickPostScreen({super.key, required this.theme});

  @override
  State<QuickPostScreen> createState() => _QuickPostScreenState();
}

class _QuickPostScreenState extends State<QuickPostScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descController = TextEditingController();
  final _longDescController = TextEditingController();
  final _dateController = TextEditingController(text: '2026');
  final _durationController = TextEditingController(text: '2 Minggu');
  final _demoUrlController = TextEditingController();
  final _githubUrlController = TextEditingController();
  final _soloRoleController = TextEditingController(text: 'Fullstack Developer');

  String _status = 'Hosted';
  String _workType = 'Solo';
  bool _submitting = false;

  final List<Map<String, String>> _collaborators = [];

  void _addCollaborator() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final originCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final t = widget.theme;
        return AlertDialog(
          backgroundColor: t.bg,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'TAMBAH KOLABORATOR',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: t.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('NAMA KOLABORATOR *', nameCtrl, 'contoh: Riaa Riyanti', t),
              const SizedBox(height: 10),
              _buildTextField('PERAN / ROLE *', roleCtrl, 'contoh: UI/UX Designer', t),
              const SizedBox(height: 10),
              _buildTextField('ASAL INSTANSI / KAMPUS', originCtrl, 'contoh: IDE LPKIA', t),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('BATAL', style: TextStyle(fontWeight: FontWeight.bold, color: t.primary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary,
                foregroundColor: t.accent,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty && roleCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _collaborators.add({
                      'name': nameCtrl.text.trim(),
                      'role': roleCtrl.text.trim(),
                      'origin': originCtrl.text.trim(),
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('TAMBAH →', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitProject() async {
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    final desc = _descController.text.trim();
    final longDesc = _longDescController.text.trim();

    if (title.isEmpty || subtitle.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul, Subtitle, dan Deskripsi Singkat wajib diisi!')),
      );
      return;
    }

    setState(() => _submitting = true);

    final ok = await ApiService.createProject({
      'title': title,
      'subtitle': subtitle,
      'desc': desc,
      'long_desc': longDesc.isEmpty ? desc : longDesc,
      'status': _status,
      'date': _dateController.text.trim().isEmpty ? '2026' : _dateController.text.trim(),
      'duration': _durationController.text.trim().isEmpty ? '2 Minggu' : _durationController.text.trim(),
      'demo_url': _demoUrlController.text.trim(),
      'github_url': _githubUrlController.text.trim(),
      'work_type': _workType,
      'solo_role': _workType == 'Solo' ? _soloRoleController.text.trim() : null,
      'collaborators': _workType == 'Collaboration' ? _collaborators : [],
      'visible': true,
      'order': 0,
    });

    setState(() => _submitting = false);

    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project berhasil diposting ke Database Website!')),
        );
        _titleController.clear();
        _subtitleController.clear();
        _descController.clear();
        _longDescController.clear();
        _demoUrlController.clear();
        _githubUrlController.clear();
        setState(() {
          _collaborators.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal posting project. Cek koneksi server Laravel.')),
        );
      }
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
          'POST PROJECT BARU',
          style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // LIVE PREVIEW BOX (ISOLATED LISTENERS FOR HIGH PERFORMANCE)
          Text(
            'LIVE CARD PREVIEW (TAMPILAN DI WEB)',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.0,
              color: t.primary,
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder(
            valueListenable: _titleController,
            builder: (context, _, __) {
              return ValueListenableBuilder(
                valueListenable: _subtitleController,
                builder: (context, _, __) {
                  return ValueListenableBuilder(
                    valueListenable: _descController,
                    builder: (context, _, __) {
                      return BrutalCard(
                        bgColor: t.cardBg,
                        borderColor: t.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _titleController.text.isEmpty
                                        ? 'JUDUL PROJECT'
                                        : _titleController.text.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: t.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: t.accent,
                                    border: Border.all(color: t.primary, width: 2),
                                  ),
                                  child: Text(
                                    _status.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                      color: t.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_subtitleController.text.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _subtitleController.text,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: t.primary.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              _descController.text.isEmpty
                                  ? 'Deskripsi singkat project akan muncul di sini...'
                                  : _descController.text,
                              style: TextStyle(
                                fontSize: 11,
                                color: t.primary.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: t.primary,
                                  ),
                                  child: Text(
                                    _workType.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 8,
                                      color: t.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // FORM INPUTS
          BrutalCard(
            bgColor: t.cardBg,
            borderColor: t.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FORM DATABASE PROJECT',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: t.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField('JUDUL PROJECT *', _titleController, 'contoh: Naoo Portfolio Web', t),
                const SizedBox(height: 12),
                _buildTextField('SUBTITLE / SLUG RINGKAS *', _subtitleController, 'contoh: Modern Fullstack Web App', t),
                const SizedBox(height: 12),
                _buildTextField('DESKRIPSI SINGKAT *', _descController, 'Penjelasan singkat 1-2 kalimat...', t, maxLines: 2),
                const SizedBox(height: 12),
                _buildTextField('DESKRIPSI LENGKAP (CASE STUDY)', _longDescController, 'Penjelasan lengkap tantangan & arsitektur...', t, maxLines: 4),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField('TANGGAL / TAHUN', _dateController, '2026', t)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('DURASI', _durationController, '2 Minggu', t)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('LIVE DEMO URL', _demoUrlController, 'https://mysite.com', t),
                const SizedBox(height: 12),
                _buildTextField('GITHUB REPO URL', _githubUrlController, 'https://github.com/user/repo', t),
                const SizedBox(height: 12),

                // WORK TYPE & STATUS
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _status,
                            dropdownColor: t.cardBg,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderSide: BorderSide(color: t.primary, width: 2), borderRadius: BorderRadius.zero),
                            ),
                            items: ['Hosted', 'In Progress', 'Planning']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: t.primary))))
                                .toList(),
                            onChanged: (val) => setState(() => _status = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TIPE PEKERJAAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _workType,
                            dropdownColor: t.cardBg,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderSide: BorderSide(color: t.primary, width: 2), borderRadius: BorderRadius.zero),
                            ),
                            items: ['Solo', 'Collaboration']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: t.primary))))
                                .toList(),
                            onChanged: (val) => setState(() => _workType = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // DYNAMIC FIELD: SOLO VS COLLABORATION
                if (_workType == 'Solo') ...[
                  _buildTextField('PERAN SOLO (SOLO ROLE)', _soloRoleController, 'contoh: Fullstack Developer & Lead', t),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('REKAN TIM KOLABORASI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('TAMBAH REKAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.primary,
                          foregroundColor: t.accent,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onPressed: _addCollaborator,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_collaborators.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: t.bg,
                        border: Border.all(color: t.primary, width: 1.5),
                      ),
                      child: Text(
                        'Belum ada rekan tim ditambahkan. Klik "+ TAMBAH REKAN".',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: t.primary.withValues(alpha: 0.6)),
                      ),
                    )
                  else
                    ..._collaborators.asMap().entries.map((entry) {
                      final i = entry.key;
                      final col = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: t.accent,
                          border: Border.all(color: t.primary, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${col['name']} (${col['role']})',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary),
                                ),
                                if (col['origin'] != null && col['origin']!.isNotEmpty)
                                  Text(
                                    col['origin']!,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: t.primary.withValues(alpha: 0.8)),
                                  ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, size: 16, color: t.primary),
                              onPressed: () {
                                setState(() {
                                  _collaborators.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submitProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.primary,
                      foregroundColor: t.accent,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: t.primary, width: 2),
                      ),
                    ),
                    child: _submitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'PUBLISH PROJECT KE DATABASE →',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    NeoThemeData t, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: t.primary),
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }
}
