
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DeceasedScreen extends StatelessWidget {
  const DeceasedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قريباً')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.engineering_rounded, size: 56, color: AppTheme.textLight),
              SizedBox(height: 10),
              Text('تم إيقاف قسم الوفيات.', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              SizedBox(height: 4),
              Text('التطبيق متخصص في المساحة والمقاولات.', style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
