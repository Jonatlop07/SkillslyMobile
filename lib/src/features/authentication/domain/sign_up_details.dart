class SignUpDetails {
  const SignUpDetails({
    required this.email,
    required this.password,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
  });

  final String email;
  final String password;
  final String name;
  final String dateOfBirth;
  final String gender;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'date_of_birth': dateOfBirth,
      'gender': gender
    };
  }
}
