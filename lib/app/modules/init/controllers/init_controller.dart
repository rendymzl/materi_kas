import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/auth_services.dart';
import '../../../data/providers/product_services.dart';
import '../../../routes/app_pages.dart';

class InitController extends GetxController {
  late ProductService productService = Get.find();
  late AuthService authService = Get.find();
  final isLogin = false.obs;
  @override
  void onInit() async {
    super.onInit();
    // debugPrint(productService.products.length.toString());
    ever(authService.isLoggedIn, handleAuthChanged);
    // debugPrint(authService.isLoggedIn.value.toString());
  }

  void handleAuthChanged(bool isLoggedIn) async {
    if (authService.isLoggedIn.value) {
      await productService.fetchProducts();
      debugPrint(productService.products.length.toString());
      Get.toNamed(Routes.HOME);
    } else {
      Get.toNamed(Routes.LOGIN);
    }
  }
}
