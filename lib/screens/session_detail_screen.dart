import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../services/firestore_service.dart';
import 'task_screen.dart';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;
  final String sessionTitle;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(sessionTitle),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: firestoreService.watchTasksForSession(sessionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Nota: si es la primera vez que consultas tasks con un where + orderBy,
            // Firestore puede pedirte crear un índice compuesto. Revisa la consola
            // de errores de Flutter y haz clic en el enlace que te proporciona.
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error al cargar tareas: ${snapshot.error}'),
              ),
            );
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'Esta sesión aún no tiene tareas.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      _mapTaskIcon(task.type),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(task.type.label), // Ej. "Gramática", "Lectura"
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${task.xpReward} XP',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskScreen(task: task),
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

  /// Mapeo de tipo de tarea a un ícono representativo.
  IconData _mapTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.grammar:
        return Icons.spellcheck;
      case TaskType.reading:
        return Icons.menu_book;
      case TaskType.listening:
        return Icons.headphones;
      case TaskType.speaking:
        return Icons.mic;
      case TaskType.vocabulary:
        return Icons.translate;
      case TaskType.writing:
        return Icons.edit_note;
      case TaskType.unknown:
        return Icons.help_outline;
    }
  }
}
