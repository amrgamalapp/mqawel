import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null || user.isAnonymous) {
      return const _EmptyRequests();
    }

    final ref = FirebaseDatabase.instance.ref('userRequests/${user.uid}');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: const Text('طلباتي 📋', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: ref.onValue,
          builder: (context, snapshot) {
            final raw = snapshot.data?.snapshot.value;
            if (raw is! Map || raw.isEmpty) return const _EmptyRequests();
            final items = <Map<String, dynamic>>[];
            raw.forEach((key, value) {
              if (value is Map) items.add({'id': '$key', ...Map<String, dynamic>.from(value.map((k, v) => MapEntry('$k', v)))});
            });
            items.sort((a, b) => _toInt(b['createdAt']).compareTo(_toInt(a['createdAt'])));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = items[i];
                final status = item['status']?.toString() ?? 'جديد';
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(item['category']?.toString() ?? 'طلب خدمة', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                      _StatusChip(status: status),
                    ]),
                    const SizedBox(height: 8),
                    Text(item['details']?.toString() ?? '', style: const TextStyle(color: AppTheme.textSecondary, height: 1.5)),
                    const SizedBox(height: 8),
                    Text(_formatDate(_toInt(item['createdAt'])), style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                  ]),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static int _toInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  static String _formatDate(int value) {
    if (value <= 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(value);
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'مكتمل' ? AppTheme.success : status == 'مقبول' ? AppTheme.primary : AppTheme.warning;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10)));
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('لا توجد طلبات حتى الآن', style: TextStyle(fontWeight: FontWeight.w800))));
}
