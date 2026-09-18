import 'package:flutter/material.dart';

import '../models/hero_model.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_helper.dart';

class HeroesScreen extends StatefulWidget {
  const HeroesScreen({super.key});

  @override
  State<HeroesScreen> createState() => _HeroesScreenState();
}

class _HeroesScreenState extends State<HeroesScreen> {
  final _nameCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _nominatorCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _storyCtrl = TextEditingController();
  String _village = 'القاهرة';
  bool _submitting = false;

  static const villages = [
    'القاهرة','القاهرة','الجيزة','الإسكندرية','المنصورة','طنطا',
    'أسيوط','سوهاج','بني سويف','الفيوم','الزقازيق','المنيا',
    'قنا','دمياط','الإسماعيلية','السويس','البحيرة','كفر الشيخ',
    'مطروح','الوادي الجديد','شمال سيناء','جنوب سيناء','البحر الأحمر',
    'أسوان','الأقصر','بورسعيد','كفر الإسماعيلية',
    'كفر كفر الشيخ','العريش','الغردقة','مرسى علم',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fieldCtrl.dispose();
    _nominatorCtrl.dispose();
    _phoneCtrl.dispose();
    _storyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitNomination() async {
    final name = _nameCtrl.text.trim();
    final field = _fieldCtrl.text.trim();
    final nominator = _nominatorCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final story = _storyCtrl.text.trim();

    if ([name, field, nominator, phone, story].any((v) => v.isEmpty)) {
      _show('يرجى استكمال بيانات الترشيح كلها.', true);
      return;
    }
    if (!RegExp(r'^01\d{9}$').hasMatch(phone)) {
      _show('رقم التليفون يجب أن يكون 11 رقم ويبدأ بـ 01.', true);
      return;
    }

    setState(() => _submitting = true);
    try {
      await FirebaseService.addHeroNomination({
        'name': name,
        'city': _village,
        'field': field,
        'nominator': nominator,
        'phone': phone,
        'story': story,
        'bio': story,
        'title': field,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'approved': false,
      });
      _nameCtrl.clear();
      _fieldCtrl.clear();
      _nominatorCtrl.clear();
      _phoneCtrl.clear();
      _storyCtrl.clear();
      _show('تم إرسال الترشيح للإدارة والمراجعة ✨', false);
    } catch (e) {
      _show('تعذر إرسال الترشيح حالياً. حاول مرة أخرى.', true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _show(String text, bool error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textDirection: TextDirection.rtl),
        backgroundColor: error ? AppTheme.danger : AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: const Text('شخصيات ملهمة ولوحة شرف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ),
        body: StreamBuilder<List<HeroModel>>(
          stream: FirebaseService.getHeroes(),
          builder: (context, snapshot) {
            final heroes = snapshot.data ?? const <HeroModel>[];
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                if (snapshot.connectionState == ConnectionState.waiting && heroes.isEmpty)
                  const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator())))
                else if (heroes.isEmpty)
                  const SliverToBoxAdapter(child: _EmptyHeroes())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _HeroCard(hero: heroes[index]),
                        childCount: heroes.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: _nominationForm()),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header() => Container(
        margin: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF1E1B4B).withOpacity(.25), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 32),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('شخصيات ملهمة ولوحة شرف خدمات المساحة والمقاولات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, height: 1.3)),
              SizedBox(height: 6),
              Text('تسليط الضوء على النماذج المشرفة والملهمة في قرى ونجوع خدمات المساحة والمقاولات.', style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 12, height: 1.5, fontWeight: FontWeight.w600)),
            ])),
          ],
        ),
      );

  Widget _nominationForm() => Container(
        margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(.3)),
            ),
            child: const Column(children: [
              Text('رشّح شخصية ملهمة من القطاع', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF92400E), fontSize: 17, fontWeight: FontWeight.w900)),
              SizedBox(height: 5),
              Text('تخضع جميع الترشيحات للمراجعة والاعتماد من الإدارة قبل النشر مباشرة.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB45309), fontSize: 11, height: 1.5, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 16),
          _field(_nameCtrl, 'اسم الشخصية المرشحة بالكامل', Icons.person_rounded),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _village,
            isExpanded: true,
            decoration: _decoration('القرية التابعة', Icons.location_on_rounded),
            items: villages.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _village = v ?? _village),
          ),
          const SizedBox(height: 10),
          _field(_fieldCtrl, 'المجال / التخصص', Icons.work_outline_rounded),
          const SizedBox(height: 10),
          _field(_nominatorCtrl, 'اسم المُقدِم للترشيح', Icons.badge_outlined),
          const SizedBox(height: 10),
          _field(_phoneCtrl, 'رقم تليفونك لتأكيد البيانات', Icons.phone_outlined, keyboard: TextInputType.phone),
          const SizedBox(height: 10),
          TextField(controller: _storyCtrl, maxLines: 5, textDirection: TextDirection.rtl, decoration: _decoration('قصة النجاح أو أسباب الترشيح بالتفصيل', Icons.article_outlined)),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _submitting ? null : _submitNomination,
            icon: _submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
            label: Text(_submitting ? 'جاري الإرسال...' : 'إرسال الترشيح للإدارة والمراجعة ✨'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1B4B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
          ),
        ]),
      );

  Widget _field(TextEditingController c, String hint, IconData icon, {TextInputType? keyboard}) => TextField(
        controller: c,
        keyboardType: keyboard,
        textDirection: TextDirection.rtl,
        decoration: _decoration(hint, icon),
      );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
      );
}

class _EmptyHeroes extends StatelessWidget {
  const _EmptyHeroes();
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_outlined, size: 36, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 14),
          const Text('لم يتم إضافة شخصيات ملهمة معتمدة بعد..', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          const Text('شاركنا بترشيح أول نموذج ملهم من المركز بالأسفل!', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ]),
      );
}

class _HeroCard extends StatelessWidget {
  final HeroModel hero;
  const _HeroCard({required this.hero});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
          boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(.08), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              child: Text('👑 لوحة شرف خدمات المساحة والمقاولات (${hero.city})', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Container(
              width: 68,
              height: 68,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
                boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(.15), blurRadius: 10)],
              ),
              child: ClipOval(
                child: hero.imageUrl?.isNotEmpty == true
                    ? buildRemoteOrBase64Image(hero.imageUrl, fit: BoxFit.cover, fallback: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB45309), size: 31))
                    : const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB45309), size: 31),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hero.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF1E1B4B), fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                child: Text(hero.field.isEmpty ? 'رمز مجتمعي ملهم' : hero.field, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF92400E), fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ])),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(hero.bio.isEmpty ? 'لا توجد تفاصيل إضافية.' : hero.bio, style: const TextStyle(color: Color(0xFF334155), fontSize: 12, height: 1.8, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                const SizedBox(width: 4),
                const Text('بطل وقائد ملهم لأبناء المركز', style: TextStyle(color: Color(0xFF92400E), fontSize: 10, fontWeight: FontWeight.w800)),
              ],
            ),
            const Text('إشراف وتطوير المهندس عمرو جمال عوض', style: TextStyle(color: Color(0xFF6366F1), fontSize: 8, fontWeight: FontWeight.w700)),
          ]),
        ]),
      );

}
