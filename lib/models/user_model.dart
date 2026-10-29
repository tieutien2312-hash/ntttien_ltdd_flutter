class UserModel {
  final String id;
  final String email;
  final String fullName;
  final List<String> roles;
  final String? phoneNumber;
  final bool isEmailConfirmed;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
    this.phoneNumber,
    this.isEmailConfirmed = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedRoles = [];
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        parsedRoles = List<String>.from(json['roles'].map((e) => e.toString()));
      } else if (json['roles'] is String) {
        parsedRoles = (json['roles'] as String).split(',');
      }
    }

    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      roles: parsedRoles,
      phoneNumber: json['phoneNumber']?.toString(),
      isEmailConfirmed: json['isEmailConfirmed'] ?? json['emailConfirmed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'roles': roles,
      'phoneNumber': phoneNumber,
      'isEmailConfirmed': isEmailConfirmed,
    };
  }
}
