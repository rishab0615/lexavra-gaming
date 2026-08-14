import 'package:get/get.dart';

import '../../domain/services/wallet_service.dart';
import '../controllers/wallet_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletController>(
      () => WalletController(Get.find<WalletService>()),
    );
  }
}
