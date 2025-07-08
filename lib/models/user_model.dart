class UserModel {
  final int id;
  final String name;
  final String email;
  final String? googleId;
  final String? avatar;
  final String role;
  final int isExisted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.googleId,
    this.avatar,
    required this.role,
    this.isExisted = 0, // Default to 0 (new user)
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      googleId: json['google_id'],
      avatar: json['avatar'],
      role: json['role'],
      isExisted: json['is_existed'] ?? 0, // Handle null case
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'google_id': googleId,
      'avatar': avatar,
      'role': role,
      'is_existed': isExisted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Add a method to create a copy with some updated fields if needed
  UserModel copyWith({
    String? name,
    String? email,
    String? avatar,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      googleId: googleId,
      avatar: avatar ?? this.avatar,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
