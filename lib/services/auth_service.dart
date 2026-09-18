import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

Map<dynamic, dynamic> _safeMap(dynamic value) {
  if (value is Map<dynamic, dynamic>) return value;
  if (value is Map) return Map<dynamic, dynamic>.from(value);
  return <dynamic, dynamic>{};
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authState => _auth.authStateChanges();

  // ─── تسجيل بالإيميل وكلمة السر ───
  static Future<UserModel?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String city,
    String? phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) return null;

    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      phone: phone,
      city: city,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.child('users/${user.uid}').set(userModel.toMap());
    return userModel;
  }

  // ─── دخول بالإيميل وكلمة السر ───
  static Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) return null;

    await NotificationService.registerCurrentUserToken();

    final snapshot = await _db.child('users/${user.uid}').get();
    if (snapshot.exists) {
      return UserModel.fromMap(user.uid, _safeMap(snapshot.value));
    }
    return null;
  }

  // ─── دخول برقم التليفون (OTP) ───
  static String normalizeEgyptianPhone(String input) {
    var value = input.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (value.startsWith('00')) value = '+${value.substring(2)}';
    if (value.startsWith('+20')) return value;
    if (value.startsWith('20') && value.length >= 12) return '+$value';
    if (value.startsWith('01') && value.length == 11) return '+20${value.substring(1)}';
    if (value.startsWith('1') && value.length == 10) return '+20$value';
    return value;
  }

  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onVerificationCompleted,
  }) async {
    final normalizedPhone = normalizeEgyptianPhone(phoneNumber);
    if (!RegExp(r'^\+20(10|11|12|15)\d{8}$').hasMatch(normalizedPhone)) {
      onError('رقم الهاتف المصري غير صحيح. اكتب الرقم مثل 01012345678');
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: normalizedPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (onVerificationCompleted != null) {
          await onVerificationCompleted(credential);
        } else {
          await _auth.signInWithCredential(credential);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'حدث خطأ');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  // ─── تسجيل الدخول بعد التحقق التلقائي من الهاتف ───
  static Future<UserModel?> verifyCredential({
    required PhoneAuthCredential credential,
    required String name,
    required String city,
  }) async {
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) return null;

    final snapshot = await _db.child('users/${user.uid}').get();
    if (snapshot.exists) {
      return UserModel.fromMap(user.uid, _safeMap(snapshot.value));
    }

    final userModel = UserModel(
      uid: user.uid,
      name: name.trim().isEmpty ? 'مستخدم' : name.trim(),
      email: user.email ?? '',
      phone: user.phoneNumber,
      city: city.trim().isEmpty ? 'القاهرة' : city.trim(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.child('users/${user.uid}').set(userModel.toMap());
    return userModel;
  }

  // ─── تأكيد كود OTP ───
  static Future<UserModel?> verifyOTP({
    required String verificationId,
    required String smsCode,
    required String name,
    required String city,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) return null;

    // Check if user exists
    final snapshot = await _db.child('users/${user.uid}').get();
    if (snapshot.exists) {
      return UserModel.fromMap(user.uid, _safeMap(snapshot.value));
    }

    // New user
    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: '',
      phone: user.phoneNumber,
      city: city,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.child('users/${user.uid}').set(userModel.toMap());
    return userModel;
  }

  // ─── جلب بيانات المستخدم الحالي ───
  static Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snapshot = await _db.child('users/${user.uid}').get();
    if (snapshot.exists) {
      return UserModel.fromMap(user.uid, _safeMap(snapshot.value));
    }
    return null;
  }


  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }


  static Future<void> updateProfile({
    required String name,
    String? phone,
    String? city,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('لا يوجد مستخدم مسجل الدخول');
    await _db.child('users/${user.uid}').update({
      'name': name.trim(),
      if (phone != null) 'phone': phone.trim(),
      if (city != null) 'city': city.trim(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ─── تسجيل الخروج ───
  static Future<void> signOut() async {
    await NotificationService.removeCurrentUserTokens();
    await _auth.signOut();
  }

  // ─── دخول كضيف (Guest) ───
  static Future<UserModel> signInAsGuest() async {
    return UserModel(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'ضيف',
      email: '',
      city: 'القاهرة',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
