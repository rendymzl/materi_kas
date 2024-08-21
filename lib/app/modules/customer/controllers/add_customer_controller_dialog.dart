import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/providers/customer_services.dart';
import '../../../widget/side_menu_controller.dart';

class AddCustomerController extends GetxController {
  late SideMenuController sideMenuC = Get.find();
  final CustomerServices customerService = Get.find();

  late final customers = customerService.customers;
  late final foundCustomers = customerService.foundCustomers;
  late final lastCustomersId = customerService.lastCustomersId;

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

  //! binding data
  void bindingEditData(Customer foundCustomer) {
    int numberId = int.parse(lastCustomersId.value.substring(3));
    debugPrint(numberId.toString());
    idController.text = foundCustomer.customerId ?? 'CST${numberId + 1}';
    nameController.text = foundCustomer.name ?? '';
    phoneController.text = foundCustomer.phone ?? '';
    addressController.text = foundCustomer.address ?? '';
  }

  //! create
  Future addCustomer(Customer customer) async {
    bool isCustomerExists =
        customers.any((item) => item.customerId == customer.customerId);
    if (isCustomerExists) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'ID Pelanggan sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } else {
      await Customer.insert(customer);
      await customerService.fetch();
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Pelanggan berhasil ditambahkan',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
      Get.back();
    }
  }

  //! update
  Future updateCustomer(
    Customer newCustomer,
    Customer currentCustomer,
  ) async {
    newCustomer.id = currentCustomer.id;
    await newCustomer.update();
    await customerService.fetch();
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Pelanggan berhasil diupdate',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
    Get.back();
  }

  //! delete
  // destroyHandle(Customer customer) async {
  //   Get.defaultDialog(
  //     title: 'Error',
  //     middleText: 'Hapus Customer ini?',
  //     confirm: TextButton(
  //       onPressed: () async {
  //         customer.delete();
  //         await customerService.fetch();
  //         // customerServices.deleteCustomer(customer.id!);
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

  //! handle save
  Future handleSave(Customer? curentCustomer) async {
    clickedField['id'] = true;
    clickedField['name'] = true;
    if (formkey.currentState!.validate()) {
      final customer = Customer(
          customerId: idController.text,
          createdAt: DateTime.now(),
          name: nameController.text,
          phone: phoneController.text,
          address: addressController.text,
          storeId: sideMenuC.store.value!.id);
      curentCustomer != null
          ? await updateCustomer(customer, curentCustomer)
          : await addCustomer(customer);
    }
  }
}
