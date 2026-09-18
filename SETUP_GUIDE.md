# 🚀 دليل تشغيل تطبيق خدمات المساح والمقاول

## 📋 متطلبات النظام

| البرنامج | الإصدار المطلوب | رابط التحميل |
|----------|----------------|--------------|
| Flutter SDK | 3.0.0+ | https://docs.flutter.dev/get-started/install |
| Android Studio | أحدث إصدار | https://developer.android.com/studio |
| JDK | 17+ | مدمج مع Android Studio |
| Git | أحدث إصدار | https://git-scm.com/downloads |

---

## 🔧 الخطوة 1: تثبيت Flutter

### على Windows:
```powershell
# 1. نزل Flutter SDK
# من الرابط: https://docs.flutter.dev/get-started/install/windows

# 2. فك الضغط في C:lutter

# 3. أضف للـ Environment Path:
# C:lutterin

# 4. تأكد من التثبيت
flutter doctor
```

### على macOS:
```bash
# باستخدام Homebrew
brew install flutter

# أو نزل يدوياً
# https://docs.flutter.dev/get-started/install/macos

flutter doctor
```

### على Linux:
```bash
sudo snap install flutter --classic
flutter doctor
```

---

## 📱 الخطوة 2: إعداد Android Studio

```bash
# 1. افتح Android Studio
# 2. Tools > SDK Manager
# 3. تأكد من تثبيت:
#    - Android SDK (API 34)
#    - Android SDK Command-line Tools
#    - Android Emulator
#    - Android SDK Platform-Tools

# 4. أنشئ Emulator (اختياري للاختبار):
#    Tools > Device Manager > Create Device
```

---

## 📦 الخطوة 3: فك المشروع

```bash
# فك الضغط
unzip amrtools_app_flutter.zip
cd amrtools_app

# تثبيت الحزم
flutter pub get
```

---

## 🔤 الخطوة 4: إضافة خط Cairo

```bash
# 1. نزل خط Cairo من Google Fonts:
# https://fonts.google.com/specimen/Cairo

# 2. حط الملفات في المجلد:
mkdir -p assets/fonts
# انسخ الملفات:
# - Cairo-Regular.ttf
# - Cairo-Bold.ttf  
# - Cairo-Black.ttf
```

---

## 🔥 الخطوة 5: إعداد Firebase

### 5.1 تثبيت Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 5.2 تفعيل Firebase في المشروع
```bash
# ثبّت flutterfire_cli
dart pub global activate flutterfire_cli

# أضف للـ PATH (لو مش مضاف)
export PATH="$PATH:$HOME/.pub-cache/bin"

# اربط المشروع بـ Firebase
flutterfire configure --project=el-iraqia-services
```

> ⚠️ **مهم:** لازم تكون مسجل دخول بحساب Google اللي فيه مشروع `el-iraqia-services`

### 5.3 تفعيل Authentication في Firebase Console
```
1. افتح: https://console.firebase.google.com
2. اختار مشروع: el-iraqia-services
3. Authentication > Get Started
4. فعّل:
   - Email/Password
   - Phone
5. احفظ
```

### 5.4 إعدادات Security Rules
```
Realtime Database > Rules:

{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    "providers": { ".read": true, ".write": false 
    },
    "pendingProviders": { ".read": false, ".write": true 
    },
    "market_products": { ".read": true, ".write": true 
    },
    "urgent_requests": { ".read": true, ".write": true 
    },
    "deaths": { ".read": true, ".write": false 
    },
    "heroes": { ".read": true, ".write": false 
    },
    "pendingHeroes": { ".read": false, ".write": true 
    },
    "reviews": { ".read": true, ".write": true 
    },
    "high_school_bookings": { ".read": false, ".write": true 
    },
    "settings": { ".read": true, ".write": false 
    },
    "ticker": { ".read": true, ".write": false 
    },
    "globalNotification": { ".read": true, ".write": false 
    }
  }
}
```

---

## ⚙️ الخطوة 6: إعدادات Android

