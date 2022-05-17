import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';

class PostContentInput {
  PostContentInput({this.media, this.descriptionController, this.videoController});

  File? media;
  TextEditingController? descriptionController;
  ChewieController? videoController;
}
