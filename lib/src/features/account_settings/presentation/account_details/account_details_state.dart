import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/shared/utils/string_validator.dart';

enum AccountDetailsFormType { accountDetails }

mixin AccountDetailsValidators {
  static const _minNameLength = 4;
  static const _maxNameLength = 20;
  static const _minUserAge = 14;

  final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();
  final StringValidator nameSubmitValidator = ConstrainedLengthStringValidator(
    minLength: _minNameLength,
    maxLength: _maxNameLength,
  );
  final StringValidator dateOfBirthSubmitValidator = DateOfBirthSubmitValidator(_minUserAge);
  final StringValidator genderSubmitValidator = NonEmptyStringValidator();
}

class AccountDetailsState with AccountDetailsValidators {
  AccountDetailsState({
    this.formType = AccountDetailsFormType.accountDetails,
    this.value = const AsyncValue.data(null),
  });

  final AccountDetailsFormType formType;
  final AsyncValue<void> value;

  bool get isLoading => value.isLoading;

  AccountDetailsState copyWith({
    AccountDetailsFormType? formType,
    AsyncValue<void>? value,
  }) {
    return AccountDetailsState(
      formType: formType ?? this.formType,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => 'AccountDetailsState(formType: $formType, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccountDetailsState && other.formType == formType && other.value == value;
  }

  @override
  int get hashCode => formType.hashCode ^ value.hashCode;
}

extension AccountDetailsStateX on AccountDetailsState {
  String get emailLabelText {
    return 'Correo electrónico'.hardcoded;
  }

  String get nameLabelText {
    return 'Nombre de usuario (Entre 4 y 20 caracteres)'.hardcoded;
  }

  String get applyAccountDetailsUpdatesButtonText {
    return 'Aplicar cambios'.hardcoded;
  }

  String get editAccountDetailsButtonText {
    return 'Edita los datos de tu cuenta'.hardcoded;
  }

  String get cancelEditAccountDetailsButtonText {
    return 'Cancelar edición'.hardcoded;
  }

  String get updateCredentialsButtonText {
    return '¿Quieres administrar tus credenciales?'.hardcoded;
  }

  AccountDetailsFormType get secondaryActionFormType {
    return AccountDetailsFormType.accountDetails;
  }

  String get errorAlertTitle {
    return 'Ocurrió un error al registrarse'.hardcoded;
  }

  String get title {
    return 'Datos de tu cuenta'.hardcoded;
  }

  bool canSubmitEmail(String email) {
    return emailSubmitValidator.isValid(email);
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

  String? nameErrorText(String name) {
    final bool showErrorText = !canSubmitName(name);
    final String errorText = name.isEmpty
        ? 'Debes indicar un nombre de usuario'.hardcoded
        : '''El nombre debe tener entre 
            ${AccountDetailsValidators._minNameLength} y 
            ${AccountDetailsValidators._maxNameLength} caracteres
          '''
            .hardcoded;
    return showErrorText ? errorText : null;
  }

  String? dateOfBirthErrorText(String dateOfBirth) {
    final bool showErrorText = !canSubmitDateOfBirth(dateOfBirth);
    final String errorText = '''Debes tener por lo menos 
            ${AccountDetailsValidators._minUserAge} años de edad
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
