import 'package:get/get.dart';

import '../../domain/services/wallet_service.dart';

class WalletController extends GetxController {
  final WalletService _walletService;

  WalletController(this._walletService);

  final balance = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadBalance();
  }

  void loadBalance() {
    balance.value = _walletService.getBalance();
  }
}
