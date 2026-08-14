import 'dart:math';

class DiceResult {
  final int roll;
  final bool won;
  final double multiplier;
  final int payout;

  const DiceResult({
    required this.roll,
    required this.won,
    required this.multiplier,
    required this.payout,
  });
}

class DiceGame {
  DiceResult play({
    required int bet,
    required int target,
    required bool rollOver,
    required int seed,
  }) {
    if (bet <= 0) {
      throw ArgumentError('Bet must be greater than zero.');
    }

    if (target < 2 || target > 98) {
      throw ArgumentError('Target must be between 2 and 98.');
    }

    final random = Random(seed);

    // Generates a value from 1 to 100.
    final roll = random.nextInt(100) + 1;

    final won = rollOver ? roll > target : roll < target;

    final chance = rollOver ? (100 - target) : (target - 1);

    final multiplier = 100 / chance;

    final payout = won ? (bet * multiplier).floor() : 0;

    return DiceResult(
      roll: roll,
      won: won,
      multiplier: multiplier,
      payout: payout,
    );
  }
}
