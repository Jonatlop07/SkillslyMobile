class SearchUserDetails {
  const SearchUserDetails(
      {required this.email,
      required this.name,
      required this.dateOfBirth,
      required this.id});

  final String email;
  final String name;
  final String dateOfBirth;
  final String id;

  factory SearchUserDetails.fromJson(Map<String, dynamic> json) {
    return SearchUserDetails(
      email: json['email'],
      name: json['name'],
      dateOfBirth: json['date_of_birth'],
      id: json['id'],
    );
  }
}
