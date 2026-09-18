import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

Widget buildRemoteOrBase64Image(
  String? source, {
  BoxFit fit = BoxFit.cover,
  Widget? fallback,
}) {
  final value = source?.trim() ?? '';
  if (value.isEmpty) return fallback ?? const SizedBox.shrink();

  // يدعم الصور المخزنة في الموقع كـ Data URI أو Base64 خام، بالإضافة للروابط.
  if (value.startsWith('data:image/')) {
    try {
      final comma = value.indexOf(',');
      if (comma >= 0) {
        final Uint8List bytes = base64Decode(value.substring(comma + 1));
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback ?? const Icon(Icons.person_rounded),
        );
      }
    } catch (_) {}
    return fallback ?? const Icon(Icons.person_rounded);
  }

  // بعض البيانات القديمة في الموقع قد تكون Base64 خاماً بدون data:image/.
  if (!value.contains('://') && value.length > 100) {
    try {
      final Uint8List bytes = base64Decode(value);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback ?? const Icon(Icons.person_rounded),
      );
    } catch (_) {
      // ليست Base64؛ نتعامل معها كرابط صورة عادي بالأسفل.
    }
  }

  return Image.network(
    value,
    fit: fit,
    errorBuilder: (_, __, ___) => fallback ?? const Icon(Icons.person_rounded),
  );
}
