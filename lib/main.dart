import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data/local/local_storage.dart';
import 'routes/app_bindings.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorage = LocalStorage();
  await localStorage.init();

  Get.put<LocalStorage>(localStorage, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lexavra Gaming',
      initialBinding: AppBindings(),
      initialRoute: AppPages.initial,
      theme: AppTheme.light(),
      getPages: AppPages.routes,
    );
  }
}
