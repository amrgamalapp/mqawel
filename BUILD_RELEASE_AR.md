# بناء نسخة Google Play

من مجلد المشروع:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

الناتج المتوقع:
`build/app/outputs/bundle/release/app-release.aab`

إعداد التوقيع موجود بالفعل في:
- `android/key.properties`
- `android/new_upload_key.jks`

**مهم:** لا ترفع `android/key.properties` أو `android/new_upload_key.jks` إلى GitHub أو أي مكان عام.
