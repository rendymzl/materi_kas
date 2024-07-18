import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:materi_kas/app/data/providers/invoice_services.dart';
import 'package:materi_kas/app/utils/theme/theme.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/data/providers/auth_services.dart';
import 'app/data/providers/customer_services.dart';
import 'app/data/providers/product_services.dart';
import 'app/widget/customer_input_field_controller.dart';
import 'app/widget/side_menu_controller.dart';
import 'firebase_options.dart';
// import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// import 'app/data/providers/powersync_provider.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(AuthService(), permanent: true);
  Get.put(SideMenuController(), permanent: true);
  Get.put(ProductService(), permanent: true);
  Get.put(InvoiceService(), permanent: true);
  Get.put(CustomerServices(), permanent: true);
  Get.put(CustomerInputFieldController(), permanent: true);
  // await openDatabase();
  // WidgetsFlutterBinding.ensureInitialized();
  // await windowManager.ensureInitialized();

  // WindowOptions windowOptions = const WindowOptions(
  //   // size: Size(800, 600),
  //   minimumSize: Size(800, 600),
  //   center: true,
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: true,
  //   titleBarStyle: TitleBarStyle.hidden,
  //   windowButtonVisibility: true,
  // );
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });
  runApp(
    GetMaterialApp(
      title: "Application",
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('id'),
      ],
      themeMode: ThemeMode.light,
      theme: MAppTheme.lightTheme,
      darkTheme: MAppTheme.darkTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.noTransition,
      debugShowCheckedModeBanner: false,
    ),
  );
}

// final supabase = Supabase.instance.client;
final db = FirebaseFirestore.instance;
// final currentUser = FirebaseAuth.instance.currentUser;
