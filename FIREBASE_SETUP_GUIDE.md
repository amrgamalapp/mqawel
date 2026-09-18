# 🔥 دليل ربط تطبيق Flutter بـ Firebase (نفس بيانات الموقع)

## الخطوة 1: إنشاء مشروع Flutter جديد (أو استخدام المشروع الحالي)

```bash
flutter create amrtools_app
cd amrtools_app
```

## الخطوة 2: تثبيت Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

## الخطوة 3: تفعيل Firebase في المشروع

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=el-iraqia-services
```

> ⚠️ **ملاحظة مهمة:** لازم تكون مسجل دخول بحساب Google اللي فيه مشروع `el-iraqia-services`

## الخطوة 4: تثبيت حزم Firebase

```bash
flutter pub add firebase_core firebase_database firebase_auth
```

## الخطوة 5: التأكد من إعدادات Android

### في `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        applicationId "com.example.amrtools_app"  // غيره للـ Package Name بتاعك
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### في `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### في `android/app/build.gradle` (آخر الملف):

```gradle
apply plugin: 'com.google.gms.google-services'
```

## الخطوة 6: التأكد من إعدادات iOS (لو هتنزل على iPhone)

```bash
cd ios
pod install
cd ..
```

## الخطوة 7: تشغيل التطبيق

```bash
flutter run
```

---

## 🗄️ هيكل قاعدة البيانات (Realtime Database)

التطبيق بيقرأ من نفس الـ Database اللي الموقع بيكتب فيها:

```json
{
  "providers": {
    "provider_id_1": {
      "name": "محمد أحمد",
      "category": "دكتور",
      "village": "العراقية",
      "phone": "01012345678",
      "address": "شارع المدارس",
      "notes": "عيادة من 9 ص لـ 5 م",
      "isVerified": true,
      "isPinned": false,
      "viewsCount": 45,
      "createdAt": 1700000000000
    }
  },
  "pendingProviders": { ... },
  "market_products": { ... },
  "urgent_requests": { ... },
  "deaths": { ... },
  "heroes": { ... },
  "pendingHeroes": { ... },
  "reviews": {
    "provider_id_1": {
      "review_id_1": {
        "author": "أحمد",
        "text": "خدمة ممتازة",
        "stars": 5,
        "createdAt": 1700000000000
      }
    }
  },
  "high_school_bookings": { ... },
  "settings": {
    "wheel": { "enabled": true, "weights": [10,5,15,10,60] },
    "devNotice": { "enabled": true, "title": "...", "body": "..." }
  },
  "ticker": { "text": "آخر الأخبار..." },
  "globalNotification": { "title": "...", "message": "..." }
}
```

---

## 🔒 Security Rules (مهم جداً!)

### في Firebase Console > Realtime Database > Rules:

```json
{
  "rules": {
    "providers": {
      ".read": true,
      ".write": false
    },
    "pendingProviders": {
      ".read": false,
      ".write": true
    },
    "market_products": {
      ".read": true,
      ".write": true
    },
    "urgent_requests": {
      ".read": true,
      ".write": true
    },
    "deaths": {
      ".read": true,
      ".write": false
    },
    "heroes": {
      ".read": true,
      ".write": false
    },
    "pendingHeroes": {
      ".read": false,
      ".write": true
    },
    "reviews": {
      ".read": true,
      ".write": true
    },
    "high_school_bookings": {
      ".read": false,
      ".write": true
    },
    "settings": {
      ".read": true,
      ".write": false
    },
    "ticker": {
      ".read": true,
      ".write": false
    },
    "globalNotification": {
      ".read": true,
      ".write": false
    }
  }
}
```

---

## 📱 بناء APK للنشر

```bash
# APK للاختبار
flutter build apk --release

# AAB للرفع على Google Play
flutter build appbundle --release
```

## 🚀 رفع على Google Play

1. سجل في [Google Play Console](https://play.google.com/console) ($25)
2. أنشئ تطبيق جديد
3. ارفع ملف `build/app/outputs/bundle/release/app-release.aab`
4. املأ بيانات المتجر (صور، وصف، سياسة خصوصية)
5. انتظر المراجعة (1-3 أيام)

---

## ⚠️ ملاحظات مهمة

1. **مفاتيح Firebase** في الكود للقراءة فقط - مفيش مشكلة أمان لو الـ Rules مظبوطة
2. **الصور** بتتحمل على Firebase Storage أو Base64 في الـ Database
3. **الإشعارات** تحتاج Firebase Cloud Messaging (FCM)
4. **التحليلات** تحتاج Firebase Analytics

---

## 📞 للدعم

المهندس عمرو جمال عوض
