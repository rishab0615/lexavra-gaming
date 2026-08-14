import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const String userBoxName = 'user_box';
  static const String betsBoxName = 'bets_box';

  static const String currentUserKey = 'current_user';
  static const String sessionKey = 'is_logged_in';

  late Box userBox;
  late Box betsBox;

  Future<void> init({String? path}) async {
    if (path != null) {
      if (!Hive.isBoxOpen(userBoxName)) {
        Hive.init(path);
      }
    } else {
      await Hive.initFlutter();
    }

    userBox = await Hive.openBox(userBoxName);
    betsBox = await Hive.openBox(betsBoxName);
  }

  // User

  Future<void> saveUser(Map<String, dynamic> user) async {
    await userBox.put(currentUserKey, user);
  }

  Map<String, dynamic>? getUser() {
    final data = userBox.get(currentUserKey);

    if (data == null) {
      return null;
    }

    return Map<String, dynamic>.from(data);
  }

  Future<void> clearUser() async {
    await userBox.delete(currentUserKey);
  }

  // Session

  Future<void> saveSession(bool isLoggedIn) async {
    await userBox.put(sessionKey, isLoggedIn);
  }

  bool getSession() {
    return userBox.get(sessionKey, defaultValue: false) as bool;
  }

  Future<void> clearSession() async {
    await userBox.delete(sessionKey);
  }

  // Bets

  Future<void> saveBet(String id, Map<String, dynamic> bet) async {
    await betsBox.put(id, bet);
  }

  List<Map<String, dynamic>> getBets() {
    return betsBox.values.map((bet) => Map<String, dynamic>.from(bet)).toList();
  }

  Future<void> clearBets() async {
    await betsBox.clear();
  }
}
