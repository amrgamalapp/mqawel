import 'dart:math';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _subjectController = TextEditingController();

  String? _pickedImageBase64;
  bool _isLoading = false;

  String _selectedCategory = 'مطاعم وكافيهات';
  String _selectedVillage = 'القاهرة';

  final List<String> _villages = const [
    'القاهرة',
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'المنصورة',
    'طنطا',
    'أسيوط',
    'سوهاج',
    'بني سويف',
    'الفيوم',
    'الزقازيق',
    'المنيا',
    'قنا',
    'دمياط',
    'السويس',
    'البحيرة',
    'كفر الشيخ',
    'مطروح',
    'الوادي الجديد',
    'شمال سيناء',
    'جنوب سيناء',
    'البحر الأحمر',
    'أسوان',
    'الأقصر',
    'بورسعيد',
    'كفر الإسماعيلية',
    'كفر كفر الشيخ',
    'العريش',
    'الغردقة',
    'مرسى علم',
  ];

  final List<Map<String, String>> _categories = const [
    {'value': 'مطاعم وكافيهات', 'label': 'مطاعم وكافيهات'},
    {'value': 'ممرض', 'label': 'تمريض منزلي / جروح'},
    {'value': 'دكتور', 'label': 'دكتور / عيادة طبية'},
    {'value': 'صيدلية', 'label': 'صيدلية'},
    {'value': 'صيانة أجهزة منزلية', 'label': 'صيانة أجهزة منزلية'},
    {'value': 'فوتوسيشن أفراح', 'label': 'فوتوسيشن أفراح والمناسبات'},
    {'value': 'محلات ملابس', 'label': 'محلات ملابس'},
    {'value': 'محامين', 'label': 'محامين واستشارات قانونية'},
    {'value': 'دي جي ومناسبات', 'label': 'دي جي ومناسبات'},
    {'value': 'مصممين', 'label': 'مصممين'},
    {'value': 'فني سيراميك ورخام', 'label': 'فني سيراميك ورخام'},
    {'value': 'مصممة أزياء وخياطة', 'label': 'مصممة أزياء وخياطة'},
    {'value': 'سنترال ومحمول', 'label': 'سنترال ومحمول'},
    {'value': 'بيع أحذية وملابس رياضية', 'label': 'بيع أحذية وملابس رياضية'},
    {'value': 'تأجير بدل ومغسلة', 'label': 'تأجير بدل ومغسلة'},
    {'value': 'نجار', 'label': 'نجار'},
    {'value': 'قرآن', 'label': 'تحفيظ قرآن'},
    {'value': 'ستائر', 'label': 'ستائر'},
    {'value': 'سباك', 'label': 'سباك'},
    {'value': 'فني دش', 'label': 'فني دش / ستالايت'},
    {'value': 'ميكانيكي', 'label': 'ميكانيكي سيارات'},
    {'value': 'كهربائي', 'label': 'كهربائي وتأسيس'},
    {'value': 'نقاش', 'label': 'نقاش / دهانات'},
    {'value': 'سائق', 'label': 'سائق / توصيل'},
    {'value': 'مدرس', 'label': 'مدرس / معلم مادة'},
    {'value': 'حداد', 'label': 'حداد'},
    {'value': 'معمل تحاليل', 'label': 'معمل تحاليل طبية'},
    {'value': 'جيم', 'label': 'جيم وصالة لياقة'},
    {'value': 'كاميرات مراقبة', 'label': 'كاميرات مراقبة وأنظمة أمنية'},
    {'value': 'أخرى', 'label': 'خدمات أخرى متنوعة'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  bool get _needsSubject =>
      _selectedCategory == 'مدرس' || _selectedCategory == 'دكتور';

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedImageBase64 = base64Encode(bytes);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر اختيار الصورة')),
        );
      }
    }
  }

  Future<void> _submit() async {
    final user = AuthService.currentUser;
    if (user == null || user.uid.startsWith('guest_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجّل الدخول أولاً علشان تقدر تسجل خدمتك.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final providers = await FirebaseService.getProvidersOnce();

      final duplicate = providers.any(
        (provider) => provider.phone.trim() == phone,
      );

      if (duplicate) {
        throw Exception('duplicate_phone');
      }

      final pin = (1000 + Random().nextInt(9000)).toString();

      await FirebaseService.addProvider({
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'city': _selectedVillage,
        'phone': phone,
        'address': _addressController.text.trim(),
        'notes': _notesController.text.trim(),
        'pin': pin,
        'subject': _needsSubject ? _subjectController.text.trim() : '',
        'imageUrl': _pickedImageBase64 ?? '',
        'isVerified': false,
        'isPinned': false,
        'viewsCount': 0,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('تم إرسال طلبك بنجاح 🚀'),
            content: Text(
              'تم إرسال بيانات خدمتك للإدارة للمراجعة والنشر.\n\n'
              'احتفظ برقم الـ PIN الخاص بك:\n\n$pin',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                height: 1.8,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('تم'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().contains('duplicate_phone')
          ? 'رقم التليفون ده مسجل بالفعل بالدليل!'
          : 'حدث خطأ أثناء إرسال طلب الخدمة. تأكد من الإنترنت وحاول مرة أخرى.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: e.toString().contains('duplicate_phone')
              ? AppTheme.warning
              : AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _decoration(
    String label,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('إضافة خدمة'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سجّل خدمتك في دليل المركز',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'املأ البيانات وسيتم إرسال طلبك للإدارة للمراجعة والنشر.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'اسم الخدمة / مقدم الخدمة',
                    'مثال: دكتور أحمد أو مطعم...',
                    Icons.business_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اكتب اسم الخدمة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _decoration(
                    'نوع الخدمة',
                    '',
                    Icons.category_rounded,
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['value'],
                      child: Text(
                        category['label']!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCategory = value;
                      if (!_needsSubject) {
                        _subjectController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (_needsSubject)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _subjectController,
                      decoration: _decoration(
                        _selectedCategory == 'دكتور'
                            ? 'التخصص الطبي'
                            : 'المادة الدراسية',
                        _selectedCategory == 'دكتور'
                            ? 'مثال: باطنة، أطفال...'
                            : 'مثال: رياضيات، إنجليزي...',
                        Icons.badge_rounded,
                      ),
                    ),
                  ),
                DropdownButtonFormField<String>(
                  value: _selectedVillage,
                  decoration: _decoration(
                    'القرية',
                    '',
                    Icons.location_on_rounded,
                  ),
                  items: _villages.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedVillage = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'رقم التليفون',
                    '010xxxxxxxx',
                    Icons.phone_rounded,
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    if (!RegExp(r'^01[0-9]{9}$').hasMatch(phone)) {
                      return 'اكتب رقم مصري صحيح مثل 010xxxxxxxx';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'العنوان التفصيلي',
                    'مثال: شارع المدارس، بجوار الجمعية',
                    Icons.place_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اكتب العنوان';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: _decoration(
                    'نبذة عن الخدمة / المواعيد',
                    'اكتب مواعيد العمل أو تفاصيل إضافية',
                    Icons.notes_rounded,
                  ),
                ),
                const SizedBox(height: 16),
                // Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _pickedImageBase64 != null
                            ? AppTheme.primary
                            : AppTheme.border,
                        width: _pickedImageBase64 != null ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_pickedImageBase64 != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              base64Decode(_pickedImageBase64!),
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_rounded,
                              color: AppTheme.primary,
                              size: 32,
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          _pickedImageBase64 != null
                              ? 'اضغط لتغيير الصورة'
                              : 'أضف صورة شخصية أو للخدمة',
                          style: TextStyle(
                            color: _pickedImageBase64 != null
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_pickedImageBase64 != null)
                          TextButton.icon(
                            onPressed: () => setState(() => _pickedImageBase64 = null),
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppTheme.danger, size: 18),
                            label: const Text(
                              'حذف الصورة',
                              style: TextStyle(
                                color: AppTheme.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isLoading
                        ? 'جاري إرسال الطلب...'
                        : 'تقديم طلب تسجيل خدمتك للمراجعة 🚀',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'بعد الإرسال ستراجع الإدارة البيانات ثم تنشر الخدمة في الدليل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
