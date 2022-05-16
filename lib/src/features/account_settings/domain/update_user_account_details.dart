class UpdateUserAccountDetails {
  const UpdateUserAccountDetails({
    required this.email,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
  });

  final String email;
  final String name;
  final String dateOfBirth;
  final String gender;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'date_of_birth': dateOfBirth,
      'gender': gender,
    };
  }
}
