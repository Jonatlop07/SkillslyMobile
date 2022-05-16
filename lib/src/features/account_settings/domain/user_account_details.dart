class UserAccountDetails {
  const UserAccountDetails({
    required this.email,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.createdAt,
    this.updatedAt,
  });

  final String email;
  final String name;
  final String dateOfBirth;
  final String gender;
  final String createdAt;
  final String? updatedAt;

  factory UserAccountDetails.fromJson(Map<String, dynamic> json) {
    return UserAccountDetails(
      email: json['email'],
      name: json['name'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
