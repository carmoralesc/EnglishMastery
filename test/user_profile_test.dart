import 'package:flutter_test/flutter_test.dart';

import 'package:english_master_academy/models/user_profile.dart';

void main() {
  test('UserProfile round-trip map -> model -> map conserva los datos', () {
    final createdAt = DateTime(2026, 1, 15, 10, 30);
    final lastLoginAt = DateTime(2026, 2, 20, 18, 45);

    final original = UserProfile(
      uid: 'abc123',
      email: 'test@example.com',
      displayName: 'test',
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      streak: 5,
      totalXp: 120,
      currentLevelId: 'level_1',
    );

    final map = original.toMap();
    final restored = UserProfile.fromMap(original.uid, map);

    expect(restored.uid, original.uid);
    expect(restored.email, original.email);
    expect(restored.displayName, original.displayName);
    expect(restored.streak, original.streak);
    expect(restored.totalXp, original.totalXp);
    expect(restored.currentLevelId, original.currentLevelId);
    expect(
      restored.createdAt.millisecondsSinceEpoch,
      original.createdAt.millisecondsSinceEpoch,
    );
    expect(
      restored.lastLoginAt.millisecondsSinceEpoch,
      original.lastLoginAt.millisecondsSinceEpoch,
    );
  });
}
