import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widget/side_menu_controller.dart';
import '../models/customer_model.dart';

class CustomerServices extends GetxController {
  late SideMenuController sideMenuC = Get.find();

  var customers = <Customer>[].obs;
  var foundCustomers = <Customer>[].obs;
  var lastCustomersId = 'CST0'.obs;

  @override
  void onInit() async {
    await fetch();
    super.onInit();
  }

  Future<void> fetch() async {
    final customerStream = await Customer.subscribe(sideMenuC.store.value!.id!);
    customerStream.listen((updated) {
      customers.assignAll(updated);
      search('');
    });
  }

  void search(String searchValue) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchValue.isEmpty) {
        List<Customer> customersList = [];
        customersList.addAll(customers);
        customersList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        List<Customer> subList = customersList.take(50).toList();
        foundCustomers.clear();
        foundCustomers.addAll(subList);
        customersList.sort((a, b) {
          int aNumber = int.parse(a.customerId!.substring(3));
          int bNumber = int.parse(b.customerId!.substring(3));
          // debugPrint('a ${a.customerId!.substring(3)}');
          // debugPrint('b ${b.customerId!.substring(3)}');
          return aNumber.compareTo(bNumber);
        });
        // debugPrint('last ${customersList.last.customerId!}');
        lastCustomersId.value =
            customersList.isEmpty ? 'CST0' : customersList.last.customerId!;
      } else {
        foundCustomers.value = customers.where((customer) {
          return customer.name!
              .toLowerCase()
              .contains(searchValue.toLowerCase());
        }).toList();
      }
    });
  }
}
