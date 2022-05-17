class CommentDetails {
  const CommentDetails(
      {required this.id,
      required this.owner_id,
      required this.description,
      required this.media_locator,
      required this.created_at,
      this.inner_comment_count,
      this.updated_at});

  final String id;
  final String owner_id;
  final String description;
  final String media_locator;
  final String created_at;
  final int? inner_comment_count;
  final String? updated_at;

  factory CommentDetails.fromJson(Map<String, dynamic> json) {
    return CommentDetails(
        id: json['_id'],
        owner_id: json['owner_id'],
        description: json['description'],
        media_locator: json['media_locator'],
        created_at: json['created_at'],
        inner_comment_count: json['inner_comment_count'],
        updated_at: json['updated_at']);
  }
}
