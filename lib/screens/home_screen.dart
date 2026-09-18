import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import 'directory_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'requests_screen.dart';
import 'notifications_screen.dart';
import 'quantity_calc_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel? user;
  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic> _appSettings = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseService.getAppSettings().listen((data) {
      if (mounted) setState(() => _appSettings = data);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ───────────────────────  Brand categories  ────────────────────────
  static const List<_ServiceCategory> categories = [
    _ServiceCategory('مكاتب مساحة',      Icons.architecture_rounded,          AppTheme.primary),
    _ServiceCategory('مقاولات عامة',     Icons.construction_rounded,         Color(0xFFEA580C)),
    _ServiceCategory('أعمال حفر وردم',   Icons.layers_rounded,               Color(0xFFB45309)),
    _ServiceCategory('خرسانات ومسلحة',   Icons.foundation_rounded,           Color(0xFF475569)),
    _ServiceCategory('تشطيبات داخلية',   Icons.home_rounded,                 Color(0xFF14B8A6)),
    _ServiceCategory('دهانات وورق حائط', Icons.format_paint_rounded,         Color(0xFFDB2777)),
    _ServiceCategory('كهرباء',            Icons.electrical_services_rounded,  Color(0xFFF59E0B)),
    _ServiceCategory('سباكة',             Icons.plumbing_rounded,             Color(0xFF0284C7)),
    _ServiceCategory('أرضيات وسيراميك',  Icons.grid_on_rounded,              Color(0xFF0EA5E9)),
    _ServiceCategory('ألوميتال وزجاج',   Icons.window_rounded,               Color(0xFF7C3AED)),
    _ServiceCategory('حدادة ولحام',      Icons.handyman_rounded,             Color(0xFF92400E)),
    _ServiceCategory('نجارة',             Icons.carpenter_rounded,            Color(0xFF64748B)),
    _ServiceCategory('تكييف وتهوية',     Icons.ac_unit_rounded,              Color(0xFF0891B2)),
    _ServiceCategory('معدات بناء',       Icons.agriculture_rounded,          Color(0xFF059669)),
    _ServiceCategory('نقل ومواد بناء',    Icons.local_shipping_rounded,       Color(0xFFEA580C)),
    _ServiceCategory('دش وأقمار',         Icons.satellite_alt_rounded,        Color(0xFF334155)),
    _ServiceCategory('كاميرات مراقبة',    Icons.videocam_rounded,             Color(0xFF2563EB)),
    _ServiceCategory('مساحون خبراء',     Icons.gps_fixed_rounded,            Color(0xFF0F766E)),
    _ServiceCategory('خرائط وتخطيط',     Icons.map_rounded,                  Color(0xFF16A34A)),
    _ServiceCategory('خدمات أخرى',       Icons.miscellaneous_services_rounded, Color(0xFF6B7280)),
  ];

  // ───────────────────────  Build method  ────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _ExploreTab(),
            DirectoryScreen(),
            QuantityCalcScreen(),
            FavoritesScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'استكشف',
            ),
            NavigationDestination(
              icon: Icon(Icons.business_outlined),
              selectedIcon: Icon(Icons.business_rounded),
              label: 'الدليل',
            ),
            NavigationDestination(
              icon: Icon(Icons.calculate_outlined),
              selectedIcon: Icon(Icons.calculate_rounded),
              label: 'الحاسبة',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'المفضلة',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//   Explore Tab — hero header + search + categories + featured
// ════════════════════════════════════════════════════════════════════
class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    final categories = _HomeScreenState.categories;
    return CustomScrollView(
      slivers: [
        // ─── Hero header ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 26),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/images/logo.png',
                            fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'خدمات المساح والمقاول',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'دليل احترافي متكامل',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<int>(
                      stream: _unreadNotificationsCount(),
                      builder: (context, snap) {
                        final count = snap.data ?? 0;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              tooltip: 'الإشعارات',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              ),
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            if (count > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  constraints: const BoxConstraints(
                                      minWidth: 18, minHeight: 18),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.danger,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    count > 99 ? '99+' : '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                const Text(
                  'ابحث عن المسّاح أو المقاول المناسب لمشروعك',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'دقة في التنفيذ، ثقة في النتائج — تمامًا كما في الموقع',
                  style: TextStyle(
                    color: Color(0xFFE1FFF8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                // ─── Search bar ────────────────────────────────────────
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: AppTheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          textDirection: TextDirection.rtl,
                          onSubmitted: (q) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DirectoryScreen(initialQuery: q),
                              ),
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: 'مثال: مساح أراضي، مقاول تشطيبات…',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تصنيفات الخدمات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DirectoryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'عرض الكل ←',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.92,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _CategoryTile(category: categories[i]),
              childCount: categories.length,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'أدوات سريعة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _QuickTool(
                icon: [
                  Icons.calculate_rounded,
                  Icons.upload_file_rounded,
                  Icons.map_rounded,
                  Icons.support_agent_rounded,
                ][i],
                title: [
                  'حاسبة الكميات',
                  'رفع ملف مشروع',
                  'خريطة المكاتب',
                  'طلب عرض سعر',
                ][i],
                color: [
                  AppTheme.primary,
                  Color(0xFFEA580C),
                  Color(0xFF059669),
                  Color(0xFF7C3AED),
                ][i],
                onTap: () {
                  if (i == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuantityCalcScreen(),
                      ),
                    );
                  } else if (i == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RequestsScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          '${['حاسبة الكميات', 'رفع ملف مشروع', 'خريطة المكاتب', 'طلب عرض سعر'][i]} قريباً')),
                    );
                  }
                },
              ),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Small reusable widgets
// ════════════════════════════════════════════════════════════════════
Stream<int> _unreadNotificationsCount() {
  final uid = AuthService.currentUser?.uid;
  if (uid == null || uid.startsWith('guest_')) return Stream.value(0);
  return FirebaseDatabase.instance
      .ref('notifications/$uid')
      .onValue
      .map((event) {
    final raw = event.snapshot.value;
    if (raw is! Map) return 0;
    return raw.values.where((v) => v is Map && v['read'] != true).length;
  });
}

class _CategoryTile extends StatelessWidget {
  final _ServiceCategory category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DirectoryScreen(
              initialCategory: category.name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTool extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _QuickTool({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_back_ios_new_rounded,
                size: 14, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}

class _ServiceCategory {
  final String name;
  final IconData icon;
  final Color color;
  const _ServiceCategory(this.name, this.icon, this.color);
}

// Lightweight launcher to open amrtools.pro
Future<void> _openAmrtools() async {
  final uri = Uri.parse('https://amrtools.pro');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
