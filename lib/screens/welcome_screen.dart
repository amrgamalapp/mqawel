import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 26),

                // ─── Logo ──────────────────────────────────────────
                Container(
                  width: 128,
                  height: 128,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.10),
                        blurRadius: 22,
                        spreadRadius: 3,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ─── App title ─────────────────────────────────────
                const Text(
                  'خدمات المساح والمقاول',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'دليل شامل لمكاتب المساحة وشركات المقاولات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Feature cards (8 primary categories) ─────────
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: const [
                    _FeatureCard(
                      icon: Icons.assignment_rounded,
                      title: 'طلبات الخدمات',
                      color: Color(0xFF0F766E),
                    ),
                    _FeatureCard(
                      icon: Icons.storefront_rounded,
                      title: 'المتجر',
                      color: Color(0xFFEA580C),
                    ),
                    _FeatureCard(
                      icon: Icons.engineering_rounded,
                      title: 'حاسبة كميات',
                      color: Color(0xFF14B8A6),
                    ),
                    _FeatureCard(
                      icon: Icons.archive_rounded,
                      title: 'أرشيف المشاريع',
                      color: Color(0xFF7C3AED),
                    ),
                    _FeatureCard(
                      icon: Icons.map_rounded,
                      title: 'خريطة المكاتب',
                      color: Color(0xFF059669),
                    ),
                    _FeatureCard(
                      icon: Icons.handyman_rounded,
                      title: 'المعدات',
                      color: Color(0xFFB45309),
                    ),
                    _FeatureCard(
                      icon: Icons.bookmark_added_rounded,
                      title: 'المفضلة',
                      color: Color(0xFFDB2777),
                    ),
                    _FeatureCard(
                      icon: Icons.notifications_rounded,
                      title: 'الإشعارات',
                      color: Color(0xFFDC2626),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // ─── CTA Buttons ───────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.login_rounded, size: 19),
                        label: const Text('تسجيل الدخول'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_alt_rounded, size: 19),
                        label: const Text('إنشاء حساب'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                TextButton.icon(
                  onPressed: () async {
                    await AuthService.signInAsGuest();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text(
                    'استكشف التطبيق كزائر',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
