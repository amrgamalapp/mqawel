# قفل لوحة الأدمن على حساب المالك

لوحة `admin.html` أصبحت لا تعتمد على مجرد تسجيل الدخول. الحساب المسموح به هو الحساب الذي يطابق القيمة الموجودة في Realtime Database تحت:

`/adminUid`

## خطوة واحدة مطلوبة

في Firebase Realtime Database أضف:

```json
{
  "adminUid": "8v8PK3iJQdd8ukLWfmsV92jDjbz1"
}
```

واجعل قواعد البيانات هي الملف `database.rules.json` الموجود في المشروع. لا يمكن تغيير `/adminUid` من التطبيق أو لوحة الأدمن.

## توقيع Android

تم تجهيز `android/key.properties` و`android/new_upload_key.jks` باستخدام alias `upload`.

**لا ترفع ملف `key.properties` أو الـ JKS إلى مستودع عام.**
