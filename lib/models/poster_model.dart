class PosterModel {
  final String posterId;
  final String userId;
  final String templateId;
  final String name;
  final Map<String, dynamic> customizations;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PosterStatus status;

  PosterModel({
    required this.posterId,
    required this.userId,
    required this.templateId,
    required this.name,
    required this.customizations,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
    this.status = PosterStatus.active,
  });

  factory PosterModel.fromJson(Map<String, dynamic> json) {
    return PosterModel(
      posterId: json['posterId'] ?? '',
      userId: json['userId'] ?? '',
      templateId: json['templateId'] ?? '',
      name: json['name'] ?? '',
      customizations: Map<String, dynamic>.from(json['customizations'] ?? {}),
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      status: PosterStatus.values.firstWhere(
        (e) => e.toString() == 'PosterStatus.${json['status']}',
        orElse: () => PosterStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posterId': posterId,
      'userId': userId,
      'templateId': templateId,
      'name': name,
      'customizations': customizations,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  PosterModel copyWith({
    String? posterId,
    String? userId,
    String? templateId,
    String? name,
    Map<String, dynamic>? customizations,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    PosterStatus? status,
  }) {
    return PosterModel(
      posterId: posterId ?? this.posterId,
      userId: userId ?? this.userId,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      customizations: customizations ?? this.customizations,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}

enum PosterStatus { active, deleted, archived }