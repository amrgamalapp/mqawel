import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product_model.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_helper.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _searchQuery = '';
  String _condition = 'الكل';
  String _category = 'الكل';

  Future<void> _callPhone(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String phone) async {
    if (phone.isEmpty) return;
    var clean = phone.trim();
    if (clean.startsWith('0')) clean = clean.substring(1);
    final uri = Uri.parse('https://wa.me/20$clean');
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
          title: const Text('سوق المركز 🛒', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث بالسلعة أو اسم البائع...',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _category,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'التصنيف', prefixIcon: Icon(Icons.category_rounded), isDense: true),
                items: const ['الكل','أجهزة','موبايلات','أثاث','ملابس','سيارات','أخرى'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'الكل'),
              )),
              const SizedBox(width: 8),
              Expanded(child: DropdownButtonFormField<String>(
                value: _condition,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'الحالة', prefixIcon: Icon(Icons.verified_rounded), isDense: true),
                items: const ['الكل','جديد','مستعمل'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => _condition = v ?? 'الكل'),
              )),
            ]),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: FirebaseService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('تعذر تحميل السوق حالياً\n${snapshot.error}', textAlign: TextAlign.center));
                var list = snapshot.data ?? const <ProductModel>[];
                if (_category != 'الكل') {
                  list = list.where((p) => (p.category ?? 'أخرى').trim() == _category).toList();
                }
                if (_condition != 'الكل') {
                  list = list.where((p) => p.condition.trim() == _condition).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  list = list.where((p) => [p.name, p.sellerName ?? '', p.notes ?? '', p.category ?? '', p.city ?? ''].join(' ').toLowerCase().contains(q)).toList();
                }
                if (list.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(25), child: Text('السوق فاضي حالياً يا هندسة..\nلو عندك شاشة، تليفون أو بوتاجاز عايز تبيعه اعرضه فوراً.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, height: 1.7, fontWeight: FontWeight.w700))));
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _ProductCard(product: list[i], onCall: _callPhone, onWhatsApp: _openWhatsApp),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final Future<void> Function(String) onCall;
  final Future<void> Function(String) onWhatsApp;
  const _ProductCard({required this.product, required this.onCall, required this.onWhatsApp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.055), blurRadius: 14, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 78, height: 78, decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(14)), child: product.imageUrl?.isNotEmpty == true ? ClipRRect(borderRadius: BorderRadius.circular(14), child: buildRemoteOrBase64Image(product.imageUrl, fit: BoxFit.cover, fallback: const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 32))) : const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 32)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w900))),
              if (product.isPinned) const Icon(Icons.push_pin_rounded, color: AppTheme.warning, size: 18),
            ]),
            const SizedBox(height: 7),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: AppTheme.warning, borderRadius: BorderRadius.circular(9)), child: Text('${product.price} ج.م', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12))),
              const SizedBox(width: 6),
              Expanded(child: Text(product.condition.isEmpty ? 'الحالة غير محددة' : product.condition, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
            ]),
            if (product.city?.isNotEmpty == true) ...[const SizedBox(height: 5), Text('📍 ${product.city}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))],
          ])),
        ]),
        const SizedBox(height: 10),
        Text(product.notes?.isNotEmpty == true ? product.notes! : 'لا توجد تفاصيل إضافية.', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.6)),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.person_rounded, size: 16, color: AppTheme.success),
          const SizedBox(width: 5),
          Expanded(child: Text('المعلن: ${product.sellerName?.isNotEmpty == true ? product.sellerName! : 'صاحب السلعة'}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: product.phone.isEmpty ? null : () => onCall(product.phone), icon: const Icon(Icons.phone, size: 17), label: const Text('اتصال'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), textStyle: const TextStyle(fontWeight: FontWeight.w800)))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(onPressed: product.phone.isEmpty ? null : () => onWhatsApp(product.phone), icon: const Icon(Icons.chat, size: 17), label: const Text('واتساب'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), textStyle: const TextStyle(fontWeight: FontWeight.w800)))),
        ]),
      ]),
    );
  }
}
