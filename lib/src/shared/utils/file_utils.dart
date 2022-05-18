import 'dart:io';

import 'package:mime/mime.dart';

String getFileName(File file) {
  return file.path.split(Platform.pathSeparator).last;
}

String getMediaType(String fileName) {
  return '.' + fileName.split('.').last;
}

String getMimeType(String filePath) {
  return lookupMimeType(filePath)!;
}

bool isImage(String filePath) {
  return lookupMimeType(filePath)!.startsWith('image/');
}

bool isVideo(String filePath) {
  return lookupMimeType(filePath)!.startsWith('video/');
}
