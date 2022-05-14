import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/shared/utils/string_validator.dart';

/// Form type for email & password authentication
enum AccountCredentialsFormType { updateCredentials, deleteAccount }

/// Mixin class to be used for client-side email & password validation
mixin EmailAndPasswordValidators {
  final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();
  final StringValidator passwordSubmitValidator = PasswordSubmitRegexValidator();
}

/// State class for the email & password form.
class AccountCredentialsState with EmailAndPasswordValidators {
  AccountCredentialsState({
    this.formType = AccountCredentialsFormType.updateCredentials,
    this.value = const AsyncValue.data(null),
  });

  final AccountCredentialsFormType formType;
  final AsyncValue<void> value;

  bool get isLoading => value.isLoading;

  AccountCredentialsState copyWith({
    AccountCredentialsFormType? formType,
    AsyncValue<void>? value,
  }) {
    return AccountCredentialsState(
      formType: formType ?? this.formType,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => 'AccountCredentialsState(formType: $formType, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccountCredentialsState && other.formType == formType && other.value == value;
  }

  @override
  int get hashCode => formType.hashCode ^ value.hashCode;
}

extension AccountCredentialsStateX on AccountCredentialsState {
  String get passwordLabelText {
    return 'Contraseña'.hardcoded;
  }

  // Getters
  String get primaryButtonText {
    if (formType == AccountCredentialsFormType.updateCredentials) {
      return 'Actualizar credenciales'.hardcoded;
    }
    return 'Eliminar cuenta'.hardcoded;
  }

  String get secondaryButtonText {
    if (formType == AccountCredentialsFormType.updateCredentials) {
      return '¿Deseas eliminar tu cuenta?'.hardcoded;
    }
    return '¿Deseas actualizar tus credenciales?'.hardcoded;
  }

  AccountCredentialsFormType get alternativeActionFormType {
    if (formType == AccountCredentialsFormType.updateCredentials) {
      return AccountCredentialsFormType.deleteAccount;
    }
    return AccountCredentialsFormType.updateCredentials;
  }

  String get errorAlertTitle {
    if (formType == AccountCredentialsFormType.updateCredentials) {
      return 'Fallo al actualizar tus credenciales'.hardcoded;
    }
    return 'Fallo al eliminar tu cuenta'.hardcoded;
  }

  String get title {
    if (formType == AccountCredentialsFormType.updateCredentials) {
      return 'Actualización de credenciales'.hardcoded;
    }
    return 'Eliminación de la cuenta'.hardcoded;
  }

  bool canSubmitEmail(String email) {
    return emailSubmitValidator.isValid(email);
  }

  bool canSubmitPassword(String password) {
    return passwordSubmitValidator.isValid(password);
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
