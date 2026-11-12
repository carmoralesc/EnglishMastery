import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/level_model.dart';
import '../models/session_model.dart';
import '../models/task_model.dart';
import '../models/user_profile.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    final now = DateTime.now();
    final profile = UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? email.split('@').first,
      createdAt: now,
      lastLoginAt: now,
      streak: 0,
      totalXp: 0,
    );
    await _usersRef.doc(uid).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final snapshot = await _usersRef.doc(uid).get();
    if (!snapshot.exists) return null;
    return UserProfile.fromMap(uid, snapshot.data()!);
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }

  Future<void> updateLastLogin(String uid) async {
    await _usersRef.doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStreak(String uid, {required int streak}) async {
    await _usersRef.doc(uid).update({
      'streak': streak,
    });
  }

  // ── CONTENIDO EDUCATIVO ────────────────────────────────────────

  Stream<List<LevelModel>> watchLevels() {
    return _db.collection('levels').orderBy('order').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => LevelModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<LevelModel?> getLevel(String levelId) async {
    final snapshot = await _db.collection('levels').doc(levelId).get();
    if (!snapshot.exists) return null;
    return LevelModel.fromMap(snapshot.id, snapshot.data()!);
  }

  Stream<List<SessionModel>> watchSessionsForLevel(String levelId) {
    return _db
        .collection('levels')
        .doc(levelId)
        .collection('sessions')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<TaskModel>> watchTasksForSession(String sessionId) {
    return _db
        .collection('tasks')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}
