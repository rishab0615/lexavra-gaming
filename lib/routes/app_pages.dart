import 'package:get/get.dart';

import '../presentation/bindings/dice_binding.dart';
import '../presentation/bindings/history_binding.dart';
import '../presentation/bindings/home_binding.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/dice/dice_page.dart';
import '../presentation/pages/history/history_page.dart';
import '../presentation/pages/splash/splash_page.dart';

class AppPages {
  static const initial = '/splash';

  static final routes = [
    GetPage(name: '/splash', page: () => const SplashPage()),
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(
      name: '/home',
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: '/dice',
      page: () => const DicePage(),
      binding: DiceBinding(),
    ),
    GetPage(
      name: '/history',
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
    ),
  ];
}
