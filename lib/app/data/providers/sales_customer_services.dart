import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../models/customer_model.dart';
import '../models/sales_model.dart';
// import 'auth_services.dart';
import 'stores_services.dart';

class SalesCustomerServices extends GetxController {
  final StoreServices storesService = Get.find();
  final CollectionReference _customersCollection =
      FirebaseFirestore.instance.collection('sales_customer');

  var customers = <Sales>[].obs;
  var foundCustomers = <Sales>[].obs;
  var lastSalesId = 'SL0'.obs;

  Future<void> fetchCustomers() async {
    try {
      DocumentSnapshot docSnapshot = await _customersCollection
          .doc(storesService.account.value.ownerUid)
          .get();
      if (docSnapshot.exists) {
        var customerData = docSnapshot.data() as Map<String, dynamic>;
        customers.value = customerData.values
            .map((customerJson) => Sales.fromJson(customerJson))
            .toList();

        searchCustomers('');
      } else {
        customers.value = [];
        foundCustomers.value = [];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String> getId() async {
    return _customersCollection.doc().id;
  }

  Future<void> addCustomers(
      Map<String, Map<String, dynamic>> customersMap) async {
    try {
      DocumentReference docRef =
          _customersCollection.doc(storesService.account.value.ownerUid);
      await docRef.set(customersMap, SetOptions(merge: true));
      await fetchCustomers();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateCustomer(Sales newCustomer, Sales currentCustomer) async {
    if (currentCustomer.id == null) {
      debugPrint('Product ID is null');
      return;
    }

    try {
      await _customersCollection
          .doc(storesService.account.value.ownerUid)
          .update({currentCustomer.id!: newCustomer.toJson()});
      await fetchCustomers();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _customersCollection
          .doc(storesService.account.value.ownerUid)
          .update({id: FieldValue.delete()});
      customers.removeWhere((customer) => customer.id == id);
      foundCustomers.removeWhere((customer) => customer.id == id);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteAllCustomer() async {
    try {
      await _customersCollection
          .doc(storesService.account.value.ownerUid)
          .delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void searchCustomers(String customerName) {
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
        salesList.sort((a, b) => a.salesId!.compareTo(b.salesId!));
        lastSalesId.value = salesList[customers.length - 1].salesId!;
        debugPrint(lastSalesId.value);
      } else {
        foundCustomers.value = customers.where((customer) {
          return customer.name!
              .toLowerCase()
              .contains(customerName.toLowerCase());
        }).toList();
      }
    });
  }
}
