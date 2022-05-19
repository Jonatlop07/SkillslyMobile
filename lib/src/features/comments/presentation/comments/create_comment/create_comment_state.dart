import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';

class CreateCommentState {
  CreateCommentState({this.value = const AsyncValue.data(null)});
  final AsyncValue<void> value;

  bool get isLoading => value.isLoading;

  CreateCommentState copyWith({AsyncValue<void>? value}) {
    return CreateCommentState(value: value ?? this.value);
  }

  @override
  String toString() => 'CreateCommentState(value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateCommentState && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

extension CreateCommentStateX on CreateCommentState {
  String get noCommentContentLabelText {
    return 'No has agregado ningún contenido al comentario'.hardcoded;
  }

  bool canSubmitComment(String comment, File media) {
    return comment.isNotEmpty || media.path.isNotEmpty;
  }

  String? sumbitErrorText(String comment, File media) {
    final bool showErrorText = !canSubmitComment(comment, media);
    final String errorText = 'El comentario no puede estar vacio'.hardcoded;
    return showErrorText ? errorText : null;
  }
}
