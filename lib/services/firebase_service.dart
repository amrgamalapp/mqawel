import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/provider_model.dart';
import '../models/product_model.dart';
import '../models/request_model.dart';
import '../models/deceased_model.dart';
import '../models/hero_model.dart';

class FirebaseService {
  static final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://el-iraqia-services-default-rtdb.firebaseio.com',
  );

  // ============================================================
  // Debug
  // ============================================================

  static void _log(String message) {
    debugPrint('🔥 FirebaseService: $message');
  }

  // ============================================================
  // Helpers
  // ============================================================

  static Map<dynamic, dynamic>? _asMap(dynamic value) {
    if (value is Map<dynamic, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<dynamic, dynamic>.from(value);
    }

    return null;
  }

  static int _intValue(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  // ============================================================
  // Notifications
  // ============================================================

  static Stream<List<Map<String, dynamic>>> getNotifications() {
    _log('Connecting to notifications...');

    return _db.ref('notifications').onValue.handleError((error) {
      _log('❌ notifications error: $error');
    }).map((event) {
      final data = _asMap(event.snapshot.value);

      if (data == null || data.isEmpty) {
        _log('⚠️ notifications empty');
        return <Map<String, dynamic>>[];
      }

      final list = <Map<String, dynamic>>[];

      for (final entry in data.entries) {
        final map = _asMap(entry.value);
        if (map == null) continue;

        list.add({
          'id': entry.key.toString(),
          'title': map['title']?.toString() ?? 'إشعار جديد',
          'body': map['body']?.toString() ?? '',
          'createdAt': _intValue(map['createdAt']),
          'targetTopic': map['targetTopic']?.toString() ?? 'all',
        });
      }

      list.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));
      _log('✅ notifications parsed: ${list.length}');
      return list;
    });
  }

  // ============================================================
  // Providers
  // ============================================================

  static Stream<List<ProviderModel>> getProviders() {
    _log('Connecting to providers...');

    return _db.ref('providers').onValue.handleError((error) {
      _log('❌ providers error: $error');
    }).map((event) {
      final raw = event.snapshot.value;
      final data = _asMap(raw);

      if (data == null || data.isEmpty) {
        _log('⚠️ providers empty');
        return <ProviderModel>[];
      }

      final list = <ProviderModel>[];

      for (final entry in data.entries) {
        final map = _asMap(entry.value);

        if (map == null) {
          continue;
        }

        try {
          list.add(
            ProviderModel.fromMap(
              entry.key.toString(),
              Map<dynamic, dynamic>.from(map),
            ),
          );
        } catch (e) {
          _log(
            '⚠️ provider parse error ${entry.key}: $e',
          );
        }
      }

      list.sort((a, b) {
        if (a.isPinned && !b.isPinned) {
          return -1;
        }

        if (!a.isPinned && b.isPinned) {
          return 1;
        }

        return b.sortValue.compareTo(a.sortValue);
      });

      _log('✅ providers parsed: ${list.length}');

      return list;
    });
  }

  static Future<List<ProviderModel>> getProvidersOnce() async {
    try {
      final event = await _db.ref('providers').once();

      final data = _asMap(event.snapshot.value);

      if (data == null || data.isEmpty) {
        return <ProviderModel>[];
      }

      final list = <ProviderModel>[];

      for (final entry in data.entries) {
        final map = _asMap(entry.value);

        if (map == null) {
          continue;
        }

        try {
          list.add(
            ProviderModel.fromMap(
              entry.key.toString(),
              Map<dynamic, dynamic>.from(map),
            ),
          );
        } catch (e) {
          _log(
            '⚠️ provider parse error ${entry.key}: $e',
          );
        }
      }

      list.sort((a, b) {
        if (a.isPinned && !b.isPinned) {
          return -1;
        }

        if (!a.isPinned && b.isPinned) {
          return 1;
        }

        return b.sortValue.compareTo(a.sortValue);
      });

      return list;
    } catch (e) {
      _log('❌ getProvidersOnce: $e');
      return <ProviderModel>[];
    }
  }

  // ============================================================
  // Add Provider
  // ============================================================

  static Future<void> addProvider(
    Map<String, dynamic> data,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('auth_required');
    final payload = <String, dynamic>{...data, 'userId': uid};
    await _db.ref('pendingProviders').push().set(payload);
  }

  static Future<void> updateProvider(
    String key,
    Map<String, dynamic> data,
  ) async {
    await _db.ref('providers/$key').update(data);
  }

  static Future<void> incrementViews(
    String key,
    int current,
  ) async {
    await _db.ref('providers/$key').update({
      'viewsCount': current + 1,
    });
  }

  // ============================================================
  // Market
  // ============================================================

  static Stream<List<ProductModel>> getProducts() {
    _log('Connecting to market_products...');

    return _db.ref('market_products').onValue.handleError((error) {
      _log('❌ market_products error: $error');
    }).map((event) {
      final data = _asMap(event.snapshot.value);

      if (data == null || data.isEmpty) {
        return <ProductModel>[];
      }

      final list = <ProductModel>[];

      for (final entry in data.entries) {
        final map = _asMap(entry.value);

        if (map == null) {
          continue;
        }

        try {
          list.add(
            ProductModel.fromMap(
              entry.key.toString(),
              Map<dynamic, dynamic>.from(map),
            ),
          );
        } catch (e) {
          _log(
            '⚠️ product parse error ${entry.key}: $e',
          );
        }
      }

      list.sort(
        (a, b) => (b.createdAt ?? 0).compareTo(
          a.createdAt ?? 0,
        ),
      );

      return list;
    });
  }

  static Future<void> addProduct(
    Map<String, dynamic> data,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('auth_required');
    final payload = <String, dynamic>{...data, 'userId': uid};
    await _db.ref('market_products').push().set(payload);
  }

  // ============================================================
  // Deceased
  // ============================================================

  static Stream<List<DeceasedModel>> getDeceased() {
    _log('Connecting to deaths...');

    return _db.ref('deaths').onValue.handleError((error) {
      _log('❌ deaths error: $error');
    }).map((event) {
      final data = _asMap(event.snapshot.value);

      if (data == null || data.isEmpty) {
        return <DeceasedModel>[];
      }

      final list = <DeceasedModel>[];

      for (final entry in data.entries) {
        final map = _asMap(entry.value);

        if (map == null) {
          continue;
        }

        try {
          list.add(
            DeceasedModel.fromMap(
              entry.key.toString(),
              Map<dynamic, dynamic>.from(map),
            ),
          );
        } catch (e) {
          _log(
            '⚠️ deceased parse error ${entry.key}: $e',
          );
        }
      }

      list.sort(
        (a, b) => (b.createdAt ?? 0).compareTo(
          a.createdAt ?? 0,
        ),
      );

      return list;
    });
  }

  // ============================================================
  // Heroes
  // ============================================================

  static Future<void> addHeroNomination(Map<String, dynamic> data) async {
    await _db.ref('pendingHeroes').push().set(data);
  }

  static Stream<List<HeroModel>> getHeroes() {
    _log('Connecting to heroes...');

    return _db.ref('heroes').onValue.handleError((error) {
      _log('❌ heroes error: $error');
    }).map((event) {
      final data = _asMap(event.snapshot.value);

      if (data == null || data.isEmpty) {
        return <HeroModel>[];
      }

      final list = <HeroModel>[];

      for (final entry in data.entries) {
        final map = _asMap(entry.value);

        if (map == null) {
          continue;
        }

        try {
          list.add(
            HeroModel.fromMap(
              entry.key.toString(),
              Map<dynamic, dynamic>.from(map),
            ),
          );
        } catch (e) {
          _log(
            '⚠️ hero parse error ${entry.key}: $e',
          );
        }
      }

      list.sort(
        (a, b) => (b.createdAt ?? 0).compareTo(
          a.createdAt ?? 0,
        ),
      );

      return list;
    });
  }

  // ============================================================
  // Urgent Requests
  // ============================================================

  static Stream<List<RequestModel>> getRequests() {
    _log('Connecting to urgent_requests...');

    return _db.ref('urgent_requests').onValue.handleError((error) {
      _log('❌ urgent_requests error: $error');
    }).map((event) {
      final data = _asMap(event.snapshot.value);

      if (data == null || data.isEmpty) {
        return <RequestModel>[];
      }

      final list = <RequestModel>[];

      for (final entry in data.entries) {
        final map = _asMap(entry.value);

        if (map == null) {
          continue;
        }

        try {
          list.add(
            RequestModel.fromMap(
              entry.key.toString(),
              Map<dynamic, dynamic>.from(map),
            ),
          );
        } catch (e) {
          _log(
            '⚠️ request parse error ${entry.key}: $e',
          );
        }
      }

      list.sort(
        (a, b) => (b.createdAt ?? 0).compareTo(
          a.createdAt ?? 0,
        ),
      );

      return list;
    });
  }

  static Future<void> addRequest(
    Map<String, dynamic> data,
  ) async {
    final payload = <String, dynamic>{...data};
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && !uid.startsWith('guest_')) {
      payload['userId'] = uid;
    }
    final requestRef = _db.ref('urgent_requests').push();
    await requestRef.set(payload);
    if (uid != null && !uid.startsWith('guest_')) {
      await _db.ref('userRequests/$uid/${requestRef.key}').set({
        ...payload,
        'status': 'جديد',
      });
    }
  }

  // ============================================================
  // Heroes nominations
  // ============================================================

  static Future<void> nominateHero(
    Map<String, dynamic> data,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('auth_required');
    final payload = <String, dynamic>{...data, 'userId': uid};
    await _db.ref('pendingHeroes').push().set(payload);
  }

  // ============================================================
  // Reviews
  // ============================================================

  static Stream<Map<String, List<Map<String, dynamic>>>> getReviews() {
    return _db.ref('reviews').onValue.map((event) {
      final data = _asMap(event.snapshot.value);

      if (data == null || data.isEmpty) {
        return <String, List<Map<String, dynamic>>>{};
      }

      final result =
          <String, List<Map<String, dynamic>>>{};

      data.forEach((providerKey, reviewsMap) {
        final reviews = _asMap(reviewsMap);

        if (reviews == null) {
          return;
        }

        final list = <Map<String, dynamic>>[];

        reviews.forEach((reviewKey, reviewValue) {
          final review = _asMap(reviewValue);

          if (review == null) {
            return;
          }

          list.add({
            'key': reviewKey.toString(),
            ...Map<String, dynamic>.from(review),
          });
        });

        list.sort(
          (a, b) => _intValue(b['createdAt'])
              .compareTo(_intValue(a['createdAt'])),
        );

        result[providerKey.toString()] = list;
      });

      return result;
    });
  }

  static Future<void> addReview(
    String providerKey,
    Map<String, dynamic> data,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('auth_required');
    final payload = <String, dynamic>{...data, 'userId': uid};
    await _db.ref('reviews/$providerKey').push().set(payload);
  }

  static Stream<List<Map<String, dynamic>>> getReviewsForProvider(
    String providerKey,
  ) {
    if (providerKey.trim().isEmpty) {
      return Stream.value(<Map<String, dynamic>>[]);
    }

    return _db.ref('reviews/$providerKey').onValue.map((event) {
      final data = _asMap(event.snapshot.value);

      if (data == null || data.isEmpty) {
        return <Map<String, dynamic>>[];
      }

      final list = <Map<String, dynamic>>[];

      for (final entry in data.entries) {
        final review = _asMap(entry.value);

        if (review == null) {
          continue;
        }

        list.add({
          'key': entry.key.toString(),
          ...Map<String, dynamic>.from(review),
        });
      }

      list.sort(
        (a, b) => _intValue(b['createdAt'])
            .compareTo(_intValue(a['createdAt'])),
      );

      return list;
    });
  }

  // ============================================================
  // App content / admin controlled settings
  // ============================================================

  static Stream<Map<String, dynamic>> getAppSettings() {
    return _db.ref('settings/app').onValue.map((event) {
      final map = _asMap(event.snapshot.value);
      return map == null ? <String, dynamic>{} : Map<String, dynamic>.from(map);
    });
  }

  static Stream<Map<String, dynamic>> getGlobalNotification() {
    return _db.ref('globalNotification').onValue.map((event) {
      final map = _asMap(event.snapshot.value);
      return map == null ? <String, dynamic>{} : Map<String, dynamic>.from(map);
    });
  }

  static Stream<String> getTicker() {
    return _db.ref('ticker').onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw is Map) return raw['text']?.toString() ?? '';
      return raw?.toString() ?? '';
    });
  }

  static Stream<List<Map<String, dynamic>>> getNews() {
    return _db.ref('news').onValue.map((event) {
      final data = _asMap(event.snapshot.value);
      if (data == null) return <Map<String, dynamic>>[];
      final list = <Map<String, dynamic>>[];
      for (final e in data.entries) {
        final m = _asMap(e.value);
        if (m == null) continue;
        list.add({'key': e.key.toString(), ...Map<String, dynamic>.from(m)});
      }
      list.sort((a,b) => _intValue(b['createdAt']).compareTo(_intValue(a['createdAt'])));
      return list;
    });
  }

  static Future<Map<String, dynamic>> getWheelSettings() async {
    final event = await _db.ref('settings/wheel').get();
    final map = _asMap(event.value);
    return map == null ? <String, dynamic>{} : Map<String, dynamic>.from(map);
  }

  static Stream<Map<String, dynamic>> watchWheelSettings() {
    return _db.ref('settings/wheel').onValue.map((event) {
      final map = _asMap(event.snapshot.value);
      return map == null ? <String, dynamic>{} : Map<String, dynamic>.from(map);
    });
  }

  static Stream<List<String>> getCategories() {
    return _db.ref('settings/categories').onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw is List) return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      if (raw is Map) {
        return raw.values.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      }
      return <String>[];
    });
  }

  // ============================================================
  // User favorites
  // ============================================================

  static Stream<Set<String>> getFavoriteProviderKeys(String uid) {
    if (uid.trim().isEmpty || uid.startsWith('guest_')) return Stream.value(<String>{});
    return _db.ref('users/$uid/favorites/providers').onValue.map((event) {
      final raw = _asMap(event.snapshot.value);
      if (raw == null) return <String>{};
      return raw.keys.map((e) => e.toString()).toSet();
    });
  }

  static Future<void> setFavoriteProvider(String uid, String providerKey, bool favorite) async {
    if (uid.trim().isEmpty || uid.startsWith('guest_')) return;
    final ref = _db.ref('users/$uid/favorites/providers/$providerKey');
    if (favorite) {
      await ref.set(true);
    } else {
      await ref.remove();
    }
  }

  static Future<void> incrementProviderViewsSafe(String key) async {
    final ref = _db.ref('providers/$key/viewsCount');
    await ref.runTransaction((value) {
      final n = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
      return Transaction.success(n + 1);
    });
  }

  // ============================================================
  // Results
  // ============================================================

  static Future<void> bookResult(
    Map<String, dynamic> data,
  ) async {
    await _db
        .ref('high_school_bookings')
        .push()
        .set(data);
  }
}
