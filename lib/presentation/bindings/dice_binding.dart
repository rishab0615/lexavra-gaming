import 'package:get/get.dart';

import '../../domain/games/dice_game.dart';
import '../../domain/services/wallet_service.dart';
import '../controllers/dice_controller.dart';
import '../controllers/wallet_controller.dart';

class DiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiceGame>(() => DiceGame());

    Get.lazyPut<DiceController>(
      () => DiceController(
        Get.find<DiceGame>(),
        Get.find<WalletService>(),
        Get.find<WalletController>(),
      ),
    );
  }
}
