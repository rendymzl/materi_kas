// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../routes/app_pages.dart';
import '../../../widget/side_menu_controller.dart';

class InitController extends GetxController {
  late SideMenuController sideMenuC =
      Get.put(SideMenuController(), permanent: true);

  late final isLoading = true.obs;

  @override
  void onInit() async {
    // signOut();
    await handleInit();
    isLoading.value = false;
    super.onInit();
  }

  Future<void> handleInit() async {
    await sideMenuC.handleInit();
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    Get.offNamed(Routes.LOGIN);
  }
}
