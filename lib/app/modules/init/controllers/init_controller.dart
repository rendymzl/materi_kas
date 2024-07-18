// import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:materi_kas/app/data/providers/invoice_services.dart';

import '../../../data/providers/auth_services.dart';
import '../../../data/providers/customer_services.dart';
import '../../../data/providers/invoice_services.dart';
import '../../../data/providers/product_services.dart';
import '../../../routes/app_pages.dart';

class InitController extends GetxController {
  late AuthService authService = Get.find();
  late ProductService productService = Get.find();
  late InvoiceService invoiceService = Get.find();
  late CustomerServices customerServices = Get.find();
  final isLogin = false.obs;
  final loading = false.obs;
  // @override
  // void onInit() async {
  //   super.onInit();
  // debugPrint(productService.products.length.toString());
  // ever(authService.isLoggedIn, handleAuthChanged);
  // debugPrint(authService.isLoggedIn.value.toString());
  // }

  void handleAuthChanged() async {
    loading.value = true;
    await productService.fetchProducts();

    await invoiceService.fetchInvoices();
    await customerServices.fetchCustomers();
    if (authService.isLoggedIn.value) {
      Get.offNamed(Routes.HOME);
      // Get.defaultDialog(middleText: "login");
    } else {
      Get.offNamed(Routes.LOGIN);
      // Get.defaultDialog(middleText: "tidak login");
    }
    loading.value = false;
  }
}
