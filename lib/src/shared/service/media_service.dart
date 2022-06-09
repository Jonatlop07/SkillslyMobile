import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:skillsly_ma/src/shared/exception/request_exception.dart';
import 'package:skillsly_ma/src/shared/types/external_file_descriptor.dart';
import 'package:skillsly_ma/src/shared/utils/file_utils.dart';

class MediaService {
  MediaService() : _http = Dio();
  final Dio _http;

  Future<ExternalFileDescriptor> uploadFile(File file) async {
    try {
      String fileName = getFileName(file);
      final multipartFile = MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: '${DateTime.now().toUtc().toString().trim()}$fileName',
        contentType: MediaType.parse(getMimeType(file.path)),
      );
      FormData formData = FormData.fromMap({'media': multipartFile});
      final endpoint = isImage(file.path) ? 'image' : 'video';
      final result = await _http.post(
        'https://api.skillsly.app/api/v1/media/$endpoint',
        data: formData,
      );
      return ExternalFileDescriptor(
        mediaLocator: result.data!['media_locator'],
        mediaType: result.data!['contentType'],
      );
    } catch (e) {
      throw BackendRequestException(e.toString());
    }
  }
}

final mediaServiceProvider = Provider<MediaService>((ref) => MediaService());
