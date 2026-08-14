import '../../data/local/local_storage.dart';

class WalletService {
  final LocalStorage _localStorage;
  bool _transactionInProgress = false;

  WalletService(this._localStorage);

  int getBalance() {
    final user = _localStorage.getUser();

    if (user == null) {
      return 0;
    }

    return user['balance'] as int;
  }

  Future<void> createUser({
    required String id,
    required String username,
    int startingBalance = 1000,
  }) async {
    await _localStorage.saveUser({
      'id': id,
      'username': username,
      'balance': startingBalance,
    });
  }

  Future<void> recordBet({
    required int amount,
    required String game,
    required bool won,
    required int resultingBalance,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    await _localStorage.saveBet(id, {
      'id': id,
      'amount': amount,
      'game': game,
      'won': won,
      'resultingBalance': resultingBalance,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> placeBet(int amount) async {
    if (_transactionInProgress) {
      return false;
    }

    _transactionInProgress = true;

    try {
      if (amount <= 0) {
        throw ArgumentError('Bet amount must be greater than zero.');
      }

      final user = _localStorage.getUser();

      if (user == null) {
        throw StateError('User does not exist.');
      }

      final currentBalance = user['balance'] as int;

      if (amount > currentBalance) {
        throw StateError('Insufficient balance.');
      }

      user['balance'] = currentBalance - amount;

      await _localStorage.saveUser(user);

      return true;
    } finally {
      _transactionInProgress = false;
    }
  }

  Future<void> add(int amount) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero.');
    }

    final user = _localStorage.getUser();

    if (user == null) {
      throw StateError('User does not exist.');
    }

    final currentBalance = getBalance();

    user['balance'] = currentBalance + amount;

    await _localStorage.saveUser(user);
  }
}
