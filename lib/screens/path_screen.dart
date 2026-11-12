import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/level_model.dart';
import '../services/firestore_service.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta de aprendizaje'),
      ),
      body: StreamBuilder<List<LevelModel>>(
        stream: firestoreService.watchLevels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar niveles: ${snapshot.error}'),
            );
          }

          final levels = snapshot.data ?? [];

          if (levels.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Aún no hay niveles disponibles.\nContacta al administrador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      _mapIcon(level.iconName),
                      size: 32,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    level.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(level.description),
                      const SizedBox(height: 8),
                      Text(
                        '${level.totalTasks} tareas',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  trailing: level.isLocked
                      ? const Icon(Icons.lock, color: Colors.grey)
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO(Fase 5): Navegar a LevelDetailScreen.
                    // Por ahora mostramos un SnackBar para confirmar que el tap funciona.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Seleccionaste: ${level.title}. (Detalle en Fase 5)',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Mapeo local de String a IconData.
  /// Mantiene los modelos puros (sin Flutter) y permite añadir
  /// íconos en el futuro sin tocar el modelo.
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
