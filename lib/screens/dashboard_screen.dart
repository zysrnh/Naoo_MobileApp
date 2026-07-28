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

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    final carouselItems = [
      {
        'icon': Icons.add_box_rounded,
        'title': 'POST PROJECT BARU',
        'subtitle': 'Publish karya terbaru kamu langsung ke website dalam 1-klik.',
        'actionText': 'BUKA FORM POSTING →',
        'tab': 1,
      },
      {
        'icon': Icons.chat_bubble_rounded,
        'title': 'DIRECT USER CHAT',
        'subtitle': 'Pantau obrolan 1-on-1 dengan pengunjung terdaftar website.',
        'actionText': 'LIHAT PESAN MASUK →',
        'tab': 2,
      },
      {
        'icon': Icons.smart_toy_rounded,
        'title': 'AI NAOO HELPER',
        'subtitle': 'Tanya jawab seputar koding & arsitektur ke asisten virtual.',
        'actionText': 'TANYA AI SEKARANG →',
        'tab': 3,
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'NEO-BRUTALIST THEMES',
        'subtitle': 'Nikmati 7 variasi skema warna tema Neo-Brutalist real-time.',
        'actionText': 'GANTI TEMA WARNA →',
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

            // HORIZONTAL CAROUSEL SLIDER SECTION
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
                  Text(
                    'SWIPE ↔',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: t.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // CAROUSEL SLIDER
            SizedBox(
              height: 165,
              child: PageView.builder(
                controller: _pageController,
                itemCount: carouselItems.length,
                onPageChanged: (index) => setState(() => _carouselIndex = index),
                itemBuilder: (context, index) {
                  final item = carouselItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: InkWell(
                      onTap: () {
                        final tab = item['tab'] as int;
                        if (tab >= 0) widget.onNavigateTab(tab);
                      },
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: t.primary,
                                border: Border.all(color: t.primary, width: 2),
                              ),
                              child: Text(
                                item['actionText'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  color: t.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                'PROJECTS TERDAFTAR',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
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
                          children: projects
                              .map((p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: BrutalCard(
                                      bgColor: t.cardBg,
                                      borderColor: t.primary,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
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
                                  ))
                              .toList(),
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
