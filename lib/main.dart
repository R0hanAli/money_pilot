import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_pilot/core/services/connectivity_service.dart';
import 'package:money_pilot/core/services/notification_service.dart';
import 'package:money_pilot/core/services/sync_service.dart';
import 'package:money_pilot/core/theme/app_theme.dart';
import 'package:money_pilot/core/theme/theme_controller.dart';
import 'package:money_pilot/data/datasources/local_database.dart';
import 'package:money_pilot/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await Firebase.initializeApp();
  } catch (_) {}

  await LocalDatabase.instance.database;
  await NotificationService.instance.initialize();

  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
  Get.put<SyncService>(SyncService(), permanent: true);

  final themeController =
      Get.put<ThemeController>(ThemeController(), permanent: true);

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Money Pilot',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialRoute: AppPages.initial,
        getPages: AppPages.pages,
      ),
    );
  }
}
