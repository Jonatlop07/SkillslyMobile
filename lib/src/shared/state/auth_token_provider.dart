import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/features/authentication/domain/app_user.dart';
import 'package:skillsly_ma/src/shared/utils/app_in_memory_store.dart';

final StateProvider<String> authTokenProvider = StateProvider<String>((_) => '');

final StateProvider<AppInMemoryStore<AppUser?>> authStateProvider =
    StateProvider<AppInMemoryStore<AppUser?>>((_) => AppInMemoryStore<AppUser?>(null));
