import 'package:get/get.dart';
import '../../data/local/local_storage.dart';
import '../controllers/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryController>(
      () => HistoryController(Get.find<LocalStorage>()),
    );
  }
}
