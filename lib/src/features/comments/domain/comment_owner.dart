class CommentOwner {
  CommentOwner({required this.email, required this.name});

  final String email;
  final String name;

  factory CommentOwner.fromJson(Map<String, dynamic> json) {
    return CommentOwner(email: json['email'], name: json['name']);
  }
}
