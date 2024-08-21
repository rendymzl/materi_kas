// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
// import 'package:materi_kas/app/data/providers/invoice_services.dart';
// import 'package:materi_kas/app/modules/init/controllers/init_controller.dart';
// import 'package:materi_kas/app/modules/register/controllers/register_controller.dart';
// import 'package:materi_kas/app/modules/setup/controllers/setup_controller.dart';
import 'package:materi_kas/app/utils/theme/theme.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'app/data/providers/auth_services.dart';
// import 'app/data/providers/customer_services.dart';
// import 'app/data/providers/operating_cost_services.dart';
// import 'app/data/providers/product_services.dart';
// import 'app/data/providers/sales_customer_services.dart';
// import 'app/data/providers/sales_invoice_services.dart';
// import 'app/data/providers/stores_services.dart';
// import 'app/modules/product/views/buy_product_controller.dart';
// import 'app/modules/sales/controllers/sales_controller.dart';
// import 'app/modules/sales/views/sales_payment_controller.dart';
// import 'app/widget/customer_input_field_controller.dart';
// import 'app/widget/payment_controller.dart';
// import 'app/widget/side_menu_controller.dart';
// import 'app/widget/side_menu_controller.dart';
// import 'firebase_options.dart';
// import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// import 'app/data/providers/powersync_provider.dart';
import 'app/routes/app_pages.dart';
import 'powersync.dart';
import 'supabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // FirebaseFirestore.instance.settings =
  //     const Settings(persistenceEnabled: false);

  // await GetStorage.init();
  // Get.put(InitController(), permanent: true);
  // Get.put(AuthService(), permanent: true);
  // Get.put(SideMenuController(), permanent: true);
  // Get.put(StoreServices(), permanent: true);
  // Get.put(ProductService(), permanent: true);
  // Get.put(InvoiceService(), permanent: true);
  // Get.put(CustomerServices(), permanent: true);
  // Get.put(SalesInvoiceService(), permanent: true);
  // Get.put(SalesCustomerServices(), permanent: true);
  // Get.put(OperatingCostServices(), permanent: true);

  // Get.put(SetupController(), permanent: true);
  // Get.put(RegisterController(), permanent: true);
  // Get.put(SalesController(), permanent: true);
  // Get.put(CustomerInputFieldController(), permanent: true);
  // Get.put(PaymentController(), permanent: true);
  // Get.put(SalesPaymentController(), permanent: true);

  // Get.put(DatePickerController(), permanent: true);
  // Get.lazyPut(DatePickerController(), permanent: true);
  // await loadSupabase();
  await openDatabase();
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

// final db = FirebaseFirestore.instance;
final currency = NumberFormat('#,##0', 'id_ID');
final decimal = NumberFormat.decimalPattern('id');
