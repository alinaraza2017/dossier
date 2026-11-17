class VaultDocument {
  final String id;
  final String title;
  final String fileType; // 'pdf', 'jpg', 'png'
  final int sizeBytes;
  final String? expiryDate; // ISO-8601 YYYY-MM-DD
  final String? storagePath;
  final String? localPath;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const VaultDocument({
    required this.id,
    required this.title,
    required this.fileType,
    required this.sizeBytes,
    this.expiryDate,
    this.storagePath,
    this.localPath,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String get sizeFormatted {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fileType': fileType,
      'sizeBytes': sizeBytes,
      'expiryDate': expiryDate,
      'storagePath': storagePath,
      'localPath': localPath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  factory VaultDocument.fromMap(Map<String, dynamic> map) {
    return VaultDocument(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? '',
      fileType: map['fileType'] as String? ?? 'pdf',
      sizeBytes: map['sizeBytes'] as int? ?? 0,
      expiryDate: map['expiryDate'] as String?,
      storagePath: map['storagePath'] as String?,
      localPath: map['localPath'] as String?,
      createdAt: map['createdAt'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      updatedAt: map['updatedAt'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      deletedAt: map['deletedAt'] as String?,
    );
  }
}
