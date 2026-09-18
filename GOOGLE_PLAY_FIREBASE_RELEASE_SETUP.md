# Google Play + Firebase Release Setup

## Android identity
- Package / Application ID: `com.iraqia.amr`
- Firebase project ID: `el-iraqia-services`
- Firebase project number: `478034761629`
- Android Firebase App ID: `1:478034761629:android:f029998aa2731e0673c174`

## Upload signing
- Keystore: `android/new_upload_key.jks`
- Alias: `upload`
- Upload certificate: `android/upload_certificate.pem`
- The keystore and certificate were verified to have the same SHA-256 fingerprint:
  `F6:03:8A:5B:40:6C:7C:B7:C7:A4:A0:84:C3:A2:0D:A7:05:A5:95:75:0E:4C:FA:30:15:0C:F3:30:A3:58:0E:86`

The keystore password is intentionally not written in this documentation. It is stored in the local `android/key.properties` file required by Gradle.

## Firebase / Google services
- `android/app/google-services.json` is included and targets package `com.iraqia.amr`.
- Google Services Gradle plugin is configured.
- FlutterFire configuration is included in `lib/firebase_options.dart`.
- Firebase App Check is configured in the Flutter app; Android Release uses Play Integrity and debug builds use the debug provider.

## Google Play Console checklist
1. Create/select the Android app using package `com.iraqia.amr`.
2. In Play Console App integrity, use Play App Signing if this is a new Play app.
3. Register the upload certificate / upload key as required by Play Console.
4. For Firebase App Check with Play Integrity, add the Play Console app to the Firebase project and configure the Play Integrity provider for the same Android app.
5. Make sure the Play Console package name and Firebase package name remain exactly `com.iraqia.amr`.
6. Do not change or regenerate the upload key unless you intentionally follow Google's upload-key reset/replacement process.

## Release build
From the project root:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

The Gradle release signing configuration reads `android/key.properties` and signs the release with `android/new_upload_key.jks`.

## Important security note
Never upload `android/new_upload_key.jks` or `android/key.properties` to GitHub or another public repository. Keep an encrypted backup of the keystore and its password.


## Verification performed on 21 Aug 2026
- Upload keystore `android/new_upload_key.jks` was checked with alias `upload`.
- The keystore password supplied for this project opens the keystore successfully.
- SHA-256 upload certificate: `F6:03:8A:5B:40:6C:7C:B7:C7:A4:A0:84:C3:A2:0D:A7:05:A5:95:75:0E:4C:FA:30:15:0C:F3:30:A3:58:0E:86`
- `android/key.properties` is configured for the release signing block.
- Cleartext HTTP traffic is disabled in the Android application manifest.

## About the Google Play Protect "harmful app" warning
A warning shown when installing an APK manually is not, by itself, evidence that the Flutter source is malicious. Android/Play Protect can show stronger warnings for APKs installed outside Google Play, especially when the package/signing history is not yet established. For the closed test, install the build from the Google Play closed-testing link rather than sideloading an exported APK.

If the warning is shown on the Play Store listing/install flow itself, check Play Console App content, App integrity, policy status, and any Play Protect/Pre-launch report message. The source review did not find obvious malware-style code, dynamic code execution, or install-package permissions.
