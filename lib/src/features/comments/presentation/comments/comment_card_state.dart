import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';

class CommentCardState {
  CommentCardState({this.value = const AsyncValue.data(null)});
  final AsyncValue<void> value;

  bool get isLoading => value.isLoading;

  CommentCardState copyWith({AsyncValue<void>? value}) {
    return CommentCardState(value: value ?? this.value);
  }

  @override
  String toString() => 'CommentCardState(value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentCardState && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

extension CommentCardStateX on CommentCardState {
  String get removeCommentDialogText {
    return "Si eliminas el comentario, todas las respuesta a este también se eliminarán."
        .hardcoded;
  }
}
