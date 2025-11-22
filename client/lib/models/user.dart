class User {
  final String userId;
  final String name;
  final String role;

  User({required this.userId, required this.name, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }
}
