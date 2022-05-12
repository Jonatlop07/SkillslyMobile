import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/shared/utils/string_validator.dart';

/// Form type for email & password authentication
enum SignUpFormType { signUp }

/// Mixin class to be used for client-side email & password validation
mixin SignUpDetailsValidators {
  static const _minNameLength = 4;
  static const _maxNameLength = 20;
  static const _minUserAge = 14;

  final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();
  final StringValidator passwordSubmitValidator = PasswordSubmitRegexValidator();
  final StringValidator nameSubmitValidator = ConstrainedLengthStringValidator(
    minLength: _minNameLength,
    maxLength: _maxNameLength,
  );
  final StringValidator dateOfBirthSubmitValidator = DateOfBirthSubmitValidator(_minUserAge);
  final StringValidator genderSubmitValidator = NonEmptyStringValidator();
}

/// State class for the email & password form.
class SignUpState with SignUpDetailsValidators {
  SignUpState({
    this.formType = SignUpFormType.signUp,
    this.value = const AsyncValue.data(null),
  });

  final SignUpFormType formType;
  final AsyncValue<void> value;

  bool get isLoading => value.isLoading;

  SignUpState copyWith({
    SignUpFormType? formType,
    AsyncValue<void>? value,
  }) {
    return SignUpState(
      formType: formType ?? this.formType,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => 'SignUpState(formType: $formType, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SignUpState && other.formType == formType && other.value == value;
  }

  @override
  int get hashCode => formType.hashCode ^ value.hashCode;
}

extension SignUpStateX on SignUpState {
  String get passwordLabelText {
    return 'Contraseña (8 o más caracteres)'.hardcoded;
  }

  String get nameLabelText {
    return 'Nombre de usuario (Entre 4 y 20 caracteres)'.hardcoded;
  }

  // Getters
  String get primaryButtonText {
    return 'Crear una cuenta'.hardcoded;
  }

  String get secondaryButtonText {
    return '¿Ya tienes una cuenta? Inicia sesión'.hardcoded;
  }

  SignUpFormType get secondaryActionFormType {
    return SignUpFormType.signUp;
  }

  String get errorAlertTitle {
    return 'Ocurrió un error al registrarse'.hardcoded;
  }

  String get title {
    return 'Crea una cuenta'.hardcoded;
  }

  bool canSubmitEmail(String email) {
    return emailSubmitValidator.isValid(email);
  }

  bool canSubmitPassword(String password) {
    return passwordSubmitValidator.isValid(password);
  }

  bool canSubmitName(String name) {
    return nameSubmitValidator.isValid(name);
  }

  bool canSubmitDateOfBirth(String dateOfBirth) {
    return dateOfBirthSubmitValidator.isValid(dateOfBirth);
  }

  bool canSubmitGender(String gender) {
    return genderSubmitValidator.isValid(gender);
  }

  String? emailErrorText(String email) {
    final bool showErrorText = !canSubmitEmail(email);
    final String errorText = email.isEmpty
        ? 'Debes indicar una dirección de correo electronico'.hardcoded
        : 'Dirección de correo electrónico inválida'.hardcoded;
    return showErrorText ? errorText : null;
  }

  String? passwordErrorText(String password) {
    final bool showErrorText = !canSubmitPassword(password);
    final String errorText = password.isEmpty
        ? 'Debes indicar una contraseña'.hardcoded
        : 'El formato de la contraseña no es válido'.hardcoded;
    return showErrorText ? errorText : null;
  }

  String? nameErrorText(String name) {
    final bool showErrorText = !canSubmitName(name);
    final String errorText = name.isEmpty
        ? 'Debes indicar un nombre de usuario'.hardcoded
        : '''El nombre debe tener entre 
            ${SignUpDetailsValidators._minNameLength} y 
            ${SignUpDetailsValidators._maxNameLength} caracteres
          '''
            .hardcoded;
    return showErrorText ? errorText : null;
  }

  String? dateOfBirthErrorText(String dateOfBirth) {
    final bool showErrorText = !canSubmitDateOfBirth(dateOfBirth);
    final String errorText = '''Debes tener por lo menos 
            ${SignUpDetailsValidators._minUserAge} años de edad
            para usar Skillsly
          '''
        .hardcoded;
    return showErrorText ? errorText : null;
  }

  String? genderErrorText(String gender) {
    final bool showErrorText = !canSubmitGender(gender);
    const String errorText = 'Debes elegir tu género';
    return showErrorText ? errorText : null;
  }
}
