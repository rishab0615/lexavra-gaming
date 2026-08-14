import 'package:get/get.dart';

import '../../data/local/local_storage.dart';

class HistoryController extends GetxController {
  final LocalStorage _localStorage;

  HistoryController(this._localStorage);

  final bets = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    final storedBets = _localStorage.getBets();

    storedBets.sort((a, b) {
      final first = DateTime.parse(a['createdAt'] as String);
      final second = DateTime.parse(b['createdAt'] as String);

      return second.compareTo(first);
    });

    bets.assignAll(storedBets);
  }
}
