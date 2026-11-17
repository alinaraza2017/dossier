class Requirement {
  final String id;
  final String scholarshipId;
  final String title;
  final bool isDone;
  final int sortOrder;
  final String? documentId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const Requirement({
    required this.id,
    required this.scholarshipId,
    required this.title,
    this.isDone = false,
    this.sortOrder = 0,
    this.documentId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Requirement copyWith({
    String? id,
    String? scholarshipId,
    String? title,
    bool? isDone,
    int? sortOrder,
    String? documentId,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return Requirement(
      id: id ?? this.id,
      scholarshipId: scholarshipId ?? this.scholarshipId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      sortOrder: sortOrder ?? this.sortOrder,
      documentId: documentId ?? this.documentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scholarshipId': scholarshipId,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'sortOrder': sortOrder,
      'documentId': documentId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  factory Requirement.fromMap(Map<String, dynamic> map) {
    return Requirement(
      id: map['id']?.toString() ?? '',
      scholarshipId: map['scholarshipId']?.toString() ?? '',
      title: map['title'] as String? ?? '',
      isDone: (map['isDone'] as int? ?? 0) == 1,
      sortOrder: map['sortOrder'] as int? ?? 0,
      documentId: map['documentId'] as String?,
      createdAt: map['createdAt'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      updatedAt: map['updatedAt'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      deletedAt: map['deletedAt'] as String?,
    );
  }

  @override
  String toString() {
    return 'Requirement(id: $id, scholarshipId: $scholarshipId, title: $title, isDone: $isDone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Requirement &&
        other.id == id &&
        other.scholarshipId == scholarshipId &&
        other.title == title &&
        other.isDone == isDone &&
        other.documentId == documentId;
  }

  @override
  int get hashCode {
    return Object.hash(id, scholarshipId, title, isDone, documentId);
  }
}
