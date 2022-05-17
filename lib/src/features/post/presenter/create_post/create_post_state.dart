import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/shared/utils/string_validator.dart';

mixin CreatePostValidators {
  final StringValidator descriptionSubmitValidator = NonEmptyStringValidator();
}

class CreatePostState with CreatePostValidators {
  CreatePostState({
    this.value = const AsyncValue.data(null),
  });

  final AsyncValue<void> value;

  bool get isLoading => value.isLoading;

  CreatePostState copyWith({AsyncValue<void>? value}) {
    return CreatePostState(value: value ?? this.value);
  }

  @override
  String toString() => 'CreatePostState(value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreatePostState && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

extension CreatePostStateX on CreatePostState {
  double get postContentContainerHeight => Sizes.p64 * 5;
  int get textFieldMaxLength => 1024;
  int get textFieldMinLines => 1;
  int get textFieldMaxLines => 3;

  String get descriptionLabelText {
    return 'Descripción de tu publicación'.hardcoded;
  }

  String get noContentLabelText {
    return 'Todavía no has añadido contenido adicional a tu publicación'.hardcoded;
  }

  String get contentDescriptionLabelText {
    return 'Descripción'.hardcoded;
  }

  String get addPostElementLabelText {
    return 'Añadir un elemento al contenido'.hardcoded;
  }

  String get selectMediaLabelText {
    return 'Seleccionar archivo'.hardcoded;
  }

  String get deletePostElementLabelText {
    return 'Borrar'.hardcoded;
  }

  String get noFileLoadedLabelText {
    return 'No has subido un archivo aún'.hardcoded;
  }

  String get submitButtonText {
    return 'Crear'.hardcoded;
  }

  bool canSubmitDescription(String description) {
    return descriptionSubmitValidator.isValid(description);
  }

  String? descriptionErrorText(String email) {
    final bool showErrorText = !canSubmitDescription(email);
    final String errorText = 'Debes indicar una descripcion de tu publicación'.hardcoded;
    return showErrorText ? errorText : null;
  }
}
