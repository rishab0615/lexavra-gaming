import 'package:get/get.dart';

import '../../domain/games/coin_game.dart';
import '../../domain/services/wallet_service.dart';
import '../controllers/coin_controller.dart';
import '../controllers/wallet_controller.dart';

class CoinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinGame>(() => CoinGame());

    Get.lazyPut<CoinController>(
          () => CoinController(
        Get.find<CoinGame>(),
        Get.find<WalletService>(),
        Get.find<WalletController>(),
      ),
    );
  }
}