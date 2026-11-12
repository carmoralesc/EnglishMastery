// Modelo puro Dart. id = doc ID de la sesión.
// levelId se persiste aunque sea derivable de la ruta
// levels/{levelId}/sessions/{sessionId}: docs auto-descriptivos
// y a prueba de una futura promoción a colección raíz.
// taskIds se mantiene para conocer el total y el orden explícito
// sin query extra; el seed lo sincroniza con tasks/{id}.sessionId.

/// Tier de dificultad estilo Voxy/CEFR. Nullable: las sesiones de la
/// ruta gramatical pueden no tener tier asignado.
enum DifficultyTier {
  entry('entry'),
  basic('basic'),
  intermediate('intermediate'),
  upperIntermediate('upper_intermediate'),
  advanced('advanced'),
  unknown('unknown');

  /// Valor estable en Firestore (snake_case).
  final String firestoreValue;

  const DifficultyTier(this.firestoreValue);

  static DifficultyTier? fromString(String? value) {
    if (value == null) return null;
    for (final tier in DifficultyTier.values) {
      if (tier.firestoreValue == value) return tier;
    }
    // Valor desconocido: 'unknown' es honesto, no fingimos un tier real.
    return DifficultyTier.unknown;
  }

  String get label => switch (this) {
        DifficultyTier.entry => 'Inicial',
        DifficultyTier.basic => 'Básico',
        DifficultyTier.intermediate => 'Intermedio',
        DifficultyTier.upperIntermediate => 'Intermedio alto',
        DifficultyTier.advanced => 'Avanzado',
        DifficultyTier.unknown => 'Desconocido',
      };
}

class SessionModel {
  final String id;
  final String levelId;
  final int order;
  final String title;
  final String description;

  /// Null = sesión sin tier (ej. ruta gramatical pura).
  /// Unknown = el dato venía malformado desde Firestore.
  final DifficultyTier? difficultyTier;

  /// Referencias a tasks/{taskId}. El orden del listado es el
  /// orden de presentación dentro de la sesión.
  final List<String> taskIds;

  const SessionModel({
    required this.id,
    required this.levelId,
    required this.order,
    required this.title,
    required this.description,
    required this.difficultyTier,
    required this.taskIds,
  });

  factory SessionModel.fromMap(String id, Map<String, dynamic> map) {
    return SessionModel(
      id: id,
      levelId: (map['levelId'] as String?) ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      difficultyTier:
          DifficultyTier.fromString(map['difficultyTier'] as String?),
      taskIds: _parseStringList(map['taskIds']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'order': order,
      'title': title,
      'description': description,
      'difficultyTier': difficultyTier?.firestoreValue,
      'taskIds': taskIds,
    };
  }

  /// Defensivo: si el valor no es List o contiene no-String,
  /// descarta los elementos inválidos en lugar de lanzar.
  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }
}
