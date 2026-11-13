import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/level_model.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final authService = context.read<AuthService>();
    final String? uid = authService.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ruta de aprendizaje')),
      body: StreamBuilder<UserProfile?>(
        stream: firestoreService.watchUserProfile(uid),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final int userXp = userSnap.data?.totalXp ?? 0;

          return StreamBuilder<List<LevelModel>>(
            stream: firestoreService.watchLevels(),
            builder: (context, levelsSnap) {
              if (levelsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (levelsSnap.hasError) {
                return Center(child: Text('Error: ${levelsSnap.error}'));
              }
              final levels = levelsSnap.data ?? <LevelModel>[];
              if (levels.isEmpty) {
                return const Center(
                  child: Text('Aún no hay niveles disponibles.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return _LevelTile(
                    level: level,
                    userXp: userXp,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final LevelModel level;
  final int userXp;

  const _LevelTile({required this.level, required this.userXp});

  bool get _isAdminLocked => level.isLocked;
  bool get _isXpLocked => !level.isLocked && userXp < level.requiredXp;
  bool get _isUnlocked => !_isAdminLocked && !_isXpLocked;

  void _handleTap(BuildContext context) {
    if (_isUnlocked) {
      context.push('/level/${level.id}', extra: level.title);
      return;
    }
    final String message;
    if (_isAdminLocked) {
      message = 'Contenido no disponible aún.';
    } else {
      final int missing = level.requiredXp - userXp;
      message = 'Necesitas $missing XP más para desbloquear este nivel.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color leadingBg = _isUnlocked
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final Color leadingFg = _isUnlocked
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: leadingBg,
          child: Icon(_mapIcon(level.iconName), size: 32, color: leadingFg),
        ),
        title: Text(
          level.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isUnlocked ? null : theme.disabledColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4),
            Text(level.description),
            const SizedBox(height: 8),
            Text(
              '${level.totalTasks} tareas',
              style: TextStyle(
                color: _isUnlocked
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isXpLocked) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                'Requiere ${level.requiredXp} XP (tienes $userXp)',
                style: TextStyle(
                  color: theme.disabledColor,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: _isUnlocked
            ? const Icon(Icons.chevron_right)
            : const Icon(Icons.lock, color: Colors.grey),
        onTap: () => _handleTap(context),
      ),
    );
  }

  IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'school':
        return Icons.school;
      case 'star':
        return Icons.star;
      default:
        return Icons.book;
    }
  }
}
