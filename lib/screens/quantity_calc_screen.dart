import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// حاسبة الكميات الأساسية لمشاريع البناء - بسيطة وسريعة الاستخدام
class QuantityCalcScreen extends StatefulWidget {
  final String? initialCategory;
  const QuantityCalcScreen({super.key, this.initialCategory});

  @override
  State<QuantityCalcScreen> createState() => _QuantityCalcScreenState();
}

class _QuantityCalcScreenState extends State<QuantityCalcScreen> {
  final _length = TextEditingController(text: '10');
  final _width  = TextEditingController(text: '8');

  int _shape = 0; // 0 rectangle 1 triangle 2 circle
  int _fill   = 0; // 0 m³ concrete, 1 tile m², 2 paint m², 3 rebar kg/m³

  String _result = '';

  void _calc() {
    final l = double.tryParse(_length.text) ?? 0;
    final w = double.tryParse(_width.text)  ?? 0;
    if (l <= 0 || w <= 0) {
      setState(() => _result = 'من فضلك أدخل أبعادًا صحيحة أكبر من صفر.');
      return;
    }
    double area, volume;
    switch (_shape) {
      case 1: // مثلث
        area   = 0.5 * l * w;
        volume = area * 0.3; // سماكة افتراضية
        break;
      case 2: // دائرة
        area   = 3.14159 * l * l;
        volume = area * 0.3;
        break;
      default: // مستطيل
        area   = l * w;
        volume = area * 0.3;
    }

    String body;
    switch (_fill) {
      case 0: // خرسانة
        body = 'حجم الخرسانة ≈ ${volume.toStringAsFixed(2)} م³\n'
               '• نسبة حديد تقريبية: ${(volume * 80).toStringAsFixed(0)} كجم';
        break;
      case 1: // بلاط
        body = 'مساحة البلاط ≈ ${area.toStringAsFixed(2)} م²\n'
               '• أضف 10% احتياطي للكسور';
        break;
      case 2: // دهان
        body = 'مساحة الدهان ≈ ${area.toStringAsFixed(2)} م²\n'
               '• تحتاج تقريبًا ${(area / 12).toStringAsFixed(1)} لتر دهان (وجهين)';
        break;
      default: // حديد صنبور
        body = 'وزن الحديد ≈ ${(volume * 80).toStringAsFixed(0)} كجم\n'
               '≈ ${(volume * 80 / 12).toStringAsFixed(0)} سيخ 12 ملم';
    }

    setState(() => _result = body);
  }

  @override
  void dispose() {
    _length.dispose();
    _width.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('حاسبة الكميات')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('شكل المساحة'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _shapeBtn(0, Icons.crop_square_rounded, 'مستطيل'),
                  const SizedBox(width: 8),
                  _shapeBtn(1, Icons.change_history_rounded, 'مثلث'),
                  const SizedBox(width: 8),
                  _shapeBtn(2, Icons.circle_outlined, 'دائرة'),
                ],
              ),

              const SizedBox(height: 16),
              _sectionTitle('نوع الحساب'),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.6,
                children: [
                  _fillBtn(0, Icons.foundation_rounded,    'خرسانة (م³)',     AppTheme.primary),
                  _fillBtn(1, Icons.grid_on_rounded,       'بلاط (م²)',       const Color(0xFF14B8A6)),
                  _fillBtn(2, Icons.format_paint_rounded,  'دهان (م²)',       const Color(0xFFDB2777)),
                  _fillBtn(3, Icons.architecture_rounded,  'حديد تسليح (كجم)', const Color(0xFFEA580C)),
                ],
              ),

              const SizedBox(height: 18),
              _sectionTitle('الأبعاد (متر)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _dim(_length, 'الطول / القطر')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dim(_width, _shape == 1 ? 'القاعدة' : 'العرض'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _calc,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('احسب الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 18),
              if (_result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.assignment_turned_in_rounded, color: AppTheme.primary),
                          SizedBox(width: 8),
                          Text('النتيجة',
                              style: TextStyle(
                                fontFamily: 'Cairo', fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                              )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppTheme.textPrimary,
        ),
      );

  Widget _shapeBtn(int i, IconData icon, String label) {
    final selected = _shape == i;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _shape = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withOpacity(0.10) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppTheme.primary : AppTheme.textSecondary),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fillBtn(int i, IconData icon, String label, Color col) {
    final selected = _fill == i;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _fill = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? col.withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? col : AppTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: col, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? col : AppTheme.textPrimary,
                )),
          ],
        ),
      ),
    );
  }

  Widget _dim(TextEditingController c, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 5),
          child: Text(label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Cairo',
                fontSize: 12, fontWeight: FontWeight.w800,
              )),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: c,
            controller: c..text = c.text,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'متر',
              hintStyle: TextStyle(color: AppTheme.textLight, fontFamily: 'Cairo'),
            ),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
