class PostContentElement {
  PostContentElement({this.description, this.mediaLocator, this.mediaType});

  final String? description;
  final String? mediaLocator;
  final String? mediaType;

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'media_locator': mediaLocator,
      'media_type': mediaType,
    };
  }

  factory PostContentElement.fromJson(Map<String, dynamic> json) {
    return PostContentElement(
      description: json['description'],
      mediaLocator: json['media_locator'],
      mediaType: json['media_type'],
    );
  }
}
