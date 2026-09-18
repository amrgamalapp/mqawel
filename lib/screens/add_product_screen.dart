import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _seller = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  String _condition = 'جديد';
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose(); _price.dispose(); _seller.dispose(); _phone.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = AuthService.currentUser;
    if (user == null || user.uid.startsWith('guest_')) {
      _message('سجّل الدخول أولاً علشان تقدر تعرض سلعة في السوق.', true);
      return;
    }
    final name = _name.text.trim();
    final price = _price.text.trim();
    final seller = _seller.text.trim();
    final phone = _phone.text.trim();
    final notes = _notes.text.trim();
    if (name.isEmpty || price.isEmpty || seller.isEmpty || phone.isEmpty || notes.isEmpty) {
      _message('يرجى استكمال بيانات السلعة كلها.', true);
      return;
    }
    if (!RegExp(r'^01\d{9}$').hasMatch(phone)) {
      _message('رقم التليفون يجب أن يكون 11 رقم ويبدأ بـ 01.', true);
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseService.addProduct({
        'productName': name,
        'price': price,
        'condition': _condition,
        'sellerName': seller,
        'phone': phone,
        'notes': notes,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر السلعة في سوق المركز فوراً 🚀'), backgroundColor: AppTheme.success));
      Navigator.pop(context);
    } catch (_) {
      _message('حدث خطأ أثناء نشر السلعة. حاول مرة أخرى.', true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String text, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, textDirection: TextDirection.rtl), backgroundColor: error ? AppTheme.danger : AppTheme.success));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, centerTitle: true, title: const Text('اعرض حاجة للبيع في سوق المركز', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 16, offset: const Offset(0, 6))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('اعرض حاجة للبيع في سوق المركز 🛒', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.success, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              const Text('شاشة، بوتاجاز، تليفون أو أي حاجة حابب تعرضها لأهل المركز.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 16),
              _field(_name, 'اسم السلعة / المنتج للبيع', Icons.shopping_bag_outlined),
              const SizedBox(height: 10),
              _field(_price, 'السعر المطلوب (جنيه)', Icons.payments_outlined, keyboard: TextInputType.number),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(value: _condition, decoration: _decoration('حالة المنتج', Icons.inventory_2_outlined), items: const [DropdownMenuItem(value: 'جديد', child: Text('جديد كرتونة زيرو')), DropdownMenuItem(value: 'مستعمل بحالة ممتازة', child: Text('مستعمل بحالة ممتازة')), DropdownMenuItem(value: 'مستعمل بحالة متوسطة', child: Text('مستعمل بحالة متوسطة'))], onChanged: (v) => setState(() => _condition = v ?? _condition)),
              const SizedBox(height: 10),
              _field(_seller, 'اسم البائع المحترم', Icons.person_outline),
              const SizedBox(height: 10),
              _field(_phone, 'رقم تليفون التواصل (واتساب ومكالمات)', Icons.phone_outlined, keyboard: TextInputType.phone),
              const SizedBox(height: 10),
              TextField(controller: _notes, maxLines: 5, textDirection: TextDirection.rtl, decoration: _decoration('وصف السلعة بالتفصيل ومكان المعاينة والطلب', Icons.description_outlined)),
              const SizedBox(height: 14),
              ElevatedButton.icon(onPressed: _loading ? null : _submit, icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.publish_rounded), label: Text(_loading ? 'جاري النشر...' : 'انشر السلعة في سوق المركز فوراً 🚀'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontWeight: FontWeight.w900))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {TextInputType? keyboard}) => TextField(controller: c, keyboardType: keyboard, textDirection: TextDirection.rtl, decoration: _decoration(hint, icon));
  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(hintText: hint, hintTextDirection: TextDirection.rtl, prefixIcon: Icon(icon, color: AppTheme.primary), filled: true, fillColor: AppTheme.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)));
}
