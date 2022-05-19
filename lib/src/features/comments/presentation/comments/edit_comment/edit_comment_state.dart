import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';

class EditCommentState {
  EditCommentState({
    this.value = const AsyncValue.data(null),
  });

  final AsyncValue<void> value;

  bool get isLoading => value.isLoading;

  EditCommentState copyWith({AsyncValue<void>? value}) {
    return EditCommentState(value: value ?? this.value);
  }

  @override
  String toString() => 'CreatePostState(value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditCommentState && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

extension EditCommentStateX on EditCommentState {
  double get commentMediaPreviewHeight => Sizes.p48 * 3;
  int get textFieldMaxLength => 1024;
  int get textFieldMinLines => 1;
  int get textFieldMaxLines => 3;

  String get noCommentContentLabelText {
    return 'No has agregado ningún contenido al comentario'.hardcoded;
  }

  bool canUpdateComment(String comment, File media) {
    return comment.isNotEmpty || media.path.isNotEmpty;
  }

  bool canUpdateCommentIfMediaExists(String comment, String media) {
    return comment.isNotEmpty || media.isNotEmpty;
  }

  String? sumbitErrorText(String comment, File media) {
    final bool showErrorText = !canUpdateComment(comment, media);
    final String errorText = 'El comentario no puede estar vacio'.hardcoded;
    return showErrorText ? errorText : null;
  }
}
