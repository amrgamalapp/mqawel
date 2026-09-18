import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/provider_model.dart';
import '../services/firebase_service.dart';
import '../utils/image_helper.dart';
import 'provider_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;
  const DirectoryScreen({super.key, this.initialCategory, this.initialQuery});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  String _searchQuery = '';
  String _categoryFilter = 'all';
  String _roleFilter    = 'all'; // مساح | مقاول | الكل

  @override
  void initState() {
    super.initState();
    _searchQuery  = widget.initialQuery  ?? '';
    _categoryFilter = widget.initialCategory ?? 'all';
  }

  // ─────────────────────────  Filters  ────────────────────────────
  static const _roles = [
    {'value': 'all',          'label': 'الكل'},
    {'value': 'مساح',         'label': 'مسّاح'},
    {'value': 'مقاول',        'label': 'مقاول'},
  ];

  static const _categories = [
    {'value': 'all', 'label': 'الكل',                              'icon': Icons.grid_view_rounded,          'color': Color(0xFF0F766E)},
    {'value': 'مكاتب مساحة',                 'label': 'مكاتب مساحة',                       'icon': Icons.architecture_rounded,         'color': Color(0xFF0F766E)},
    {'value': 'مقاولات عامة',                'label': 'مقاولات عامة',                      'icon': Icons.construction_rounded,          'color': Color(0xFFEA580C)},
    {'value': 'أعمال حفر وردم',              'label': 'حفر وردم',                          'icon': Icons.layers_rounded,                'color': Color(0xFFB45309)},
    {'value': 'خرسانات ومسلحة',              'label': 'خرسانات',                            'icon': Icons.foundation_rounded,            'color': Color(0xFF475569)},
    {'value': 'تشطيبات داخلية',              'label': 'تشطيبات',                            'icon': Icons.home_rounded,                  'color': Color(0xFF14B8A6)},
    {'value': 'دهانات وورق حائط',            'label': 'دهانات',                             'icon': Icons.format_paint_rounded,          'color': Color(0xFFDB2777)},
    {'value': 'كهرباء',                      'label': 'كهرباء',                             'icon': Icons.electrical_services_rounded,   'color': Color(0xFFF59E0B)},
    {'value': 'سباكة',                       'label': 'سباكة',                              'icon': Icons.plumbing_rounded,              'color': Color(0xFF0284C7)},
    {'value': 'أرضيات وسيراميك',             'label': 'سيراميك',                            'icon': Icons.grid_on_rounded,               'color': Color(0xFF0EA5E9)},
    {'value': 'ألوميتال وزجاج',              'label': 'ألوميتال',                           'icon': Icons.window_rounded,                'color': Color(0xFF7C3AED)},
    {'value': 'حدادة ولحام',                 'label': 'حدادة',                              'icon': Icons.handyman_rounded,              'color': Color(0xFF92400E)},
    {'value': 'نجارة',                       'label': 'نجارة',                              'icon': Icons.carpenter_rounded,             'color': Color(0xFF64748B)},
    {'value': 'تكييف وتهوية',                'label': 'تكييف',                              'icon': Icons.ac_unit_rounded,               'color': Color(0xFF0891B2)},
    {'value': 'معدات بناء',                  'label': 'معدات بناء',                         'icon': Icons.construction_rounded,          'color': Color(0xFF059669)},
    {'value': 'نقل ومواد بناء',              'label': 'نقل مواد',                           'icon': Icons.local_shipping_rounded,        'color': Color(0xFFEF4444)},
    {'value': 'دش وأقمار',                   'label': 'دش وأقمار',                          'icon': Icons.satellite_alt_rounded,         'color': Color(0xFF334155)},
    {'value': 'كاميرات مراقبة',              'label': 'كاميرات',                            'icon': Icons.videocam_rounded,              'color': Color(0xFF2563EB)},
    {'value': 'مساحون خبراء',                'label': 'مساحون خبراء',                       'icon': Icons.gps_fixed_rounded,             'color': Color(0xFF0F766E)},
    {'value': 'خرائط وتخطيط',                'label': 'خرائط وتخطيط',                      'icon': Icons.map_rounded,                   'color': Color(0xFF16A34A)},
    {'value': 'خدمات أخرى',                  'label': 'خدمات أخرى',                         'icon': Icons.miscellaneous_services_rounded,'color': Color(0xFF6B7280)},
  ];

  String _normalizeCategory(String value) {
    const aliases = <String, String>{
      'مقاولات عامة'              : 'مقاولات عامة',
      'مساحة أراضي'               : 'مكاتب مساحة',
      'مساحة معمارية'             : 'مكاتب مساحة',
    };
    return aliases[value.trim()] ?? value.trim();
  }

  // ───────────────────────  Filter UI helpers  ────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('دليل مكاتب المساحة والمقاولات'),
        leading: IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => setState(() {
            _searchQuery = '';
            _categoryFilter = 'all';
            _roleFilter    = 'all';
          }),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 10),
          _buildRoleChips(),
          const SizedBox(height: 10),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                textDirection: TextDirection.rtl,
                controller: TextEditingController(text: _searchQuery)
                  ..selection = TextSelection.collapsed(offset: _searchQuery.length),
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'ابحث بالاسم، التخصص، أو المدينة…',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo', fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppTheme.textLight,
                  ),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                onPressed: () => setState(() => _searchQuery = ''),
                icon: const Icon(Icons.clear_rounded, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final c = _categories[i];
            final selected = _categoryFilter == c['value'];
            final color   = c['color'] as Color;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _categoryFilter = c['value'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? color : AppTheme.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(c['icon'] as IconData,
                        size: 16,
                        color: selected ? Colors.white : color),
                    const SizedBox(width: 5),
                    Text(
                      c['label'] as String,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ───────────────────────  List  ─────────────────────────────────────
  Widget _buildList() {
    return StreamBuilder<List<ProviderModel>>(
      stream: FirebaseService.streamProviders(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData) {
          return _EmptyState(
            icon: Icons.business_rounded,
            title: 'لا توجد بيانات',
            subtitle: 'حاول مرة أخرى أو تواصل مع الإدارة.',
          );
        }

        var results = snap.data!;

        if (_categoryFilter != 'all') {
          final wanted = _normalizeCategory(_categoryFilter);
          results = results.where((p) =>
              _normalizeCategory(p.category) == wanted).toList();
        }
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.toLowerCase().trim();
          results = results.where((p) {
            return p.name.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q) ||
                (p.subject ?? '').toLowerCase().contains(q) ||
                p.address.toLowerCase().contains(q);
          }).toList();
        }
        if (_roleFilter != 'all') {
          results = results.where((p) => p.role == _roleFilter).toList();
        }

        if (results.isEmpty) {
          return _EmptyState(
            icon: Icons.search_off_rounded,
            title: 'لا توجد نتائج مطابقة',
            subtitle: 'جرّب بحثًا آخر أو غيّر التصنيف.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _ProviderCard(provider: results[i]),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    for (final c in _categories) {
      if (c['value'] == category) return c['icon'] as IconData;
    }
    return Icons.business_rounded;
  }

  Color _getCategoryColor(String category) {
    for (final c in _categories) {
      if (c['value'] == category) return c['color'] as Color;
    }
    return AppTheme.primary;
  }

  String _getCategoryLabel(String category) {
    for (final c in _categories) {
      if (c['value'] == category) return c['label'] as String;
    }
    return category;
  }
}

// ═══════════════════════════════════════════════════════════════════════
//   Provider card
// ═══════════════════════════════════════════════════════════════════════
class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final p    = provider;
    final dir  = _DirectoryScreenState();
    final icon = dir._getCategoryIcon(p.category);
    final color = dir._getCategoryColor(p.category);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderDetailScreen(provider: p),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ Avatar / icon ─
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                  ? buildRemoteOrBase64Image(p.imageUrl!, fit: BoxFit.cover,
                      fallback: Icon(icon, color: color, size: 28))
                  : Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),

            // ─ Info ─
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (p.role != null && p.role!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: p.role == 'مساح'
                                ? AppTheme.primary.withOpacity(0.10)
                                : Color(0xFFEA580C).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p.role!,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: p.role == 'مساح'
                                  ? AppTheme.primary
                                  : const Color(0xFFEA580C),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dir._getCategoryLabel(p.category)} • ${p.address}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _actionIconBtn(
                        Icons.call_rounded,
                        color,
                        () async {
                          final uri = Uri.parse('tel:${p.phone}');
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                      ),
                      const SizedBox(width: 6),
                      _actionIconBtn(
                        Icons.chat_rounded,
                        const Color(0xFF16A34A),
                        () async {
                          String clean = p.phone.replaceAll(RegExp(r'[^0-9]'), '');
                          if (clean.startsWith('0') && clean.length == 11) {
                            clean = '2$clean';
                          } else if (clean.length == 10) {
                            clean = '20$clean';
                          }
                          final uri = Uri.parse('https://wa.me/$clean');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      _actionIconBtn(
                        Icons.map_rounded,
                        const Color(0xFFEA580C),
                        () async {
                          final uri = Uri.parse(
                            'https://www.google.com/maps/search/${Uri.encodeComponent(p.address)}',
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.10),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppTheme.textLight),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
