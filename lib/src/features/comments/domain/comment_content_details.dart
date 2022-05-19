import 'dart:io';

class CommentContentDetails {
  const CommentContentDetails({
    required this.description,
    required this.media_locator,
  });

  final String description;
  final String media_locator;

  factory CommentContentDetails.fromJson(Map<String, dynamic> json) {
    return CommentContentDetails(
        description: json['description'], media_locator: json['media_locator']);
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
