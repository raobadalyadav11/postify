class TemplateModel {
  final String templateId;
  final String category;
  final String type;
  final String name;
  final String imagePath;
  final Map<String, dynamic> metadata;
  final String language;
  final int width;
  final int height;
  final bool isPremium;
  final DateTime createdAt;

  TemplateModel({
    required this.templateId,
    required this.category,
    required this.type,
    required this.name,
    required this.imagePath,
    required this.metadata,
    required this.language,
    required this.width,
    required this.height,
    this.isPremium = false,
    required this.createdAt,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      templateId: json['templateId'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      imagePath: json['imagePath'] ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      language: json['language'] ?? 'en',
      width: json['width'] ?? 1080,
      height: json['height'] ?? 1920,
      isPremium: json['isPremium'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'category': category,
      'type': type,
      'name': name,
      'imagePath': imagePath,
      'metadata': metadata,
      'language': language,
      'width': width,
      'height': height,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}