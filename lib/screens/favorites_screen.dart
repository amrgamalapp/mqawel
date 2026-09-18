import 'package:flutter/material.dart';

import '../models/provider_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import 'provider_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = AuthService.currentUser;

    if (u == null) {
      return const _Empty();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: const Text(
            'المفضلة ❤️',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: StreamBuilder<Set<String>>(
          stream: FirebaseService.getFavoriteProviderKeys(u.uid),
          builder: (context, favoritesSnapshot) {
            final favorites = favoritesSnapshot.data ?? <String>{};

            return StreamBuilder<List<ProviderModel>>(
              stream: FirebaseService.getProviders(),
              builder: (context, providersSnapshot) {
                final providers = providersSnapshot.data ?? <ProviderModel>[];

                final list = providers
                    .where((provider) => favorites.contains(provider.key))
                    .toList();

                if (list.isEmpty) {
                  return const _Empty();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final provider = list[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.primaryLight,
                          child: Icon(
                            Icons.favorite_rounded,
                            color: AppTheme.danger,
                          ),
                        ),
                        title: Text(
                          provider.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        subtitle: Text(
                          '${provider.category} • ${provider.city}',
                        ),
                        trailing: const Icon(
                          Icons.chevron_left_rounded,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProviderDetailScreen(
                                provider: provider,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

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
            'المفضلة ❤️',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'لا توجد خدمات في المفضلة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
