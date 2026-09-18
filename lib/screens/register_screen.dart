import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _officeCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();

  int _modeIndex = 1; // 0 engineer (مساح) | 1 contractor (مقاول) | 2 client
  bool _isLoading = false;
  bool _accept = false;

  static const _specialties = <String>[
    'مساحة أراضي',
    'مساحة معمارية',
    'مساحة جيولوجية',
    'مساحة بحرية',
    'مقاولات عامة',
    'مقاولات تشطيبات',
    'مقاولات كهرباء',
    'مقاولات سباكة',
    'هدم وإزالة',
    'حفر وردم',
  ];

  String _specialty = _specialties.first;

  static const _modes = <_RoleMode>[
    _RoleMode(label: 'مساح', icon: Icons.architecture_rounded, color: Color(0xFF0F766E)),
    _RoleMode(label: 'مقاول', icon: Icons.construction_rounded, color: Color(0xFFEA580C)),
    _RoleMode(label: 'عميل', icon: Icons.person_rounded, color: Color(0xFF7C3AED)),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _officeCtrl.dispose();
    _licenseCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accept) {
      _show('وافق على الشروط أولاً.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final cred = await AuthService.signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      await AuthService.updateProfile(
        name: _nameCtrl.text.trim(),
        extra: {
          'phone'      : _phoneCtrl.text.trim(),
          'office'     : _officeCtrl.text.trim(),
          'licenseNo'  : _licenseCtrl.text.trim(),
          'role'       : _modes[_modeIndex].label,
          'specialty'  : _specialty,
          'createdAt'  : DateTime.now().millisecondsSinceEpoch,
        },
      );
      if (mounted && cred != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _show(_humanError(e.code));
    } catch (_) {
      _show('حدث خطأ غير متوقع.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _humanError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'هذا البريد مسجل مسبقاً.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، يجب أن تكون 6 أحرف على الأقل.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      default:
        return 'تعذر إنشاء الحساب، حاول مرة أخرى.';
    }
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final role = _modes[_modeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ─── Logo ─────────────────────────────────────────
                  Container(
                    width: 78,
                    height: 78,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child:
                          Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'انضم إلى مجتمع المساحين والمقاولين',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ─── Role selector ────────────────────────────────
                  Row(
                    children: List.generate(_modes.length, (i) {
                      final m = _modes[i];
                      final sel = _modeIndex == i;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == 0 ? 0 : 6,
                            left:  i == _modes.length - 1 ? 0 : 6,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _modeIndex = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: sel ? m.color.withOpacity(0.10) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel ? m.color : AppTheme.border,
                                  width: sel ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(m.icon, color: m.color, size: 22),
                                  const SizedBox(height: 6),
                                  Text(
                                    m.label,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: sel ? m.color : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 18),

                  _field(_nameCtrl, 'الاسم بالكامل',
                      'اكتب اسمك بالكامل', Icons.person_outline_rounded),

                  const SizedBox(height: 12),
                  _field(_emailCtrl, 'البريد الإلكتروني',
                      'name@example.com', Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress),

                  const SizedBox(height: 12),
                  _field(_passwordCtrl, 'كلمة المرور',
                      '6 أحرف على الأقل', Icons.lock_outline_rounded,
                      isPassword: true),

                  const SizedBox(height: 12),
                  _field(_phoneCtrl, 'رقم الهاتف',
                      '01XXXXXXXXX', Icons.phone_outlined,
                      keyboardType: TextInputType.phone),

                  const SizedBox(height: 12),
                  _field(_officeCtrl,
                      'اسم ${role.label == 'عميل' ? 'الشركة (اختياري)' : 'المكتب / الشركة'}',
                      'مثلاً: مكتب العز للمساحة', Icons.business_rounded),

                  if (role.label != 'عميل') ...[
                    const SizedBox(height: 12),
                    _field(_licenseCtrl,
                        'رقم القيد / الترخيص (اختياري)',
                        'رقم القيد بالنقابة أو السجل التجاري',
                        Icons.assignment_rounded),

                    const SizedBox(height: 12),
                    _buildSpecialtyDropdown(role.color),
                  ],

                  const SizedBox(height: 16),

                  // ─── Accept checkbox ─────────────────────────────
                  InkWell(
                    onTap: () => setState(() => _accept = !_accept),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _accept,
                          onChanged: (v) => setState(() => _accept = v ?? false),
                          activeColor: role.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'أوافق على شروط الاستخدام وسياسة الخصوصية لتطبيق خدمات المساح والمقاول.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.4,
                            ),
                          )
                        : Icon(Icons.person_add_alt_rounded, color: Colors.white),
                    label: Text(
                      'إنشاء حساب كـ ${role.label}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: role.color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'خدمات المساح والمقاول © 2026\nتطوير: عمرو جمال عوض',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyDropdown(Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _specialty,
          icon: Icon(Icons.expand_more_rounded, color: accentColor),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          items: _specialties
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _specialty = v);
          },
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 5),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 12,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextFormField(
          controller: c,
          keyboardType: keyboardType,
          obscureText: isPassword,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppTheme.textLight,
              fontFamily: 'Cairo',
              fontSize: 12,
            ),
            prefixIcon: Icon(icon, color: AppTheme.primary, size: 21),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleMode {
  final String label;
  final IconData icon;
  final Color color;
  const _RoleMode({required this.label, required this.icon, required this.color});
}
