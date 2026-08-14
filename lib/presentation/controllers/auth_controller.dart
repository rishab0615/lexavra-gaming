import 'package:get/get.dart';

import '../../data/local/local_storage.dart';
import '../../domain/services/wallet_service.dart';

class AuthController extends GetxController {
  final LocalStorage _localStorage;
  final WalletService _walletService;

  AuthController(this._localStorage, this._walletService);

  final isLoggedIn = false.obs;
  final username = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSession();
  }

  void loadSession() {
    final user = _localStorage.getUser();
    final sessionActive = _localStorage.getSession();

    if (user != null && sessionActive) {
      username.value = user['username'] as String;
      isLoggedIn.value = true;
    }
  }

  Future<void> login(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Username cannot be empty.');
    }

    final existingUser = _localStorage.getUser();

    if (existingUser == null) {
      await _walletService.createUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: trimmedName,
      );
    } else {
      existingUser['username'] = trimmedName;

      await _localStorage.saveUser(existingUser);
    }

    await _localStorage.saveSession(true);

    username.value = trimmedName;
    isLoggedIn.value = true;

    Get.offAllNamed('/home');
  }

  Future<void> logout() async {
    await _localStorage.clearSession();

    isLoggedIn.value = false;
    username.value = '';

    Get.offAllNamed('/login');
  }
}
