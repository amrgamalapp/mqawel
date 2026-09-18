import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  String _village = 'القاهرة';

  bool _loading = true;
  bool _saving = false;

  UserModel? _user;

  static const villages = [
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
    'الإسماعيلية',
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await AuthService.getCurrentUserData();

    if (!mounted) return;

    if (u != null) {
      _user = u;
      _name.text = u.name;
      _phone.text = u.phone ?? '';

      if (villages.contains(u.city)) {
        _village = u.city;
      }
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await AuthService.updateProfile(
        name: _name.text,
        phone: _phone.text,
        city: _village,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ بيانات حسابك بنجاح ✅'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر الحفظ: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: const Text(
            'حسابي',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppTheme.primary,
                        size: 50,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _user?.email ?? '',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: AppTheme.success, size: 17),
                      ],
                    ),

                    const SizedBox(height: 16),

                    FutureBuilder<List<int>>(
                      future: _loadAccountStats(),
                      builder: (context, snapshot) {
                        final favorites = snapshot.data?[0] ?? 0;
                        final requests = snapshot.data?[1] ?? 0;
                        final points = favorites * 10 + requests * 20;
                        final level = points >= 500 ? 'عضو مميز 🏆' : points >= 200 ? 'عضو نشط ⭐' : 'عضو جديد 🌱';
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(.07),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _stat('النقاط', '$points', Icons.stars_rounded)),
                              Expanded(child: _stat('المفضلة', '$favorites', Icons.favorite_rounded)),
                              Expanded(child: _stat('الطلبات', '$requests', Icons.assignment_rounded)),
                              Expanded(child: _stat('المستوى', level, Icons.emoji_events_rounded)),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    _field(
                      'الاسم بالكامل',
                      _name,
                      Icons.person_rounded,
                    ),

                    const SizedBox(height: 12),

                    _field(
                      'رقم الهاتف',
                      _phone,
                      Icons.phone_rounded,
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: villages.contains(_village)
                          ? _village
                          : villages.first,
                      isExpanded: true,
                      decoration: _dec(
                        'القرية',
                        Icons.location_on_rounded,
                      ),
                      items: villages
                          .map(
                            (v) => DropdownMenuItem<String>(
                              value: v,
                              child: Text(v),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _village = v ?? _village;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          _saving
                              ? 'جاري الحفظ...'
                              : 'حفظ البيانات',
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const _ResetDialog(),
                        );
                      },
                      icon: const Icon(
                        Icons.lock_reset_rounded,
                      ),
                      label: const Text(
                        'تغيير كلمة المرور',
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  InputDecoration _dec(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
        borderSide: BorderSide(
          color: AppTheme.primary,
          width: 1.6,
        ),
      ),
    );
  }

  Future<List<int>> _loadAccountStats() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return [0, 0];
    final fav = await FirebaseService.getFavoriteProviderKeys(uid).first;
    final requestSnap = await FirebaseDatabase.instance.ref('userRequests/$uid').get();
    final requests = requestSnap.value is Map ? (requestSnap.value as Map).length : 0;
    return [fav.length, requests];
  }

  Widget _stat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
        const SizedBox(height: 2),
        Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: _dec(label, icon),
    );
  }
}

class _ResetDialog extends StatefulWidget {
  const _ResetDialog();

  @override
  State<_ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends State<_ResetDialog> {
  final c = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'إرسال رابط تغيير كلمة المرور',
      ),
      content: TextField(
        controller: c,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'البريد الإلكتروني',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() {
                    loading = true;
                  });

                  try {
                    await AuthService.sendPasswordReset(
                      c.text.trim(),
                    );

                    if (context.mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم إرسال الرابط إلى بريدك الإلكتروني ✅',
                          ),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تعذر الإرسال: $e',
                          ),
                          backgroundColor: AppTheme.danger,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        loading = false;
                      });
                    }
                  }
                },
          child: const Text('إرسال'),
        ),
      ],
    );
  }
}
