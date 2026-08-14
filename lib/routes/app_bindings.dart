import 'package:get/get.dart';

import '../data/local/local_storage.dart';
import '../domain/services/wallet_service.dart';
import '../presentation/controllers/auth_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    final localStorage = Get.find<LocalStorage>();

    final walletService = WalletService(localStorage);

    Get.put<WalletService>(walletService, permanent: true);

    Get.put<AuthController>(
      AuthController(localStorage, walletService),
      permanent: true,
    );
  }
}