### في `android/app/build.gradle`:
```gradle
android {
    namespace "com.amr.amrtools"
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.amr.amrtools"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            storeFile file("release-key.jks")
            storePassword "your-password"
            keyAlias "amrtools"
            keyPassword "your-password"
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### إنشاء مفتاح التوقيع:
```bash
cd android/app
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias amrtools
```

---

## 🚀 الخطوة 7: تشغيل التطبيق

### على Emulator:
```bash
flutter emulators --launch <emulator_name>
flutter run
```

### على جهاز حقيقي:
```bash
# فعّل USB Debugging على الموبايل
# وصل الموبايل بالكمبيوتر
flutter devices
flutter run -d <device_id>
```

---

## 📦 الخطوة 8: بناء APK للنشر

### APK للاختبار:
```bash
flutter build apk --release
# الملف: build/app/outputs/flutter-apk/app-release.apk
```

### AAB للـ Google Play:
```bash
flutter build appbundle --release
# الملف: build/app/outputs/bundle/release/app-release.aab
```

---

## 🌐 الخطوة 9: رفع على Google Play

```
1. سجل في Google Play Console ($25 مرة واحدة)
   https://play.google.com/console

2. أنشئ تطبيق جديد
   - اختار "Create app"
   - اختار اللغة: Arabic
   - اكتب الاسم: خدمات المساح والمقاول

3. املأ بيانات المتجر:
   - Short description (80 حرف)
   - Full description (4000 حرف)
   - Screenshots (Phone: 2-8 صور)
   - Feature Graphic (1024x500)
   - App Icon (512x512)

4. ارفع الـ AAB:
   Production > Create new release
   ارفع ملف app-release.aab

5. املأ:
   - Content rating
   - Target audience
   - News apps (No)
   - Data safety
   - Privacy policy

6. ارسل للمراجعة (1-3 أيام)
```

---

## 📁 هيكل المشروع النهائي

```
amrtools_app/
├── android/
│   └── app/
│       ├── build.gradle
│       └── release-key.jks
├── assets/
│   ├── images/
│   │   └── logo.png
│   └── fonts/
│       ├── Cairo-Regular.ttf
│       ├── Cairo-Bold.ttf
│       └── Cairo-Black.ttf
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── provider_model.dart
│   │   ├── product_model.dart
│   │   ├── request_model.dart
│   │   ├── deceased_model.dart
│   │   └── hero_model.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── firebase_service.dart
│   ├── screens/
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── directory_screen.dart
│   │   ├── provider_detail_screen.dart
│   │   ├── market_screen.dart
│   │   ├── add_service_screen.dart
│   │   ├── add_product_screen.dart
│   │   ├── results_screen.dart
│   │   ├── heroes_screen.dart
│   │   ├── deceased_screen.dart
│   │   └── urgent_screen.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       └── custom_widgets.dart
├── pubspec.yaml
└── FIREBASE_SETUP_GUIDE.md
```

---

## 🐛 حل المشاكل الشائعة

### مشكلة: `flutter doctor` يظهر أخطاء
```bash
# Windows: شغل PowerShell كـ Administrator
# macOS/Linux: شغل Terminal

# ثبّت Android SDK Command-line Tools
# Android Studio > SDK Manager > SDK Tools
```

### مشكلة: Firebase مش متصل
```bash
# تأكد من:
1. firebase login (مسجل دخول)
2. flutterfire configure --project=el-iraqia-services
3. ملف lib/firebase_options.dart موجود
```

### مشكلة: الخط العربي مش ظاهر
```bash
# تأكد من:
1. الملفات في assets/fonts/
2. pubspec.yaml فيه قسم fonts
3. flutter clean && flutter pub get
```

### مشكلة: OTP مش بيجي
```bash
# تأكد من:
1. فعّل Phone Auth في Firebase Console
2. أضف SHA-1 fingerprint:
   cd android
   ./gradlew signingReport
# انسخ SHA-1 وحطه في Firebase Console > Project Settings
```

---

## 📞 للدعم

المهندس / عمرو جمال عوض
