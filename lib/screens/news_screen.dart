import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  Future<void> _open(String? link) async {
    if (link == null || link.trim().isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          title: const Text('مركز الأخبار 🔥', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebaseService.getNews(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snapshot.data ?? <Map<String, dynamic>>[];
            if (list.isEmpty) {
              return const Center(
                child: Text('لا توجد أخبار منشورة حالياً.', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final n = list[index];
                final link = n['link']?.toString() ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                            child: Text(n['badge']?.toString() ?? 'خبر', style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                          const Spacer(),
                          Text(n['date']?.toString() ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(n['title']?.toString() ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Text(n['body']?.toString() ?? '', style: const TextStyle(fontSize: 12, height: 1.8, color: AppTheme.textSecondary)),
                      if (link.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _open(link),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: Text(n['linkText']?.toString() ?? 'التفاصيل'),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
