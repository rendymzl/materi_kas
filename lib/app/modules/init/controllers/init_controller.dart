// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:materi_kas/app/data/providers/invoice_services.dart';

import '../../../data/providers/auth_services.dart';
import '../../../data/providers/customer_services.dart';
import '../../../data/providers/invoice_services.dart';
import '../../../data/providers/operating_cost_services.dart';
import '../../../data/providers/product_services.dart';
import '../../../data/providers/sales_customer_services.dart';
import '../../../data/providers/sales_invoice_services.dart';
import '../../../data/providers/stores_services.dart';
import '../../../routes/app_pages.dart';

class InitController extends GetxController {
  late StoreServices storeService = Get.find();

  late AuthService authService = Get.find();
  late ProductService productService = Get.find();
  late InvoiceService invoiceService = Get.find();
  late SalesInvoiceService salesInvoiceService = Get.find();
  late CustomerServices customerServices = Get.find();
  late SalesCustomerServices salesCustomerServices = Get.find();
  late OperatingCostServices operatingCostServices = Get.find();
  final isLogin = false.obs;
  final loading = false.obs;

  void handleAuthChanged() async {
    loading.value = true;

    if (authService.isLoggedIn.value) {
      await storeService.fetchStore();

      await productService.fetchProducts();
      await invoiceService.fetchInvoices();
      await salesCustomerServices.fetchCustomers();
      await customerServices.fetchCustomers();
      await salesInvoiceService.fetchInvoices();
      // await salesInvoiceService.fetchInvoices();
      await operatingCostServices.fetchOperatingCost();
      await Future.delayed(const Duration(seconds: 1));
      loading.value = false;
      Get.offNamed(Routes.HOME);
      // Get.defaultDialog(middleText: "login");
    } else {
      loading.value = false;
      Get.offNamed(Routes.LOGIN);
      // Get.defaultDialog(middleText: "tidak login");
    }
  }

  // Future<void> checkAccount() async {
  //   await authService.signOut();
  //   Get.offNamed(Routes.LOGIN);
  // }

  Future<void> signOut() async {
    await authService.signOut();
    Get.offNamed(Routes.LOGIN);
  }
}
