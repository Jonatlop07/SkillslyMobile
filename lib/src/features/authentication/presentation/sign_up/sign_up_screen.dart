import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/common_widgets/custom_text_button.dart';
import 'package:skillsly_ma/src/core/common_widgets/primary_button.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_scrollable_card.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/palette.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/route_paths.dart';
import 'package:skillsly_ma/src/features/authentication/domain/sign_up_details.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_up/sign_up_controller.dart';
import 'package:skillsly_ma/src/shared/utils/date_formatter.dart';
import 'package:skillsly_ma/src/shared/utils/string_validator.dart';
import 'package:skillsly_ma/src/shared/utils/async_value_ui.dart';

import 'sign_up_state.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key, required this.formType}) : super(key: key);

  final SignUpFormType formType;

  // * Keys for testing using find.byKey()
  static const emailKey = Key('email');
  static const passwordKey = Key('password');
  static const nameKey = Key('name');
  static const dateOfBirthKey = Key('dateOfBirth');
  static const genderKey = Key('gender');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Registro'.hardcoded)),
        body: SignUpContents(
          formType: formType,
        ));
  }
}

class SignUpContents extends ConsumerStatefulWidget {
  const SignUpContents({
    Key? key,
    this.onSignedUp,
    required this.formType,
  }) : super(key: key);

  final VoidCallback? onSignedUp;
  final SignUpFormType formType;

  @override
  ConsumerState<SignUpContents> createState() => _SignUpContentsState();
}

class _SignUpContentsState extends ConsumerState<SignUpContents> {
  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime _selectedDateOfBirth = DateTime.now();
  String _selectedGender = 'male';

  String get email => _emailController.text;
  String get password => _passwordController.text;
  String get name => _nameController.text;
  String get dateOfBirth => dateOfBirthFormatter.format(_selectedDateOfBirth);
  String get gender => _selectedGender;

  var _submitted = false;

  @override
  void dispose() {
    _node.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _presentDateTimePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth,
      firstDate: dateOfBirthFormatter.parse('01/01/1900'),
      lastDate: DateTime.now(),
      fieldLabelText: 'Fecha de nacimiento'.hardcoded,
      fieldHintText: 'Selecciona tu fecha de nacimiento'.hardcoded,
      locale: Localizations.localeOf(context),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDateOfBirth = pickedDate;
      });
    });
  }

  Future<void> _submit(SignUpState state) async {
    setState(() => _submitted = true);
    // only submit the form if validation passes
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(signUpControllerProvider(widget.formType).notifier);
      final success = await controller.submit(
        SignUpDetails(
          email: email,
          password: password,
          name: name,
          dateOfBirth: dateOfBirth,
          gender: gender,
        ),
      );
      if (success) {
        widget.onSignedUp?.call();
      }
    }
  }

  void _emailEditingComplete(SignUpState state) {
    if (state.canSubmitEmail(email)) {
      _node.nextFocus();
    }
  }

  void _passwordEditingComplete(SignUpState state) {
    if (!state.canSubmitEmail(email)) {
      _node.previousFocus();
      return;
    }
    if (state.canSubmitPassword(password)) {
      _node.nextFocus();
    }
  }

  void _nameEditingComplete(SignUpState state) {
    if (!state.canSubmitPassword(password)) {
      _node.previousFocus();
      return;
    }
    if (!state.canSubmitName(name)) {
      _node.nextFocus();
    }
  }

  void _genderEditingComplete(SignUpState state) {
    if (!state.canSubmitDateOfBirth(dateOfBirth)) {
      _node.previousFocus();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      signUpControllerProvider(widget.formType).select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(signUpControllerProvider(widget.formType));

    final genderOptions = [
      {'value': 'male', 'text': 'Hombre'.hardcoded},
      {'value': 'female', 'text': 'Mujer'.hardcoded},
      {'value': 'other', 'text': 'Otro'.hardcoded}
    ];

    return ResponsiveScrollableCard(
      child: FocusScope(
        node: _node,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              gapH8,
              // Email field
              TextFormField(
                key: SignUpScreen.emailKey,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico'.hardcoded,
                  hintText: 'ejemplo_correo1@ejemplo.com'.hardcoded,
                  enabled: !state.isLoading,
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                      fontSize: Sizes.p12),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) => !_submitted ? null : state.emailErrorText(email ?? ''),
                autocorrect: false,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                keyboardAppearance: Brightness.light,
                onEditingComplete: () => _emailEditingComplete(state),
                inputFormatters: <TextInputFormatter>[
                  ValidatorInputFormatter(editingValidator: EmailEditingRegexValidator()),
                ],
              ),
              gapH8,
              // Password field
              TextFormField(
                key: SignUpScreen.passwordKey,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: state.passwordLabelText,
                  hintText: 'Mínimo una minúscula, mayúscula, número y símbolo'.hardcoded,
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
                      fontSize: Sizes.p12),
                  enabled: !state.isLoading,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (password) =>
                    !_submitted ? null : state.passwordErrorText(password ?? ''),
                obscureText: true,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                keyboardAppearance: Brightness.light,
                onEditingComplete: () => _passwordEditingComplete(state),
                inputFormatters: <TextInputFormatter>[
                  ValidatorInputFormatter(editingValidator: PasswordEditingRegexValidator())
                ],
              ),
              gapH8,
              TextFormField(
                key: SignUpScreen.nameKey,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: state.nameLabelText,
                  enabled: !state.isLoading,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (name) => !_submitted ? null : state.nameErrorText(name ?? ''),
                autocorrect: false,
                textInputAction: TextInputAction.done,
                keyboardAppearance: Brightness.light,
                onEditingComplete: () => _nameEditingComplete(state),
              ),
              gapH8,
              // ignore: sized_box_for_whitespace
              Container(
                height: Sizes.p64,
                child: Column(
                  children: <Widget>[
                    CustomTextButton(
                      text: 'Selecciona una fecha de nacimiento',
                      style: const TextStyle(
                        color: Palette.secondary,
                      ),
                      onPressed: _presentDateTimePicker,
                    ),
                    Expanded(child: Text('Fecha seleccionada: $dateOfBirth')),
                  ],
                ),
              ),
              gapH8,
              SizedBox(
                height: Sizes.p64,
                child: Column(
                  children: [
                    DropdownButton(
                      key: SignUpScreen.genderKey,
                      value: _selectedGender,
                      items: genderOptions
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender['value'],
                              child: Text(gender['text']!),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                        _genderEditingComplete(state);
                      },
                    ),
                  ],
                ),
              ),
              gapH8,
              PrimaryButton(
                text: state.primaryButtonText,
                isLoading: state.isLoading,
                onPressed: state.isLoading ? null : () => _submit(state),
              ),
              gapH8,
              CustomTextButton(
                text: state.secondaryButtonText,
                onPressed:
                    state.isLoading ? null : () => GoRouter.of(context).go(RoutePaths.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
