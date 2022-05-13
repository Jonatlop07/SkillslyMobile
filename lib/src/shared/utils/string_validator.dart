import 'package:flutter/services.dart';
import 'package:skillsly_ma/src/shared/utils/date_formatter.dart';

/// This file contains some helper functions used for string validation.
abstract class StringValidator {
  bool isValid(String value);
}

class RegexValidator implements StringValidator {
  RegexValidator({required this.regexSource});
  final String regexSource;

  @override
  bool isValid(String value) {
    try {
      // https://regex101.com/
      final RegExp regex = RegExp(regexSource);
      final Iterable<Match> matches = regex.allMatches(value);
      for (final match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // Invalid regex
      assert(false, e.toString());
      return true;
    }
  }
}

class ValidatorInputFormatter implements TextInputFormatter {
  ValidatorInputFormatter({required this.editingValidator});
  final StringValidator editingValidator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final bool oldValueValid = editingValidator.isValid(oldValue.text);
    final bool newValueValid = editingValidator.isValid(newValue.text);
    if (oldValueValid && !newValueValid) {
      return oldValue;
    }
    return newValue;
  }
}

class EmailEditingRegexValidator extends RegexValidator {
  EmailEditingRegexValidator() : super(regexSource: '^(|\\S)+\$');
}

class EmailSubmitRegexValidator extends RegexValidator {
  EmailSubmitRegexValidator()
      : super(
          regexSource:
              '^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})\$',
        );
}

class PasswordEditingRegexValidator extends RegexValidator {
  PasswordEditingRegexValidator() : super(regexSource: '^(|\\S)+\$');
}

class PasswordSubmitRegexValidator extends RegexValidator {
  PasswordSubmitRegexValidator()
      : super(
          regexSource: '^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_]).{8,}\$',
        );
}

class NonEmptyStringValidator extends StringValidator {
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class MinLengthStringValidator extends StringValidator {
  MinLengthStringValidator(this.minLength);
  final int minLength;

  @override
  bool isValid(String value) {
    return value.length >= minLength;
  }
}

class ConstrainedLengthStringValidator extends StringValidator {
  ConstrainedLengthStringValidator({
    required this.minLength,
    required this.maxLength,
  });

  final int minLength;
  final int maxLength;

  int get min => minLength;
  int get max => maxLength;

  @override
  bool isValid(String value) {
    return value.length >= minLength && value.length <= maxLength;
  }
}

class DateOfBirthSubmitValidator extends StringValidator {
  DateOfBirthSubmitValidator(this._minUserAge);
  final int _minUserAge;

  @override
  bool isValid(String value) {
    final dateOfBirth = dateOfBirthFormatter.parse(value);
    return dateOfBirth.year > 1900 && DateTime.now().year - dateOfBirth.year >= _minUserAge;
  }
}
