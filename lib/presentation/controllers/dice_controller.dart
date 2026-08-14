import 'package:get/get.dart';

import '../../domain/games/dice_game.dart';
import '../../domain/services/wallet_service.dart';
import 'wallet_controller.dart';

class DiceController extends GetxController {
  final DiceGame _diceGame;
  final WalletService _walletService;
  final WalletController _walletController;
  final errorMessage = RxnString();

  DiceController(this._diceGame, this._walletService, this._walletController);

  final isRolling = false.obs;
  final result = Rxn<DiceResult>();

  final rollOver = true.obs;

  Future<String?> roll({required int bet, required int target}) async {
    if (isRolling.value) {
      return null;
    }

    isRolling.value = true;

    try {
      // Validate input before moving any coins.
      if (bet <= 0) {
        return 'Please enter a bet greater than 0.';
      }

      if (target < 2 || target > 98) {
        return 'Target must be between 2 and 98.';
      }

      // Place the bet through the wallet service.
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

      // Generate the game result.
      final seed = DateTime.now().microsecondsSinceEpoch;

      final gameResult = _diceGame.play(
        bet: bet,
        target: target,
        rollOver: rollOver.value,
        seed: seed,
      );

      // Apply winnings.
      if (gameResult.won) {
        await _walletService.add(gameResult.payout);
      }

      // Read the actual persisted balance.
      final resultingBalance = _walletService.getBalance();

      // Record the completed bet.
      await _walletService.recordBet(
        amount: bet,
        game: 'Dice',
        won: gameResult.won,
        resultingBalance: resultingBalance,
      );

      // Update the game result shown by the UI.
      result.value = gameResult;

      // Synchronize the GetX wallet state.
      _walletController.loadBalance();

      return null;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      isRolling.value = false;
    }
  }

  void setPrediction(bool value) {
    rollOver.value = value;
  }
}
