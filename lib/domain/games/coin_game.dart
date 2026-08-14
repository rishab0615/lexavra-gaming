import 'dart:math';

enum CoinSide {
  heads,
  tails,
}

class CoinResult {
  final CoinSide prediction;
  final CoinSide result;
  final bool won;
  final int payout;

  const CoinResult({
    required this.prediction,
    required this.result,
    required this.won,
    required this.payout,
  });
}

class CoinGame {
  CoinResult play({
    required int bet,
    required CoinSide prediction,
    required int seed,
  }) {
    if (bet <= 0) {
      throw ArgumentError('Bet amount must be greater than zero.');
    }

    final random = Random(seed);
    final result = random.nextBool() ? CoinSide.heads : CoinSide.tails;

    final won = result == prediction;

    return CoinResult(
      prediction: prediction,
      result: result,
      won: won,
      payout: won ? bet * 2 : 0,
    );
  }
}