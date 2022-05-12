import 'package:skillsly_ma/src/core/common_widgets/custom_text_button.dart';
import 'package:skillsly_ma/src/core/common_widgets/primary_button.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_scrollable_card.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_in/sign_in_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/shared/utils/async_value_ui.dart';

import 'sign_in_state.dart';
import 'string_validator.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key, required this.formType}) : super(key: key);

  final SignInFormType formType;

  // * Keys for testing using find.byKey()
  static const emailKey = Key('email');
  static const passwordKey = Key('password');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Autenticación'.hardcoded)),
      body: SignInContents(
        formType: formType,
      ),
    );
  }
}

class SignInContents extends ConsumerStatefulWidget {
  const SignInContents({
    Key? key,
    this.onSignedIn,
    required this.formType,
  }) : super(key: key);

  final VoidCallback? onSignedIn;
  final SignInFormType formType;

  @override
  ConsumerState<SignInContents> createState() => _SignInContentsState();
}

class _SignInContentsState extends ConsumerState<SignInContents> {
  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String get email => _emailController.text;
  String get password => _passwordController.text;

  var _submitted = false;

  @override
  void dispose() {
    _node.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(SignInState state) async {
    setState(() => _submitted = true);
    // only submit the form if validation passes
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(signInControllerProvider(widget.formType).notifier);
      final success = await controller.submit(email, password);
      if (success) {
        widget.onSignedIn?.call();
      }
    }
  }

  void _emailEditingComplete(SignInState state) {
    if (state.canSubmitEmail(email)) {
      _node.nextFocus();
    }
  }

  void _passwordEditingComplete(SignInState state) {
    if (!state.canSubmitEmail(email)) {
      _node.previousFocus();
      return;
    }
    _submit(state);
  }

  void _updateFormType(SignInFormType formType) {
    ref.read(signInControllerProvider(widget.formType).notifier).updateFormType(formType);
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      signInControllerProvider(widget.formType).select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(signInControllerProvider(widget.formType));
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
                key: SignInScreen.emailKey,
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: 'Correo'.hardcoded,
                    hintText: 'test_email1@test.com'.hardcoded,
                    enabled: !state.isLoading,
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                        fontSize: Sizes.p12)),
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
                key: SignInScreen.passwordKey,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: state.passwordLabelText,
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
                    state.isLoading ? null : () => _updateFormType(state.secondaryActionFormType),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
