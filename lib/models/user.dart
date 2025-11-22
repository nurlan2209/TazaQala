class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.district,
    this.isActive,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? district;
  final bool? isActive;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['_id'];
    return UserModel(
      id: rawId?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      district: json['district'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'district': district,
        'isActive': isActive,
      };
}
