import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:lexavra_gaming/data/local/local_storage.dart';
import 'package:lexavra_gaming/domain/services/wallet_service.dart';

void main() {
  late LocalStorage localStorage;
  late WalletService walletService;
  late String testPath;

  setUpAll(() async {
    final directory = await Directory.systemTemp.createTemp(
      'lexavra_wallet_test_',
    );

    testPath = directory.path;
    Hive.init(testPath);
  });

  setUp(() async {
    if (Hive.isBoxOpen(LocalStorage.userBoxName)) {
      await Hive.box(LocalStorage.userBoxName).clear();
    }

    if (Hive.isBoxOpen(LocalStorage.betsBoxName)) {
      await Hive.box(LocalStorage.betsBoxName).clear();
    }

    localStorage = LocalStorage();

    await localStorage.init(path: testPath);

    walletService = WalletService(localStorage);

    await walletService.createUser(
      id: 'test-user',
      username: 'Test User',
      startingBalance: 1000,
    );
  });

  tearDown(() async {
    await localStorage.userBox.clear();
    await localStorage.betsBox.clear();

    await localStorage.userBox.close();
    await localStorage.betsBox.close();
  });

  group('WalletService', () {
    test('new user should have the starting balance', () {
      expect(walletService.getBalance(), 1000);
    });

    test('placeBet should deduct the bet amount', () async {
      final result = await walletService.placeBet(100);

      expect(result, true);
      expect(walletService.getBalance(), 900);
    });

    test('placeBet should reject zero amount', () async {
      expect(() => walletService.placeBet(0), throwsArgumentError);

      expect(walletService.getBalance(), 1000);
    });

    test('placeBet should reject negative amount', () async {
      expect(() => walletService.placeBet(-100), throwsArgumentError);

      expect(walletService.getBalance(), 1000);
    });

    test('placeBet should reject amount greater than balance', () async {
      expect(() => walletService.placeBet(1001), throwsStateError);

      expect(walletService.getBalance(), 1000);
    });

    test('balance should never become negative', () async {
      await walletService.placeBet(1000);

      expect(walletService.getBalance(), 0);

      expect(() => walletService.placeBet(1), throwsStateError);

      expect(walletService.getBalance(), 0);
    });

    test('add should increase the balance', () async {
      await walletService.placeBet(100);

      await walletService.add(250);

      expect(walletService.getBalance(), 1150);
    });

    test('add should reject zero amount', () async {
      expect(() => walletService.add(0), throwsArgumentError);

      expect(walletService.getBalance(), 1000);
    });

    test('add should reject negative amount', () async {
      expect(() => walletService.add(-50), throwsArgumentError);

      expect(walletService.getBalance(), 1000);
    });

    test('placeBet should persist the updated balance', () async {
      await walletService.placeBet(300);

      final storedUser = localStorage.getUser();

      expect(storedUser, isNotNull);
      expect(storedUser!['balance'], 700);
    });

    test('add should persist the updated balance', () async {
      await walletService.add(500);

      final storedUser = localStorage.getUser();

      expect(storedUser, isNotNull);
      expect(storedUser!['balance'], 1500);
    });
    test('placeBet should reject concurrent transactions', () async {
      final results = await Future.wait([
        walletService.placeBet(100),
        walletService.placeBet(100),
      ]);

      expect(results.where((result) => result).length, 1);
      expect(results.where((result) => !result).length, 1);
      expect(walletService.getBalance(), 900);
    });
    test('recordBet should persist the bet in the ledger', () async {
      await walletService.placeBet(100);

      await walletService.recordBet(
        amount: 100,
        game: 'Dice',
        won: true,
        resultingBalance: 900,
      );

      final bets = localStorage.getBets();

      expect(bets.length, 1);
      expect(bets.first['amount'], 100);
      expect(bets.first['game'], 'Dice');
      expect(bets.first['won'], true);
      expect(bets.first['resultingBalance'], 900);
      expect(bets.first['createdAt'], isNotNull);
    });
  });
}
