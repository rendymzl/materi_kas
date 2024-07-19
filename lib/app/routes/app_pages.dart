import 'package:get/get.dart';

// import '../data/providers/auth_services.dart';
import '../modules/customer/bindings/customer_binding.dart';
import '../modules/customer/views/customer_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/init/bindings/init_binding.dart';
import '../modules/init/views/init_view.dart';
import '../modules/invoice/bindings/invoice_binding.dart';
import '../modules/invoice/views/invoice_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/product/bindings/product_binding.dart';
import '../modules/product/views/product_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/statistic/bindings/statistic_binding.dart';
import '../modules/statistic/views/statistic_view.dart';

// import 'package:firebase_auth/firebase_auth.dart';

// import '../../main.dart';
// import '../../main.dart';

part 'app_routes.dart';

// var init = supabase.auth.currentSession?.accessToken != null
//     ? Routes.HOME
//     : Routes.LOGIN;
// final AuthService authService = Get.put(AuthService());

// var init = authService.isLoggedIn.value ? Routes.HOME : Routes.LOGIN;

class AppPages {
  AppPages._();
  static final String INITIAL = Routes.INIT;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT,
      page: () => const ProductView(),
      binding: ProductBinding(),
    ),
    // GetPage(
    //   name: _Paths.INVOICE,
    //   page: () => const InvoiceView(),
    //   binding: InvoiceBinding(),
    // ),
    GetPage(
      name: _Paths.CUSTOMER,
      page: () => const CustomerView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    // GetPage(
    //   name: _Paths.STATISTIC,
    //   page: () => const StatisticView(),
    //   binding: StatisticBinding(),
    // ),
    GetPage(
      name: _Paths.INIT,
      page: () => const InitView(),
      binding: InitBinding(),
    ),
  ];
}
