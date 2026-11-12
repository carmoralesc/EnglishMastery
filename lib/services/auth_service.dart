import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_service.dart';

class AuthService {
  final FirestoreService _firestoreService;

  AuthService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    try {
      await _ensureProfileExists(cred.user!);
    } catch (_) {
      // Si Firestore falla, no bloqueamos el login. El perfil
      // se creara o actualizara en el siguiente intento.
    }
    return cred;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestoreService.createUserProfile(
      uid: cred.user!.uid,
      email: cred.user!.email ?? email,
    );
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _ensureProfileExists(User user) async {
    final profile = await _firestoreService.getUserProfile(user.uid);
    if (profile == null) {
      await _firestoreService.createUserProfile(
        uid: user.uid,
        email: user.email ?? '',
      );
    } else {
      await _firestoreService.updateLastLogin(user.uid);
    }
  }
}
