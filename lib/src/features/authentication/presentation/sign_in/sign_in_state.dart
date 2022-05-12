import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'string_validator.dart';

/// Form type for email & password authentication
enum SignInFormType { signIn, twoFactorSignIn }

/// Mixin class to be used for client-side email & password validation
mixin EmailAndPasswordValidators {
  final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();
  final StringValidator passwordSignInSubmitValidator = NonEmptyStringValidator();
}

/// State class for the email & password form.
class SignInState with EmailAndPasswordValidators {
  SignInState({
    this.formType = SignInFormType.signIn,
    this.value = const AsyncValue.data(null),
  });

  final SignInFormType formType;
  final AsyncValue<void> value;

  bool get isLoading => value.isLoading;

  SignInState copyWith({
    SignInFormType? formType,
    AsyncValue<void>? value,
  }) {
    return SignInState(
      formType: formType ?? this.formType,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => 'SignInState(formType: $formType, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SignInState && other.formType == formType && other.value == value;
  }

  @override
  int get hashCode => formType.hashCode ^ value.hashCode;
}

extension SignInStateX on SignInState {
  String get passwordLabelText {
    return 'Contraseña'.hardcoded;
  }

  // Getters
  String get primaryButtonText {
    return 'Iniciar sesion'.hardcoded;
  }

  String get secondaryButtonText {
    return '¿No posees todavía una cuenta? Regístrate'.hardcoded;
  }

  SignInFormType get secondaryActionFormType {
    if (formType == SignInFormType.twoFactorSignIn) {
      return SignInFormType.signIn;
    } else {
      return SignInFormType.twoFactorSignIn;
    }
  }

  String get errorAlertTitle {
    return 'Fallo en el inicio de sesión'.hardcoded;
  }

  String get title {
    return 'Inicia sesion'.hardcoded;
  }

  bool canSubmitEmail(String email) {
    return emailSubmitValidator.isValid(email);
  }

  bool canSubmitPassword(String password) {
    return passwordSignInSubmitValidator.isValid(password);
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
}
