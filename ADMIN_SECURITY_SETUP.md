# حماية لوحة الإدارة

لوحة الإدارة مقفولة على **مالك واحد فقط** عبر Firebase Authentication UID.

## إعداد المالك مرة واحدة

في Firebase Realtime Database أنشئ المفتاح:

```json
"adminUid": "8v8PK3iJQdd8ukLWfmsV92jDjbz1"
```

القواعد تمنع أي مستخدم أو لوحة الإدارة من تعديل `/adminUid`.

بعد وضع UID الصحيح، أي حساب Firebase آخر حتى لو كانت بيانات دخوله صحيحة سيتم رفضه وتسجيل خروجه.

## App Check

التطبيق يستخدم Firebase App Check مع Play Integrity في نسخة Android Release، وDebug provider أثناء التطوير.

## ملاحظة

لا تعتمد على إخفاء رابط `admin.html` للحماية؛ الحماية الحقيقية موجودة في Authentication + Realtime Database Rules.
