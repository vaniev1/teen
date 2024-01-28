class User {
  final String id;
  final String firstNameLastName;
  final String username;
  final String password;
  final String phoneNumber;
  final String prefix;
  final int stata;
  final bool premium;
  final bool blocked;
  final String selectedImagePath;

  User({
    required this.id,
    required this.firstNameLastName,
    required this.username,
    required this.password,
    required this.phoneNumber,
    required this.prefix,
    required this.stata,
    required this.premium,
    required this.blocked,
    required this.selectedImagePath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      firstNameLastName: json['firstNameLastName'] ?? "",
      username: json['username'] ?? "",
      password: json['password'] ?? "",
      phoneNumber: json['phoneNumber'] ?? "",
      prefix: json['prefix'] ?? "",
      stata: json['stata'] ?? 0,
      premium: json['premium'] ?? false,
      blocked: json['blocked'] ?? false,
      selectedImagePath: json['selectedImagePath'] ?? "",
    );
  }
}