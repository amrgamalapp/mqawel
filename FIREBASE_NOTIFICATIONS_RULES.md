# Rules اللازمة لمزايا الحساب والإشعارات والطلبات

أضف هذه العقد إلى قواعد Realtime Database الحالية، مع إبقاء قواعدك الأخرى كما هي:

```json
"users": {
  "$uid": {
    ".read": "auth != null && auth.uid == $uid",
    ".write": "auth != null && auth.uid == $uid",
    "fcmTokens": {
      "$tokenKey": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    }
  }
},

"userRequests": {
  "$uid": {
    ".read": "auth != null && auth.uid == $uid",
    ".write": "auth != null && auth.uid == $uid"
  }
},

"notifications": {
  "$uid": {
    ".read": "auth != null && auth.uid == $uid",
    "$notificationId": {
      ".write": "auth != null && auth.uid == $uid"
    }
  }
}
```

> مهم: هذه القواعد تسمح للمستخدم بتعديل إشعاراته بنفسه. إذا أردت أن تكون الإشعارات قابلة للإنشاء من لوحة الإدارة فقط، الأفضل لاحقًا نقل الإنشاء إلى Cloud Functions/Admin SDK وعدم إعطاء المستخدم صلاحية إنشاء إشعارات.
