class Member {
  Member(
      {required this.user_id, this.is_admin, this.is_active, this.joined_at});

  final String user_id;
  final String? is_admin;
  final String? is_active;
  final String? joined_at;

  factory Member.fromJson(dynamic json) {
    return Member(user_id: json["user_id"]);
  }
}
