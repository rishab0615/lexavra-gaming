import 'package:flutter_test/flutter_test.dart';

import 'package:lexavra_gaming/domain/games/dice_game.dart';

void main() {
  late DiceGame diceGame;

  setUp(() {
    diceGame = DiceGame();
  });

  group('DiceGame', () {
    test('same seed should produce the same result', () {
      final firstResult = diceGame.play(
        bet: 10,
        target: 50,
        rollOver: true,
        seed: 12345,
      );

      final secondResult = diceGame.play(
        bet: 10,
        target: 50,
        rollOver: true,
        seed: 12345,
      );

      expect(firstResult.roll, secondResult.roll);
      expect(firstResult.won, secondResult.won);
      expect(firstResult.multiplier, secondResult.multiplier);
      expect(firstResult.payout, secondResult.payout);
    });

    test('roll should always be between 1 and 100', () {
      final result = diceGame.play(
        bet: 10,
        target: 50,
        rollOver: true,
        seed: 12345,
      );

      expect(result.roll, inInclusiveRange(1, 100));
    });

    test('invalid bet should throw ArgumentError', () {
      expect(
        () => diceGame.play(bet: 0, target: 50, rollOver: true, seed: 12345),
        throwsArgumentError,
      );
    });

    test('invalid target should throw ArgumentError', () {
      expect(
        () => diceGame.play(bet: 10, target: 1, rollOver: true, seed: 12345),
        throwsArgumentError,
      );

      expect(
        () => diceGame.play(bet: 10, target: 99, rollOver: true, seed: 12345),
        throwsArgumentError,
      );
    });

    test('seed should produce the expected deterministic result', () {
      final result = diceGame.play(
        bet: 10,
        target: 50,
        rollOver: true,
        seed: 12345,
      );

      expect(result.roll, 32);
      expect(result.won, false);
      expect(result.multiplier, 2.0);
      expect(result.payout, 0);
    });
  });
}
