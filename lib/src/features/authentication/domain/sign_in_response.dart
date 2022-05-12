class SignInResponse {
  SignInResponse({required this.id, required this.email, required this.accessToken});

  final String id;
  final String email;
  final String accessToken;

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      id: json['id'],
      email: json['email'],
      accessToken: json['access_token'],
    );
  }
}
