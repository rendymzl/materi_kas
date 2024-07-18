import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/customer_model.dart';
import 'auth_services.dart';

class CustomerServices extends GetxController {
  final AuthService authService = Get.find();
  final CollectionReference _customersCollection =
      FirebaseFirestore.instance.collection('customers');

  var customers = <Customer>[].obs;
  var foundCustomers = <Customer>[].obs;

  Future<void> fetchCustomers() async {
    try {
      DocumentSnapshot docSnapshot =
          await _customersCollection.doc(authService.uid.value).get();
      if (docSnapshot.exists) {
        var customerData = docSnapshot.data() as Map<String, dynamic>;
        customers.value = customerData.values
            .map((customerJson) => Customer.fromJson(customerJson))
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
          _customersCollection.doc(authService.uid.value);
      await docRef.set(customersMap, SetOptions(merge: true));
      await fetchCustomers();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateCustomer(
      Customer newCustomer, Customer currentCustomer) async {
    if (currentCustomer.id == null) {
      debugPrint('Product ID is null');
      return;
    }

    try {
      await _customersCollection
          .doc(authService.uid.value)
          .update({currentCustomer.id!: newCustomer.toJson()});
      await fetchCustomers();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _customersCollection
          .doc(authService.uid.value)
          .update({customerId: FieldValue.delete()});
      customers.removeWhere((customer) => customer.id == customerId);
      foundCustomers.removeWhere((customer) => customer.id == customerId);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteAllCustomer() async {
    try {
      await _customersCollection.doc(authService.uid.value).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void searchCustomers(String customerName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (customerName.isEmpty) {
        List<Customer> customersList = [];
        customersList.addAll(customers);
        customersList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        List<Customer> subList = customersList.take(50).toList();
        foundCustomers.clear();
        foundCustomers.addAll(subList);
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
