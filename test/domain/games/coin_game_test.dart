import 'package:flutter_test/flutter_test.dart';
import 'package:lexavra_gaming/domain/games/coin_game.dart';

void main() {
  late CoinGame coinGame;

  setUp(() {
    coinGame = CoinGame();
  });

  group('CoinGame', () {
    test('should return a valid coin side', () {
      final result = coinGame.play(
        bet: 100,
        prediction: CoinSide.heads,
        seed: 1,
      );

      expect(
        [CoinSide.heads, CoinSide.tails],
        contains(result.result),
      );
    });

    test('should pay 2x bet when prediction is correct', () {
      final first = coinGame.play(
        bet: 100,
        prediction: CoinSide.heads,
        seed: 1,
      );

      final prediction = first.result;

      final result = coinGame.play(
        bet: 100,
        prediction: prediction,
        seed: 1,
      );

      expect(result.won, true);
      expect(result.payout, 200);
    });

    test('should return zero payout when prediction is wrong', () {
      final first = coinGame.play(
        bet: 100,
        prediction: CoinSide.heads,
        seed: 1,
      );

      final opposite = first.result == CoinSide.heads
          ? CoinSide.tails
          : CoinSide.heads;

      final result = coinGame.play(
        bet: 100,
        prediction: opposite,
        seed: 1,
      );

      expect(result.won, false);
      expect(result.payout, 0);
    });

    test('should reject zero bet', () {
      expect(
            () => coinGame.play(
          bet: 0,
          prediction: CoinSide.heads,
          seed: 1,
        ),
        throwsArgumentError,
      );
    });

    test('should reject negative bet', () {
      expect(
            () => coinGame.play(
          bet: -100,
          prediction: CoinSide.heads,
          seed: 1,
        ),
        throwsArgumentError,
      );
    });

    test('same seed should produce the same result', () {
      final first = coinGame.play(
        bet: 100,
        prediction: CoinSide.heads,
        seed: 12345,
      );

      final second = coinGame.play(
        bet: 100,
        prediction: CoinSide.heads,
        seed: 12345,
      );

      expect(first.result, second.result);
      expect(first.won, second.won);
      expect(first.payout, second.payout);
    });
  });
}