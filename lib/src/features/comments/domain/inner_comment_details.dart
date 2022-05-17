class InnerCommentDetails {
  const InnerCommentDetails(
      {required this.id,
      required this.owner_id,
      required this.description,
      required this.media_locator,
      required this.created_at,
      required this.comment_id,
      this.updated_at});

  final String id;
  final String owner_id;
  final String description;
  final String media_locator;
  final String created_at;
  final String comment_id;
  final String? updated_at;

  factory InnerCommentDetails.fromJson(Map<String, dynamic> json) {
    return InnerCommentDetails(
        id: json['_id'],
        owner_id: json['owner_id'],
        description: json['description'],
        media_locator: json['media_locator'],
        created_at: json['created_at'],
        comment_id: json['comment_id'],
        updated_at: json['updated_at']);
  }
}
