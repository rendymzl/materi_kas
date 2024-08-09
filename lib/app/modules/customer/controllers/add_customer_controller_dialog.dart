import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/providers/customer_services.dart';

class AddCustomerController extends GetxController {
  final CustomerServices customerServices = Get.find();

  late final customers = customerServices.customers;
  late final foundCustomers = customerServices.foundCustomers;
  late final lastCustomersId = customerServices.lastCustomersId;

  final idController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  final clickedField = {
    'id': false,
    'name': false,
    'phone': false,
    'address': false,
  }.obs;

  String? nameValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['name'] == true) {
      return 'Nama tidak boleh kosong';
    } else if (value.length < 3 && clickedField['name'] == true) {
      return 'Nama harus di isi minimal 3 karakter';
    }
    return null;
  }

  String? idValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['id'] == true) {
      return 'ID tidak boleh kosong';
    }
    return null;
  }

  late String customerId;

  // Future<String> getCustomerId(String name, String? id) async {
  //   String initials = name.substring(0, 2).toUpperCase();
  //   debugPrint(id);
  //   if (id != null) {
  //     int lastNumber = int.tryParse(id.substring(id.length - 1)) ?? 0;
  //     String newId =
  //         id.substring(0, id.length - 1) + (lastNumber + 1).toString();
  //     debugPrint(newId);
  //     return newId;
  //   } else {
  //     return "${initials}1";
  //   }
  // }

  void bindingEditData(Customer foundCustomer) {
    int numberId = int.parse(lastCustomersId.substring(3));
    idController.text = foundCustomer.customerId ?? 'CST${numberId + 1}';
    nameController.text = foundCustomer.name ?? '';
    phoneController.text = foundCustomer.phone ?? '';
    addressController.text = foundCustomer.address ?? '';
  }

  //! update
  Future updateCustomer(
    Customer newCustomer,
    String curentid,
    Customer curentCustomer,
    Map<String, Map<String, dynamic>> customerData,
  ) async {
    customerServices.updateCustomer(newCustomer, curentCustomer);
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Customer berhasil diupdate',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
    Get.back();
  }

  // destroyHandle(Customer customer) async {
  //   Get.defaultDialog(
  //     title: 'Error',
  //     middleText: 'Hapus Customer ini?',
  //     confirm: TextButton(
  //       onPressed: () async {
  //         Get.back();
  //       },
  //       child: const Text('OK'),
  //     ),
  //     cancel: TextButton(
  //       onPressed: () => Get.back(),
  //       child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
  //     ),
  //   );
  // }

  Future handleSave(Customer? curentCustomer) async {
    clickedField['id'] = true;
    clickedField['name'] = true;
    debugPrint(curentCustomer?.customerId);
    // customerId =
    //     await getCustomerId(nameController.text, curentCustomer?.customerId);
    // debugPrint(customerId);
    if (formkey.currentState!.validate()) {
      final customer = Customer(
        customerId: idController.text,
        name: nameController.text,
        phone: phoneController.text,
        address: addressController.text,
        createdAt: Timestamp.now(),
      );
      Map<String, Map<String, dynamic>> customersMap = {};
      String newCustomerId = await customerServices.getId();
      customer.id = newCustomerId;
      customersMap[newCustomerId] = customer.toJson();
      curentCustomer != null
          ? await updateCustomer(
              customer, curentCustomer.id!, curentCustomer, customersMap)
          : addCustomer(customer, customersMap);
    }
  }

  //! create
  void addCustomer(
      Customer customer, Map<String, Map<String, dynamic>> customerData) async {
    bool isCustomerExists =
        customers.any((item) => item.customerId == customer.customerId);
    if (isCustomerExists) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'Kode yang dimasukkan sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } else {
      await customerServices.addCustomers(customerData);
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Customer berhasil ditambahkan',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
      Get.back();
    }
  }
}
