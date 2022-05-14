import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsly_ma/src/shared/state/app_user.dart';

final StateProvider<AppUser?> authStateProvider = StateProvider<AppUser?>((_) => null);
