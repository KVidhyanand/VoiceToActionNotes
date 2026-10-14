class VoiceNote {
  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime createdAt;

  VoiceNote({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
  });

  String get createdAtFormatted =>
      '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VoiceNote.fromJson(Map<String, dynamic> json) {
    return VoiceNote(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
