class ExternalFileDescriptor {
  ExternalFileDescriptor({required this.mediaLocator, required this.mediaType});

  final String mediaLocator;
  final String mediaType;

  factory ExternalFileDescriptor.fromJson(Map<String, dynamic> json) {
    return ExternalFileDescriptor(mediaLocator: json['media_locator'], mediaType: 'media_type');
  }
}
