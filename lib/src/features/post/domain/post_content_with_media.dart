import 'dart:io';

class PostContentWithFile {
  PostContentWithFile({required this.media, required this.mediaType, required this.description});

  final File? media;
  final String? mediaType;
  final String? description;
}
