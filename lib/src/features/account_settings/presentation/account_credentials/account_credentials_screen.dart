// import 'package:skillsly_ma/src/core/common_widgets/custom_text_button.dart';
// import 'package:skillsly_ma/src/core/common_widgets/delete_button.dart';
// import 'package:skillsly_ma/src/core/common_widgets/primary_button.dart';
// import 'package:skillsly_ma/src/core/common_widgets/responsive_scrollable_card.dart';
// import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
// import 'package:skillsly_ma/src/core/constants/palette.dart';
// import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:skillsly_ma/src/shared/utils/async_value_ui.dart';
// import 'package:skillsly_ma/src/shared/utils/string_validator.dart';
//
// import 'account_credentials_controller.dart';
// import 'account_credentials_state.dart';
//
// class AccountCredentialsScreen extends StatelessWidget {
//   const AccountCredentialsScreen({Key? key, required this.formType}) : super(key: key);
//
//   final AccountCredentialsFormType formType;
//
//   // * Keys for testing using find.byKey()
//   static const emailKey = Key('email');
//   static const passwordKey = Key('password');
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Administración de la cuenta'.hardcoded)),
//       body: AccountCredentialsContents(
//         formType: formType,
//       ),
//     );
//   }
// }
//
// class AccountCredentialsContents extends ConsumerStatefulWidget {
//   const AccountCredentialsContents({
//     Key? key,
//     this.onSubmit,
//     required this.formType,
//   }) : super(key: key);
//
//   final VoidCallback? onSubmit;
//   final AccountCredentialsFormType formType;
//
//   @override
//   ConsumerState<AccountCredentialsContents> createState() => _AccountCredentialsContentsState();
// }
//
// class _AccountCredentialsContentsState extends ConsumerState<AccountCredentialsContents> {
//   final _formKey = GlobalKey<FormState>();
//   final _node = FocusScopeNode();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   String get email => _emailController.text;
//   String get password => _passwordController.text;
//
//   var _submitted = false;
//
//   @override
//   void dispose() {
//     _node.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submit(AccountCredentialsState state) async {
//     setState(() => _submitted = true);
//     // only submit the form if validation passes
//     if (_formKey.currentState!.validate()) {
//       final controller = ref.read(
//         accountCredentialsControllerProvider(widget.formType).notifier,
//       );
//       final success = await controller.submit(email, password);
//       if (success) {
//         widget.onSubmit?.call();
//       }
//     }
//   }
//
//   void _emailEditingComplete(AccountCredentialsState state) {
//     if (state.canSubmitEmail(email)) {
//       _node.nextFocus();
//     }
//   }
//
//   void _passwordEditingComplete(AccountCredentialsState state) {
//     if (!state.canSubmitEmail(email)) {
//       _node.previousFocus();
//       return;
//     }
//     _submit(state);
//   }
//
//   void _updateFormType(AccountCredentialsFormType formType) {
//     ref
//         .read(accountCredentialsControllerProvider(widget.formType).notifier)
//         .updateFormType(formType);
//     _passwordController.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen<AsyncValue>(
//       accountCredentialsControllerProvider(widget.formType).select((state) => state.value),
//       (_, state) => state.showAlertDialogOnError(context),
//     );
//     final state = ref.watch(accountCredentialsControllerProvider(widget.formType));
//     final actionButton = state.formType == AccountCredentialsFormType.deleteAccount
//         ? OutlinedActionButtonWithIcon(
//             text: state.primaryButtonText,
//             color: Palette.tertiary,
//             iconData: Icons.delete_forever_outlined,
//             onPressed: state.isLoading ? null : () => _submit(state),
//           )
//         : OutlinedActionButtonWithIcon(
//             text: state.primaryButtonText,
//             color: Palette.secondary,
//             iconData: Icons.update_outlined,
//             onPressed: state.isLoading ? null : () => _submit(state),
//           );
//     return ResponsiveScrollableCard(
//       child: FocusScope(
//         node: _node,
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               gapH8,
//               // Email field
//               TextFormField(
//                 key: AccountCredentialsScreen.emailKey,
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Correo electrónico'.hardcoded,
//                   hintText: 'ejemplo_correo1@ejemplo.com'.hardcoded,
//                   enabled: !state.isLoading,
//                   hintStyle: TextStyle(
//                     color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
//                     fontSize: Sizes.p12,
//                   ),
//                 ),
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 validator: (email) => !_submitted ? null : state.emailErrorText(email ?? ''),
//                 autocorrect: false,
//                 textInputAction: TextInputAction.next,
//                 keyboardType: TextInputType.emailAddress,
//                 keyboardAppearance: Brightness.light,
//                 onEditingComplete: () => _emailEditingComplete(state),
//                 inputFormatters: <TextInputFormatter>[
//                   ValidatorInputFormatter(editingValidator: EmailEditingRegexValidator()),
//                 ],
//               ),
//               gapH24,
//               // Password field
//               TextFormField(
//                 key: AccountCredentialsScreen.passwordKey,
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: state.passwordLabelText,
//                   enabled: !state.isLoading,
//                 ),
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 validator: (password) =>
//                     !_submitted ? null : state.passwordErrorText(password ?? ''),
//                 obscureText: true,
//                 autocorrect: false,
//                 textInputAction: TextInputAction.done,
//                 keyboardAppearance: Brightness.light,
//                 onEditingComplete: () => _passwordEditingComplete(state),
//               ),
//               gapH24,
//               actionButton,
//               gapH24,
//               CustomTextButton(
//                 text: state.secondaryButtonText,
//                 onPressed:
//                     state.isLoading ? null : () => _updateFormType(state.alternativeActionFormType),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
