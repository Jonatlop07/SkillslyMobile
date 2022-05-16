import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/features/account_settings/data/account_service.dart';
import 'package:skillsly_ma/src/features/account_settings/domain/update_user_account_details.dart';

import 'account_details_state.dart';

class AccountDetailsController extends StateNotifier<AccountDetailsState> {
  AccountDetailsController({
    required AccountDetailsFormType formType,
    required this.accountService,
  }) : super(AccountDetailsState(formType: formType));

  final AccountService accountService;

  Future<bool> submit(UpdateUserAccountDetails accountDetails) async {
    state = state.copyWith(value: const AsyncValue.loading());
    final value = await AsyncValue.guard(() => _updateAccountDetails(accountDetails));
    state = state.copyWith(value: value);
    return value.hasError == false;
  }

  Future<void> _updateAccountDetails(UpdateUserAccountDetails userAccountDetails) {
    switch (state.formType) {
      case AccountDetailsFormType.accountDetails:
        return accountService.updateAccountDetails(userAccountDetails);
    }
  }

  void updateFormType(AccountDetailsFormType formType) {
    state = state.copyWith(formType: formType);
  }
}

final accountDetailsControllerProvider = StateNotifierProvider.autoDispose
    .family<AccountDetailsController, AccountDetailsState, AccountDetailsFormType>((ref, formType) {
  final accountService = ref.watch(accountServiceProvider);
  return AccountDetailsController(
    formType: formType,
    accountService: accountService,
  );
});
