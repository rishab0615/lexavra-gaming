import 'package:get/get.dart';

import '../../domain/games/coin_game.dart';
import '../../domain/services/wallet_service.dart';
import 'wallet_controller.dart';

class CoinController extends GetxController {
  final CoinGame _coinGame;
  final WalletService _walletService;
  final WalletController _walletController;

  CoinController(
      this._coinGame,
      this._walletService,
      this._walletController,
      );

  final isFlipping = false.obs;
  final prediction = CoinSide.heads.obs;
  final result = Rxn<CoinResult>();

  Future<String?> flip({required int bet}) async {
    if (isFlipping.value) {
      return null;
    }

    isFlipping.value = true;

    try {
      if (bet <= 0) {
        return 'Please enter a bet greater than 0.';
      }

      try {
        final placed = await _walletService.placeBet(bet);

        if (!placed) {
          return 'A bet is already being processed.';
        }
      } on StateError catch (e) {
        if (e.message == 'Insufficient balance.') {
          return 'You don\'t have enough coins for this bet.';
        }

        return 'Unable to place the bet.';
      } on ArgumentError {
        return 'Please enter a valid bet amount.';
      }

      final seed = DateTime.now().microsecondsSinceEpoch;

      final gameResult = _coinGame.play(
        bet: bet,
        prediction: prediction.value,
        seed: seed,
      );

      if (gameResult.won) {
        await _walletService.add(gameResult.payout);
      }

      final resultingBalance = _walletService.getBalance();

      await _walletService.recordBet(
        amount: bet,
        game: 'Coin Flip',
        won: gameResult.won,
        resultingBalance: resultingBalance,
      );

      result.value = gameResult;

      _walletController.loadBalance();

      return null;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      isFlipping.value = false;
    }
  }

  void setPrediction(CoinSide value) {
    prediction.value = value;
  }
}