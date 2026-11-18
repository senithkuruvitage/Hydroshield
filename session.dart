import 'package:flutter/foundation.dart';

import 'constants/app_constants.dart';

class SessionStore {
  SessionStore._();
  static final SessionStore instance = SessionStore._();

  final ValueNotifier<UserRole?> role = ValueNotifier<UserRole?>(null);
  final ValueNotifier<String?> userName = ValueNotifier<String?>(null);
  final ValueNotifier<String?> propertyName = ValueNotifier<String?>('Greenview Residence');

  bool get isLoggedIn => role.value != null;

  void login({required UserRole asRole, String name = 'User'}) {
    role.value = asRole;
    userName.value = name;
  }

  void logout() {
    role.value = null;
    userName.value = null;
  }
}
