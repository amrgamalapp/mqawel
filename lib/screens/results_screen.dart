import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _seatCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _resultType = 'high_school';
  String _village = 'القاهرة';

  static const _villages = [
    'القاهرة','القاهرة','الجيزة','الإسكندرية','المنصورة','طنطا','أسيوط','سوهاج','بني سويف','الفيوم','الزقازيق','المنيا','قنا','دمياط','الإسماعيلية','السويس','البحيرة','كفر الشيخ','مطروح','الوادي الجديد','شمال سيناء','جنوب سيناء','البحر الأحمر','أسوان','الأقصر','بورسعيد','كفر الإسماعيلية','كفر كفر الشيخ','العريش','الغردقة','مرسى علم',
  ];
  bool _loading = false;
  bool _booking = false;
  String? _resultMsg;
  bool _isError = false;

  static const _highSchoolScript = 'https://script.google.com/macros/s/AKfycbxG1QMtDqfzkSF4VOdoGD2AK4GiwStnpGHx77Nzgmtv4e8JnWEK2s8mhpO_q8_uZ-CvDg/exec';
  static const _generalSheet = 'https://www.mediafire.com/file/4zkk7jhnjhevlmv/%D9%86%D8%AA%D9%8A%D8%AC%D8%A9+%D8%AB%D8%A7%D9%86%D9%88%D9%8A%D8%A9+%D8%B9%D8%A7%D9%85%D8%A9+%D9%86%D8%B8%D8%A7%D9%85+%D8%AD%D8%AF%D9%8A%D8%AB.xlsx/file';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _seatCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkResult() async {
    final input = _searchCtrl.text.trim();
    if (input.isEmpty) {
      _setMessage('اكتب الاسم أو رقم الجلوس للاستعلام.', true);
      return;
    }
    if (_resultType != 'high_school') {
      _setMessage('نتيجة الشهادة الإعدادية - الدور الثاني لم يتم ربط سكربتها على الموقع حتى الآن.', true);
      return;
    }

    setState(() {
      _loading = true;
      _resultMsg = 'جاري البحث عن ($input)... 🚀';
      _isError = false;
    });

    try {
      final uri = Uri.parse('$_highSchoolScript?seat=${Uri.encodeQueryComponent(input)}');
      final request = await HttpClient().getUrl(uri);
      request.followRedirects = true;
      final response = await request.close().timeout(const Duration(seconds: 20));
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body);

      if (data is Map && data['success'] == true) {
        _setMessage(
          '🎉 تم العثور على النتيجة!\n\n'
          '🆔 رقم الجلوس: ${data['seat'] ?? input}\n'
          '👤 الاسم: ${data['name'] ?? 'غير متاح'}\n'
          '📊 النتيجة / المجموع: ${data['score'] ?? 'غير متاح'}',
          false,
        );
      } else {
        _setMessage('عذراً، لم يتم العثور على نتيجة تطابق هذا البحث!', true);
      }
    } catch (_) {
      _setMessage('تأكد من الاتصال بالإنترنت وأعد المحاولة.', true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _bookResult() async {
    final name = _nameCtrl.text.trim();
    final seat = _seatCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || seat.isEmpty || phone.isEmpty) {
      _setMessage('يرجى استكمال الاسم ورقم الجلوس ورقم التليفون.', true);
      return;
    }
    if (!RegExp(r'^01\d{9}$').hasMatch(phone)) {
      _setMessage('رقم التليفون يجب أن يكون 11 رقم ويبدأ بـ 01.', true);
      return;
    }

    setState(() => _booking = true);
    try {
      await FirebaseService.bookResult({
        'name': name,
        'city': _village,
        'center': 'خدمات المساحة والمقاولات (مصر)',
        'seatNumber': seat,
        'phone': phone,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      _setMessage('تم حجز وتأكيد بيانات نتيجتك بنجاح للأدمن 🔥', false);
      _nameCtrl.clear();
      _seatCtrl.clear();
      _phoneCtrl.clear();
    } catch (_) {
      _setMessage('حدث خطأ أثناء حفظ الحجز.', true);
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  void _setMessage(String text, bool error) {
    if (!mounted) return;
    setState(() {
      _resultMsg = text;
      _isError = error;
    });
  }

  Future<void> _openSheet() async {
    final uri = Uri.parse(_generalSheet);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          title: const Text('البوابة التعليمية 2026 🎓', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 35),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _introCard(),
            const SizedBox(height: 14),
            _checkCard(),
            const SizedBox(height: 14),
            _bookingCard(),
            const SizedBox(height: 14),
            _downloadsCard(),
          ]),
        ),
      ),
    );
  }

  Widget _introCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(.16), blurRadius: 18, offset: const Offset(0, 7))]),
        child: const Column(children: [
          Icon(Icons.school_rounded, color: Colors.white, size: 48),
          SizedBox(height: 8),
          Text('البوابة التعليمية 2026 🎓', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('مهما كانت النتيجة، تذكر أنك قدّمتَ ما أمكنك، والقادم دائماً أجمل بإذن الله 💙', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.6, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _checkCard() => _card(
        title: 'الاستعلام المباشر',
        icon: Icons.search_rounded,
        children: [
          DropdownButtonFormField<String>(
            value: _resultType,
            isExpanded: true,
            decoration: _decoration('اختر النتيجة المراد الاستعلام عنها', Icons.school_outlined),
            items: const [
              DropdownMenuItem(value: 'high_school', child: Text('نتيجة الثانوية العامة 🎓')),
              DropdownMenuItem(value: 'prep_second_term', child: Text('نتيجة الشهادة الإعدادية - الدور الثاني 📚')),
            ],
            onChanged: (v) => setState(() => _resultType = v ?? 'high_school'),
          ),
          const SizedBox(height: 10),
          _field(_searchCtrl, 'اكتب الاسم أو رقم الجلوس', Icons.numbers),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: _loading ? null : _checkResult, icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search), label: Text(_loading ? 'جاري البحث...' : 'استعلام عن النتيجة الآن 🚀'), style: _button()),
          if (_resultMsg != null && !_booking) ...[
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _isError ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: _isError ? Colors.red : Colors.green)), child: Text(_resultMsg!, textAlign: TextAlign.right, style: TextStyle(color: _isError ? Colors.red.shade700 : Colors.green.shade800, fontWeight: FontWeight.w700, height: 1.6))),
          ],
        ],
      );

  Widget _bookingCard() => _card(
        title: 'حجز النتيجة للأدمن',
        icon: Icons.bookmark_add_rounded,
        children: [
          const Text('لو لم تجد نتيجتك، اترك بياناتك وسيتم إرسال النتيجة فور اعتمادها.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.6)),
          const SizedBox(height: 12),
          _field(_nameCtrl, 'الاسم بالكامل', Icons.person),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _village,
            isExpanded: true,
            decoration: _decoration('القرية التابعة', Icons.location_on_outlined),
            items: _villages.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _village = v ?? _village),
          ),
          const SizedBox(height: 10),
          _field(_seatCtrl, 'رقم الجلوس', Icons.numbers),
          const SizedBox(height: 10),
          _field(_phoneCtrl, 'رقم التليفون', Icons.phone, keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: _booking ? null : _bookResult, icon: _booking ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.bookmark), label: Text(_booking ? 'جاري الحفظ...' : 'إتمام حجز النتيجة 🚀'), style: _button()),
        ],
      );

  Widget _downloadsCard() => _card(
        title: 'تحميل ملفات النتيجة الشاملة',
        icon: Icons.file_download_rounded,
        children: [
          const Text('ملفات النتيجة المتاحة على الموقع الرسمي.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: _openSheet, icon: const Icon(Icons.download_rounded), label: const Text('شيت العامة 2026 ⚡'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, side: const BorderSide(color: AppTheme.primary), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: null, icon: Icon(Icons.menu_book_rounded), label: Text('شيت الأزهرية 🕌')),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.file_copy_rounded), label: const Text('شيت 3 إعدادية (دور تاني) 📄')),
        ],
      );

  Widget _card({required String title, required IconData icon, required List<Widget> children}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 15, offset: const Offset(0, 6))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Icon(icon, color: AppTheme.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))]),
          const SizedBox(height: 14),
          ...children,
        ]),
      );

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboard}) => TextField(controller: ctrl, keyboardType: keyboard, textDirection: TextDirection.rtl, decoration: _decoration(hint, icon));

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(hintText: hint, hintTextDirection: TextDirection.rtl, prefixIcon: Icon(icon, color: AppTheme.primary), filled: true, fillColor: AppTheme.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)));

  ButtonStyle _button() => ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontWeight: FontWeight.w800));
}
