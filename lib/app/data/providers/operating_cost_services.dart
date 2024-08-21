import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widget/side_menu_controller.dart';
import '../models/operating_costs_model.dart';
// import 'auth_services.dart';
// import 'stores_services.dart';

class OperatingCostServices extends GetxController {
  late SideMenuController sideMenuC = Get.find();

  var operatingCosts = <OperatingCost>[].obs;
  var fountOperatingCost = <OperatingCost>[].obs;

  @override
  void onInit() async {
    await fetch();
    super.onInit();
  }

  Future<void> fetch() async {
    final stream = await OperatingCost.subscribe(sideMenuC.store.value!.id!);
    stream.listen((updated) {
      operatingCosts.assignAll(updated);
      debugPrint('operatingcost: ${operatingCosts.length}');
      search('');
    });
  }

  void search(String operatingCostName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (operatingCostName.isEmpty) {
        List<OperatingCost> operatingCostList = [];
        operatingCostList.addAll(operatingCosts);
        operatingCostList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        List<OperatingCost> subList = operatingCostList.take(50).toList();
        fountOperatingCost.clear();
        fountOperatingCost.addAll(subList);
      } else {
        fountOperatingCost.value = operatingCosts.where((customer) {
          return customer.name!
              .toLowerCase()
              .contains(operatingCostName.toLowerCase());
        }).toList();
      }
    });
  }
}
