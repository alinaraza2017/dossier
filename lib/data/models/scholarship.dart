import '../../core/utils/date_utils.dart';

class Scholarship {
  final String id;
  final String name;
  final String country;
  final String deadline; // ISO-8601 string (YYYY-MM-DD)
  final String? link;
  final String status;
  final String? notes;
  final bool remindersOn;
  final String? reminderOffsets; // comma-separated e.g. "14,7,2,1" or null for default
  final String? reminderTime; // e.g. "09:00" or null for default
  final bool isLocked;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const Scholarship({
    required this.id,
    required this.name,
    this.country = '',
    required this.deadline,
    this.link,
    this.status = 'Not Started',
    this.notes,
    this.remindersOn = true,
    this.reminderOffsets,
    this.reminderTime,
    this.isLocked = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  DateTime get deadlineDateTime => AppDateUtils.parseIso(deadline);

  DateTime get createdAtDateTime => DateTime.tryParse(createdAt) ?? DateTime.now();

  bool get isSubmitted => status.trim().toLowerCase() == 'submitted';

  bool get isActive => !isSubmitted && deletedAt == null;

  List<int> get effectiveOffsets {
    if (reminderOffsets != null && reminderOffsets!.trim().isNotEmpty) {
      return reminderOffsets!
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();
    }
    return [7, 2]; // default Free offsets
  }

  Scholarship copyWith({
    String? id,
    String? name,
    String? country,
    String? deadline,
    String? link,
    String? status,
    String? notes,
    bool? remindersOn,
    String? reminderOffsets,
    String? reminderTime,
    bool? isLocked,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return Scholarship(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      deadline: deadline ?? this.deadline,
      link: link ?? this.link,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      remindersOn: remindersOn ?? this.remindersOn,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      reminderTime: reminderTime ?? this.reminderTime,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'deadline': deadline,
      'link': link,
      'status': status,
      'notes': notes,
      'remindersOn': remindersOn ? 1 : 0,
      'reminderOffsets': reminderOffsets,
      'reminderTime': reminderTime,
      'isLocked': isLocked ? 1 : 0,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  factory Scholarship.fromMap(Map<String, dynamic> map) {
    return Scholarship(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      country: map['country'] as String? ?? '',
      deadline: map['deadline'] as String? ?? '',
      link: map['link'] as String?,
      status: map['status'] as String? ?? 'Not Started',
      notes: map['notes'] as String?,
      remindersOn: (map['remindersOn'] as int? ?? 1) == 1,
      reminderOffsets: map['reminderOffsets'] as String?,
      reminderTime: map['reminderTime'] as String?,
      isLocked: (map['isLocked'] as int? ?? 0) == 1,
      createdAt: map['createdAt'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      updatedAt: map['updatedAt'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      deletedAt: map['deletedAt'] as String?,
    );
  }
}
