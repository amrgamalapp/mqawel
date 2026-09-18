# Firebase consistency fix

- Firebase project: `el-iraqia-services`
- Realtime Database: `https://el-iraqia-services-default-rtdb.firebaseio.com`
- Android package: `com.iraqia.amr`
- Android Firebase App ID used by both FlutterFire and google-services: `1:478034761629:android:f029998aa2731e0673c174`
- Release App Check: Play Integrity
- Debug App Check: Debug provider
- Database nodes consumed by the app: `providers`, `market_products`, `deaths`, `heroes`, `urgent_requests`, `reviews`, `news`, `globalNotification`, `ticker`, `settings/*`, `users/*`.

The app now initializes Firebase explicitly with `DefaultFirebaseOptions.currentPlatform`, so runtime Firebase configuration no longer depends on a different native app registration.
