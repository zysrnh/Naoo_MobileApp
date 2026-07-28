import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  final NeoThemeData theme;
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.theme,
    required this.onNavigateTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int visitors = 0;
  int pageviews = 0;
  List<dynamic> projects = [];
  bool loading = true;
  int _carouselIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    final statsData = await ApiService.fetchDashboardStats();
    final projectsData = await ApiService.fetchProjects();
    if (mounted) {
      setState(() {
        visitors = statsData['total_visitors'] ?? 0;
        pageviews = statsData['total_pageviews'] ?? 0;
        projects = projectsData;
        loading = false;
      });
    }
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    final t = widget.theme;
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.black.withValues(alpha: 0.9),
          insetPadding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'PREVIEW GAMBAR PROJECT (PINCH TO ZOOM)',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: t.primary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Expanded(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Center(
                      child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProjectDetail(Map<String, dynamic> project) {
    final t = widget.theme;
    final title = (project['title'] ?? 'Project').toString().toUpperCase();
    final subtitle = project['subtitle'] ?? '';
    final desc = project['desc'] ?? '';
    final longDesc = project['long_desc'] ?? project['longDesc'] ?? desc;
    final status = (project['status'] ?? 'Hosted').toString();
    final date = (project['date'] ?? '2026').toString();
    final duration = (project['duration'] ?? '2 Minggu').toString();
    final demoUrl = project['demo_url'] ?? project['demoUrl'] ?? '';
    final githubUrl = project['github_url'] ?? project['githubUrl'] ?? '';
    final workType = (project['work_type'] ?? project['workType'] ?? 'Solo').toString();
    final soloRole = project['solo_role'] ?? project['soloRole'] ?? 'Fullstack Developer';
    final List<dynamic> collaborators = project['collaborators'] ?? [];
    final List<dynamic> features = project['features'] ?? [];
    List<dynamic> images = [];
    final rawImages = project['images'];
    if (rawImages != null) {
      if (rawImages is List) {
        images = List<dynamic>.from(rawImages);
      } else if (rawImages is String) {
        try {
          final decoded = json.decode(rawImages);
          if (decoded is List) {
            images = decoded;
          } else if (decoded is String && decoded.isNotEmpty) {
            images = [decoded];
          }
        } catch (_) {
          if (rawImages.trim().isNotEmpty) {
            images = [rawImages];
          }
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.bg,
            border: Border(top: BorderSide(color: t.primary, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: t.primary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: t.primary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    // Status & Work Type Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.accent,
                            border: Border.all(color: t.primary, width: 2),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: t.primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.primary,
                          ),
                          child: Text(
                            workType.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: t.accent),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: t.primary.withValues(alpha: 0.8)),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Images Gallery
                    if (images.isNotEmpty) ...[
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (ctx, i) {
                            final fullUrl = ApiService.formatImageUrl(images[i].toString());
                            return InkWell(
                              onTap: () => _showImagePreview(context, fullUrl),
                              child: Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: t.primary, width: 2),
                                ),
                                child: Image.network(
                                  fullUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    color: t.cardBg,
                                    child: Icon(Icons.image_not_supported_rounded, color: t.primary),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Info Meta Cards
                    Row(
                      children: [
                        Expanded(child: _buildDetailMetaCard('TANGGAL', date, t)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildDetailMetaCard('DURASI', duration, t)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Work Type Details (Solo Role or Collaborators List)
                    BrutalCard(
                      bgColor: t.cardBg,
                      borderColor: t.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workType == 'Solo' ? 'PERAN TIM SOLO' : 'DAFTAR REKAN TIM KOLABORASI',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary),
                          ),
                          const SizedBox(height: 6),
                          if (workType == 'Solo')
                            Text(
                              soloRole,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: t.primary),
                            )
                          else if (collaborators.isEmpty)
                            Text(
                              'Belum ada rincian kolaborator.',
                              style: TextStyle(fontSize: 11, color: t.primary.withValues(alpha: 0.6)),
                            )
                          else
                            ...collaborators.map((c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_rounded, size: 14, color: t.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${c['name'] ?? ''} - ${c['role'] ?? ''} (${c['origin'] ?? ''})',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: t.primary),
                                      ),
                                    ],
                                  ),
                                )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description Section
                    BrutalCard(
                      bgColor: t.cardBg,
                      borderColor: t.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DESKRIPSI LENGKAP (CASE STUDY)',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            longDesc.isEmpty ? desc : longDesc,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.primary.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Features List Section
                    if (features.isNotEmpty) ...[
                      BrutalCard(
                        bgColor: t.cardBg,
                        borderColor: t.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FITUR UNGGULAN PROJECT',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary),
                            ),
                            const SizedBox(height: 8),
                            ...features.map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 14, color: t.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (f['title'] ?? '').toString(),
                                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: t.primary),
                                            ),
                                            if (f['desc'] != null && f['desc']!.toString().isNotEmpty)
                                              Text(
                                                f['desc'].toString(),
                                                style: TextStyle(fontSize: 10, color: t.primary.withValues(alpha: 0.7)),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // External Links
                    if (demoUrl.isNotEmpty || githubUrl.isNotEmpty) ...[
                      Row(
                        children: [
                          if (demoUrl.isNotEmpty)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: t.accent, border: Border.all(color: t.primary, width: 2)),
                                child: Text('LIVE DEMO: $demoUrl', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: t.primary), overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          if (demoUrl.isNotEmpty && githubUrl.isNotEmpty) const SizedBox(width: 10),
                          if (githubUrl.isNotEmpty)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: t.primary, border: Border.all(color: t.primary, width: 2)),
                                child: Text('GITHUB: $githubUrl', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: t.accent), overflow: TextOverflow.ellipsis),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailMetaCard(String label, String value, NeoThemeData t) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: t.cardBg, border: Border.all(color: t.primary, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: t.primary)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: t.primary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    final carouselItems = [
      {
        'icon': Icons.add_box_rounded,
        'title': 'POST PROJECT BARU',
        'subtitle': 'Publish karya terbaru kamu langsung ke website dalam 1-klik.',
        'tab': 1,
      },
      {
        'icon': Icons.chat_bubble_rounded,
        'title': 'DIRECT USER CHAT',
        'subtitle': 'Pantau obrolan 1-on-1 dengan pengunjung terdaftar website.',
        'tab': 2,
      },
      {
        'icon': Icons.smart_toy_rounded,
        'title': 'AI NAOO HELPER',
        'subtitle': 'Tanya jawab seputar koding & arsitektur ke asisten virtual.',
        'tab': 3,
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'NEO-BRUTALIST THEMES',
        'subtitle': 'Nikmati 7 variasi skema warna tema Neo-Brutalist real-time.',
        'tab': -1,
      },
    ];

    return Scaffold(
      backgroundColor: t.bg,
      body: RefreshIndicator(
        color: t.accent,
        backgroundColor: t.primary,
        strokeWidth: 3.5,
        elevation: 6,
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            // Welcome Hero Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BrutalCard(
                bgColor: t.primary,
                borderColor: t.primary,
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: t.accent,
                        border: Border.all(color: t.bg, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          'Z',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            color: t.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HALO, ZAKI YUSRON!',
                            style: TextStyle(
                              color: t.accent,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mobile Control Center Naoo.id',
                            style: TextStyle(
                              color: t.bg.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Traffic Stats Widget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BrutalCard(
                bgColor: t.accent,
                borderColor: t.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'REAL-TIME VISITORS STATS',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1.0,
                            color: t.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox('VISITORS', visitors.toString(), t),
                        _buildStatBox('PAGEVIEWS', pageviews.toString(), t),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // HORIZONTAL CAROUSEL SLIDER SECTION (STRICT NO EMOJIS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FITUR UTAMA (CAROUSEL SLIDER)',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.0,
                      color: t.primary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'SWIPE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          color: t.primary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 16,
                        color: t.primary.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // CAROUSEL SLIDER WITH CLEAN VECTOR ACTION BUTTON
            SizedBox(
              height: 155,
              child: PageView.builder(
                controller: _pageController,
                itemCount: carouselItems.length,
                onPageChanged: (index) => setState(() => _carouselIndex = index),
                itemBuilder: (context, index) {
                  final item = carouselItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: BrutalCard(
                      bgColor: t.cardBg,
                      borderColor: t.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: t.accent,
                                  border: Border.all(color: t.primary, width: 2),
                                ),
                                child: Icon(item['icon'] as IconData, size: 22, color: t.primary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item['title'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: t.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            item['subtitle'].toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: t.primary.withValues(alpha: 0.7),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  final tab = item['tab'] as int;
                                  if (tab >= 0) widget.onNavigateTab(tab);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: t.primary,
                                    border: Border.all(color: t.primary, width: 2),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: t.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // CAROUSEL DOT INDICATORS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                carouselItems.length,
                (index) => Container(
                  width: _carouselIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _carouselIndex == index ? t.primary : t.primary.withValues(alpha: 0.3),
                    border: Border.all(color: t.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Projects Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'PROJECTS TERDAFTAR (KLIK UNTUK DETAIL)',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.0,
                  color: t.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : projects.isEmpty
                      ? BrutalCard(
                          bgColor: t.cardBg,
                          borderColor: t.primary,
                          child: Center(
                            child: Text(
                              'Belum ada project terdaftar di server.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: t.primary,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: projects.map((p) {
                            String? thumbUrl;
                            final rawImgs = p['images'];
                            if (rawImgs != null) {
                              if (rawImgs is List && rawImgs.isNotEmpty) {
                                thumbUrl = rawImgs.first.toString();
                              } else if (rawImgs is String) {
                                try {
                                  final decoded = json.decode(rawImgs);
                                  if (decoded is List && decoded.isNotEmpty) {
                                    thumbUrl = decoded.first.toString();
                                  } else if (decoded is String && decoded.isNotEmpty) {
                                    thumbUrl = decoded;
                                  }
                                } catch (_) {
                                  if (rawImgs.trim().isNotEmpty) thumbUrl = rawImgs;
                                }
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: InkWell(
                                onTap: () => _showProjectDetail(Map<String, dynamic>.from(p)),
                                child: BrutalCard(
                                  bgColor: t.cardBg,
                                  borderColor: t.primary,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: t.accent,
                                        border: Border.all(color: t.primary, width: 2),
                                      ),
                                      child: thumbUrl != null && thumbUrl.isNotEmpty
                                          ? Image.network(
                                              ApiService.formatImageUrl(thumbUrl),
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Center(
                                                child: Icon(Icons.code_rounded, color: t.primary, size: 26),
                                              ),
                                            )
                                          : Center(
                                              child: Icon(Icons.folder_special_rounded, color: t.primary, size: 26),
                                            ),
                                    ),
                                    title: Text(
                                      (p['title'] ?? 'Project').toString().toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: t.primary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      p['desc'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: t.primary.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: t.accent,
                                        border: Border.all(color: t.primary, width: 2),
                                      ),
                                      child: Text(
                                        (p['status'] ?? 'Live').toString().toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                          color: t.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, NeoThemeData t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: t.bg,
        border: Border.all(color: t.primary, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 9,
              color: t.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: t.primary,
            ),
          ),
        ],
      ),
    );
  }
}
