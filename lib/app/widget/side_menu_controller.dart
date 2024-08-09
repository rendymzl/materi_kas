import 'package:get/get.dart';
import 'package:materi_kas/app/routes/app_pages.dart';

import '../data/providers/auth_services.dart';
import '../data/providers/stores_services.dart';

class SideMenuController extends GetxController {
  final AuthService authService = Get.find();
  late StoreServices storeService = Get.find();
  // late final isOwner = authService.isOwner;
  final isExpand = true.obs;
  final selectedIndex = 0.obs;

  late final isAdmin = storeService.isOwner;

  void toggleDrawer() {
    isExpand.value = !isExpand.value;
  }

  void handleClick(int index) {
    selectedIndex.value = index;
    switch (index) {
      case 0:
        Get.offNamed(Routes.HOME);
        break;
      case 1:
        Get.offNamed(Routes.INVOICE);
        break;
      case 2:
        Get.offNamed(Routes.CUSTOMER);
        break;
      case 3:
        Get.offNamed(Routes.PRODUCT);
        break;
      case 4:
        Get.offNamed(Routes.SALES);
        break;
      case 5:
        Get.offNamed(Routes.STATISTIC);
        break;
      default:
        Get.offNamed(Routes.PROFILE);
        break;
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
