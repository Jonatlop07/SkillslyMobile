import 'dart:io';

class CommentContentDetails {
  const CommentContentDetails(
      {required this.description,
      required this.media_locator,
      required this.media_type});

  final String description;
  final String media_locator;
  final String media_type;

  factory CommentContentDetails.fromJson(Map<String, dynamic> json) {
    return CommentContentDetails(
        description: json['description'],
        media_locator: json['media_locator'],
        media_type: json['media_type']);
  }
}

class CommentContentInputDetails {
  const CommentContentInputDetails({
    required this.description,
    required this.media,
  });

  final String description;
  final File media;
}
