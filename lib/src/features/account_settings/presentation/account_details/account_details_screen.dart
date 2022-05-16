import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/common_widgets/custom_text_button.dart';
import 'package:skillsly_ma/src/core/common_widgets/outlined_action_button_with_icon.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_scrollable_card.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/palette.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/main_drawer.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/account_settings/data/account_service.dart';
import 'package:skillsly_ma/src/features/account_settings/domain/update_user_account_details.dart';
import 'package:skillsly_ma/src/features/account_settings/domain/user_account_details.dart';
import 'package:skillsly_ma/src/shared/utils/async_value_ui.dart';
import 'package:skillsly_ma/src/shared/utils/date_formatter.dart';
import 'package:skillsly_ma/src/shared/utils/string_validator.dart';

import 'account_details_controller.dart';
import 'account_details_state.dart';

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({Key? key, required this.formType}) : super(key: key);

  final AccountDetailsFormType formType;

  static const emailKey = Key('email');
  static const nameKey = Key('name');
  static const dateOfBirthKey = Key('dateOfBirth');
  static const genderKey = Key('gender');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi cuenta'.hardcoded)),
      drawer: const MainDrawer(),
      body: AccountDetailsContents(formType: formType),
    );
  }
}

class AccountDetailsContents extends ConsumerStatefulWidget {
  const AccountDetailsContents({
    Key? key,
    required this.formType,
  }) : super(key: key);

  final AccountDetailsFormType formType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AccountDetailsContentsState();
  }
}

class _AccountDetailsContentsState extends ConsumerState<AccountDetailsContents> {
  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime _dateOfBirth = DateTime.now();
  String _gender = 'male';

  String get email => _emailController.text;
  String get name => _nameController.text;
  String get dateOfBirth => dateOfBirthFormatter.format(_dateOfBirth);
  String get gender => _gender;

  var _editing = false;
  var _submitted = false;

  Future<UserAccountDetails> _getUserAccountDetails() {
    final accountService = ref.read(accountServiceProvider);
    return accountService.getUserAccountDetails();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _resetChanges());
  }

  @override
  void dispose() {
    _node.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _resetChanges() async {
    UserAccountDetails accountDetails = await _getUserAccountDetails();
    setState(() {
      _emailController.value = TextEditingValue(
        text: accountDetails.email,
        selection: TextSelection.fromPosition(
          TextPosition(offset: accountDetails.email.length),
        ),
      );
      _nameController.value = TextEditingValue(
        text: accountDetails.name,
        selection: TextSelection.fromPosition(
          TextPosition(offset: accountDetails.name.length),
        ),
      );
      _dateOfBirth = dateOfBirthFormatter.parse(accountDetails.dateOfBirth);
      _gender = accountDetails.gender;
    });
  }

  void _presentDateTimePicker() {
    showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: dateOfBirthFormatter.parse('01/01/1901'),
      lastDate: DateTime.now(),
      fieldLabelText: 'Fecha de nacimiento'.hardcoded,
      fieldHintText: 'Selecciona tu fecha de nacimiento'.hardcoded,
      locale: Localizations.localeOf(context),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _dateOfBirth = pickedDate;
      });
    });
  }

  void _toggleEditing() {
    setState(() {
      _editing = !_editing;
    });
  }

  Future<void> _submit(AccountDetailsState state) async {
    setState(() => _submitted = true);
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(accountDetailsControllerProvider(widget.formType).notifier);
      final success = await controller.submit(
        UpdateUserAccountDetails(
          email: email,
          name: name,
          dateOfBirth: dateOfBirth,
          gender: gender,
        ),
      );
    }
  }

  void _emailEditingComplete(AccountDetailsState state) {
    if (state.canSubmitEmail(email)) {
      _node.nextFocus();
    }
  }

  void _nameEditingComplete(AccountDetailsState state) {
    if (!state.canSubmitEmail(email)) {
      _node.previousFocus();
      return;
    }
    if (!state.canSubmitName(name)) {
      _node.nextFocus();
    }
  }

  void _genderEditingComplete(AccountDetailsState state) {
    if (!state.canSubmitDateOfBirth(dateOfBirth)) {
      _node.previousFocus();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      accountDetailsControllerProvider(widget.formType).select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(accountDetailsControllerProvider(widget.formType));

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
                key: AccountDetailsScreen.emailKey,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: state.emailLabelText.hardcoded,
                  enabled: !state.isLoading,
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
                enabled: _editing,
              ),
              gapH8,
              TextFormField(
                key: AccountDetailsScreen.nameKey,
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
                enabled: _editing,
              ),
              gapH8,
              // ignore: sized_box_for_whitespace
              Container(
                height: Sizes.p64,
                child: Column(
                  children: <Widget>[
                    CustomTextButton(
                      text: 'Selecciona una fecha de nacimiento',
                      style: _editing
                          ? const TextStyle(color: Palette.secondary)
                          : const TextStyle(color: Colors.grey),
                      onPressed: () {
                        if (_editing) _presentDateTimePicker();
                      },
                    ),
                    Expanded(
                      child: Text('Fecha de nacimiento: $dateOfBirth'),
                    ),
                  ],
                ),
              ),
              gapH8,
              SizedBox(
                height: Sizes.p64,
                child: Column(
                  children: [
                    DropdownButton(
                      key: AccountDetailsScreen.genderKey,
                      value: _gender,
                      items: genderOptions
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender['value'],
                              child: Text(gender['text']!),
                            ),
                          )
                          .toList(),
                      onChanged: !_editing
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _gender = newValue!;
                              });
                              _genderEditingComplete(state);
                            },
                    ),
                  ],
                ),
              ),
              gapH8,
              _editing
                  ? CustomTextButton(
                      text: state.cancelEditAccountDetailsButtonText,
                      style: const TextStyle(color: Palette.tertiary),
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              _toggleEditing();
                              await _resetChanges();
                            },
                    )
                  : CustomTextButton(
                      text: state.editAccountDetailsButtonText,
                      style: const TextStyle(color: Palette.secondary),
                      onPressed: state.isLoading ? null : () => _toggleEditing(),
                    ),
              if (_editing)
                OutlinedActionButtonWithIcon(
                  text: state.applyAccountDetailsUpdatesButtonText,
                  color: Palette.secondary,
                  iconData: Icons.update_outlined,
                  onPressed:
                      state.isLoading ? null : () => _submit(state).then((_) => _toggleEditing()),
                ),
              gapH8,
              CustomTextButton(
                text: state.updateCredentialsButtonText,
                onPressed:
                    state.isLoading ? null : () => GoRouter.of(context).goNamed(Routes.credentials),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
