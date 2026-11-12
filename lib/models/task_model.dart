// Modelo puro Dart. id = doc ID de la tarea; sessionId = FK al doc
// de la sesión (colección raíz tasks/{taskId}.sessionId).
//
// TaskType.unknown existe para cumplir "fromMap nunca throw".
// Es preferible un valor honesto (desconocido) a caer a un tipo
// real (mentira silenciosa).
//
// contentJson es libre (Map<String, dynamic>). Los patrones que ya
// conocemos (listening clip, speaking cronometrado) tienen getters
// tipados abajo como documentación viva del schema. Cuando surja
// un nuevo tipo de tarea, contentJson ya lo admite sin tocar el
// modelo; solo añadimos getters si el patrón se repite.

enum TaskType {
  reading,
  writing,
  listening,
  speaking,
  grammar,
  vocabulary,
  unknown;

  static TaskType fromString(String? value) {
    if (value == null) return TaskType.unknown;
    return TaskType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TaskType.unknown,
    );
  }

  String get label => switch (this) {
        TaskType.reading => 'Lectura',
        TaskType.writing => 'Escritura',
        TaskType.listening => 'Escucha',
        TaskType.speaking => 'Habla',
        TaskType.grammar => 'Gramática',
        TaskType.vocabulary => 'Vocabulario',
        TaskType.unknown => 'Desconocido',
      };
}

class TaskModel {
  final String id;
  final String sessionId;
  final int order;
  final TaskType type;
  final String title;
  final Map<String, dynamic> contentJson;
  final int xpReward;

  const TaskModel({
    required this.id,
    required this.sessionId,
    required this.order,
    required this.type,
    required this.title,
    required this.contentJson,
    required this.xpReward,
  });

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      sessionId: (map['sessionId'] as String?) ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      type: TaskType.fromString(map['type'] as String?),
      title: (map['title'] as String?) ?? '',
      contentJson: _parseContentJson(map['contentJson']),
      xpReward: (map['xpReward'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'order': order,
      'type': type.name,
      'title': title,
      'contentJson': contentJson,
      'xpReward': xpReward,
    };
  }

  // ── Getters tipados para patrones conocidos de contentJson ──────
  // Devuelven null si el campo falta; el consumidor decide el fallback.

  // Listening con clip corto (Voxy-style).
  String? get videoId => contentJson['videoId'] as String?;
  int? get startSecond => (contentJson['startSecond'] as num?)?.toInt();
  int? get endSecond => (contentJson['endSecond'] as num?)?.toInt();

  // Speaking cronometrado / shadowing.
  String? get promptText => contentJson['promptText'] as String?;
  int? get durationSeconds => (contentJson['durationSeconds'] as num?)?.toInt();

  /// Defensivo: acepta `Map<String, dynamic>`, Map genérico, o
  /// cualquier otra cosa (retorna {} en lugar de lanzar).
  static Map<String, dynamic> _parseContentJson(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }
}
