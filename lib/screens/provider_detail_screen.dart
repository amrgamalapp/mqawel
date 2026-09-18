import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../models/provider_model.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_helper.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ProviderModel provider;

  const ProviderDetailScreen({
    super.key,
    required this.provider,
  });

  @override
  State<ProviderDetailScreen> createState() =>
      _ProviderDetailScreenState();
}

class _ProviderDetailScreenState
    extends State<ProviderDetailScreen> {
  int _selectedStars = 5;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteAndViews();
    // تشغيل الإعلان البيني الذكي بهدوء
    AdService.instance.showSmartInterstitial();
  }

  Future<void> _loadFavoriteAndViews() async {
    final uid = AuthService.currentUser?.uid;
    if (uid != null && !uid.startsWith('guest_')) {
      final favorites = await FirebaseService.getFavoriteProviderKeys(uid).first;
      if (mounted) setState(() => _favorite = favorites.contains(widget.provider.key));
    }
    try { await FirebaseService.incrementProviderViewsSafe(widget.provider.key); } catch (_) {}
  }

  final TextEditingController _reviewController =
      TextEditingController();

  final TextEditingController _authorController =
      TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        bottomNavigationBar: const AdBanner(),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 245,
              pinned: true,
              elevation: 0,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'تفاصيل الخدمة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'المفضلة',
                  onPressed: () async {
                    final uid = AuthService.currentUser?.uid;
                    if (uid == null || uid.startsWith('guest_')) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجّل الدخول أولاً لإضافة الخدمة للمفضلة.')));
                      return;
                    }
                    final next = !_favorite;
                    setState(() => _favorite = next);
                    await FirebaseService.setFavoriteProvider(uid, widget.provider.key, next);
                  },
                  icon: Icon(_favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: _favorite ? AppTheme.warning : Colors.white),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient:
                        AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        Container(
                          width: 110,
                          height: 110,
                          padding:
                              const EdgeInsets.all(4),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(
                                  0.18,
                                ),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child:
                                p.imageUrl !=
                                            null &&
                                        p.imageUrl!
                                            .isNotEmpty
                                    ? buildRemoteOrBase64Image(p.imageUrl, fit: BoxFit.cover, fallback: _defaultIcon())
                                    : _defaultIcon(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          p.name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                20,
                18,
                40,
              ),
              sliver: SliverList(
                delegate:
                    SliverChildListDelegate(
                  [
                    _buildCategory(p),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon:
                                Icons.phone_rounded,
                            title: 'اتصال',
                            color:
                                AppTheme.primary,
                            onTap: () =>
                                _launchPhone(
                              p.phone,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            icon:
                                Icons.message_rounded,
                            title: 'واتساب',
                            color:
                                AppTheme.success,
                            onTap: () =>
                                _launchWhatsApp(
                              p.phone,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            icon:
                                Icons.share_rounded,
                            title: 'مشاركة',
                            color:
                                AppTheme.accent,
                            onTap: () =>
                                _shareProvider(
                              p,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    _InfoCard(
                      icon:
                          Icons.location_on_rounded,
                      color: AppTheme.danger,
                      title:
                          'القرية والعنوان',
                      value:
                          '${p.city} - ${p.address}',
                    ),

                    const SizedBox(height: 12),

                    _InfoCard(
                      icon:
                          Icons.info_outline_rounded,
                      color: AppTheme.accent,
                      title:
                          'نبذة عن الخدمة',
                      value: p.notes == null ||
                              p.notes!.trim().isEmpty
                          ? 'لا توجد تفاصيل إضافية'
                          : p.notes!,
                    ),

                    const SizedBox(height: 12),

                    _InfoCard(
                      icon:
                          Icons.remove_red_eye_rounded,
                      color:
                          AppTheme.textSecondary,
                      title:
                          'عدد المشاهدات',
                      value:
                          '${p.viewsCount} مشاهدة',
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'التقييمات والآراء',
                      style: TextStyle(
                        color:
                            AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildReviewForm(),

                    const SizedBox(height: 18),

                    _buildReviews(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Category
  // ============================================================

  Widget _buildCategory(
    ProviderModel p,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient:
                  AppTheme.cardGradient,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.category,
                        style:
                            const TextStyle(
                          color:
                              AppTheme.primary,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                    if (p.isVerified)
                      const Icon(
                        Icons
                            .verified_rounded,
                        color:
                            AppTheme.accent,
                        size: 21,
                      ),
                  ],
                ),
                if (p.subject != null &&
                    p.subject!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    p.subject!,
                    style:
                        const TextStyle(
                      color:
                          AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Review Form
  // ============================================================

  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.035),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'قيّم تجربتك',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) {
                final active =
                    index < _selectedStars;

                return IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedStars =
                          index + 1;
                    });
                  },
                  icon: Icon(
                    active
                        ? Icons.star_rounded
                        : Icons
                            .star_border_rounded,
                    color:
                        AppTheme.warning,
                    size: 34,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 5),

          TextField(
            controller: _authorController,
            textAlign: TextAlign.right,
            decoration:
                const InputDecoration(
              hintText: 'اسمك الكريم',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
              ),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _reviewController,
            textAlign: TextAlign.right,
            maxLines: 4,
            decoration:
                const InputDecoration(
              hintText:
                  'اكتب رأيك أو تجربتك...',
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                  bottom: 55,
                ),
                child: Icon(
                  Icons.rate_review_outlined,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitReview,
              icon: const Icon(
                Icons.send_rounded,
              ),
              label: const Text(
                'إرسال التقييم',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Reviews
  // ============================================================

  Widget _buildReviews() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService.getReviewsForProvider(
        widget.provider.key,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              'تعذر تحميل التعليقات حالياً. حاول مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            ),
          );
        }

        final reviews = snapshot.data ?? <Map<String, dynamic>>[];

        if (reviews.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  color: AppTheme.textLight,
                  size: 38,
                ),
                SizedBox(height: 10),
                Text(
                  'لا توجد تقييمات بعد',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'كن أول من يكتب رأيه عن الخدمة',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: reviews.map((review) {
            final starsValue = review['stars'];
            final stars = starsValue is num
                ? starsValue.toInt().clamp(0, 5)
                : int.tryParse('$starsValue')?.clamp(0, 5) ?? 5;

            final author = '${review['author'] ?? 'ابن المركز'}'.trim();
            final text = '${review['text'] ?? ''}'.trim();

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          author.isEmpty ? 'ابن المركز' : author,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          stars,
                          (_) => const Icon(
                            Icons.star_rounded,
                            color: AppTheme.warning,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ============================================================
  // Default image
  // ============================================================

  Widget _defaultIcon() {
    return Container(
      color: AppTheme.primary,
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          color: Colors.white,
          size: 45,
        ),
      ),
    );
  }

  // ============================================================
  // Actions
  // ============================================================

  Future<void> _launchPhone(
    String phone,
  ) async {
    final uri =
        Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (clean.startsWith('20')) {
      // Already international format
    } else if (clean.startsWith('0') && clean.length == 11) {
      clean = '2$clean';
    } else if (clean.length == 10) {
      clean = '20$clean';
    }

    final uri = Uri.parse('https://wa.me/$clean');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح واتساب. تأكد من تثبيته على جهازك.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح واتساب حالياً')),
        );
      }
    }
  }

  Future<void> _shareProvider(
    ProviderModel p,
  ) async {
    await Share.share(
      '📇 كارت الخدمة - خدمات المساح والمقاول\n\n'
      '👤 الاسم: ${p.name}\n'
      '🛠️ التخصص: ${p.category}\n'
      '📍 العنوان: ${p.city} - ${p.address}\n'
      '📞 التواصل: ${p.phone}\n\n'
      '✨ https://www.amrtools.pro',
    );
  }

  // ============================================================
  // Submit Review
  // ============================================================

  Future<void> _submitReview() async {
    final user = AuthService.currentUser;
    if (user == null || user.uid.startsWith('guest_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجّل الدخول أولاً علشان تقدر تكتب تقييم.')),
      );
      return;
    }

    final text =
        _reviewController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'اكتب رأيك أولاً',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseService.addReview(
        widget.provider.key,
        {
          'author':
              _authorController.text
                      .trim()
                      .isEmpty
                  ? 'ابن المركز'
                  : _authorController
                      .text
                      .trim(),
          'text': text,
          'stars': _selectedStars,
          'createdAt': DateTime.now()
              .millisecondsSinceEpoch,
        },
      );

      _reviewController.clear();
      _authorController.clear();

      if (!mounted) return;

      setState(() {
        _selectedStars = 5;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال تقييمك بنجاح! ❤️',
          ),
          backgroundColor:
              AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ أثناء إرسال التقييم',
          ),
          backgroundColor:
              AppTheme.danger,
        ),
      );
    }
  }
}

// ============================================================
// Info Card
// ============================================================

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.035),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    color: AppTheme
                        .textSecondary,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  textAlign:
                      TextAlign.right,
                  style:
                      const TextStyle(
                    color: AppTheme
                        .textPrimary,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight:
                        FontWeight.w800,
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

// ============================================================
// Action Button
// ============================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 19,
        ),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
