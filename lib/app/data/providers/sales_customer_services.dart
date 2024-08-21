import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widget/side_menu_controller.dart';
import '../models/sales_model.dart';

class SalesCustomerServices extends GetxController {
  late SideMenuController sideMenuC = Get.find();

  var customers = <Sales>[].obs;
  var foundCustomers = <Sales>[].obs;
  var lastSalesId = 'SL0'.obs;

  @override
  void onInit() {
    fetch();
    super.onInit();
  }

  Future<void> fetch() async {
    final customerStream = await Sales.subscribe(sideMenuC.store.value!.id!);
    customerStream.listen((updatedSales) {
      customers.assignAll(updatedSales);
      search('');
    });
  }

  void search(String customerName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (customerName.isEmpty) {
        List<Sales> customersList = [];
        customersList.addAll(customers);
        customersList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        List<Sales> subList = customersList.take(50).toList();
        foundCustomers.clear();
        foundCustomers.addAll(subList);
        List<Sales> salesList = [];
        salesList.addAll(customers);
        salesList.sort((a, b) {
          int aNumber = int.parse(a.salesId!.substring(2));
          int bNumber = int.parse(b.salesId!.substring(2));
          // debugPrint('a ${a.customerId!.substring(3)}');
          // debugPrint('b ${b.customerId!.substring(3)}');
          return aNumber.compareTo(bNumber);
        });
        lastSalesId.value =
            customersList.isEmpty ? 'SL0' : salesList.last.salesId!;
        // debugPrint(lastSalesId.value);
      } else {
        foundCustomers.value = customers.where((customer) {
          return customer.name!
              .toLowerCase()
              .contains(customerName.toLowerCase());
        }).toList();
      }
    });
  }
  // Future<void> fetch() async {
  //   try {
  //     DocumentSnapshot docSnapshot = await _customersCollection
  //         .doc(storesService.account.value.accountId)
  //         .get();
  //     if (docSnapshot.exists) {
  //       var customerData = docSnapshot.data() as Map<String, dynamic>;
  //       customers.value = customerData.values
  //           .map((customerJson) => Sales.fromJson(customerJson))
  //           .toList();

  //       searchCustomers('');
  //     } else {
  //       customers.value = [];
  //       foundCustomers.value = [];
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // Future<String> getId() async {
  //   return _customersCollection.doc().id;
  // }

  // Future<void> addCustomers(
  //     Map<String, Map<String, dynamic>> customersMap) async {
  //   try {
  //     DocumentReference docRef =
  //         _customersCollection.doc(storesService.account.value.accountId);
  //     await docRef.set(customersMap, SetOptions(merge: true));
  //     await fetchCustomers();
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // Future<void> updateCustomer(Sales newCustomer, Sales currentCustomer) async {
  //   if (currentCustomer.id == null) {
  //     debugPrint('Product ID is null');
  //     return;
  //   }

  //   try {
  //     await _customersCollection
  //         .doc(storesService.account.value.accountId)
  //         .update({currentCustomer.id!: newCustomer.toJson()});
  //     await fetchCustomers();
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // Future<void> deleteCustomer(String id) async {
  //   try {
  //     await _customersCollection
  //         .doc(storesService.account.value.accountId)
  //         .update({id: FieldValue.delete()});
  //     customers.removeWhere((customer) => customer.id == id);
  //     foundCustomers.removeWhere((customer) => customer.id == id);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // Future<void> deleteAllCustomer() async {
  //   try {
  //     await _customersCollection
  //         .doc(storesService.account.value.accountId)
  //         .delete();
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }
}
