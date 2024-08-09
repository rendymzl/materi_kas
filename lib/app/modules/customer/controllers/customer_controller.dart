import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/providers/customer_services.dart';
import '../../../data/providers/stores_services.dart';

class CustomerController extends GetxController {
  late StoreServices storeService = Get.find();
  final CustomerServices customerServices = Get.find();

  late final customers = customerServices.customers;
  late final foundCustomers = customerServices.foundCustomers;
  late final isAdmin = storeService.isOwner;

  void filterCustomers(String customerName) {
    customerServices.searchCustomers(customerName);
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
      try {
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
      } on PostgrestException catch (e) {
        Get.defaultDialog(
          title: 'Error',
          middleText: e.message,
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    }
  }

  //! update
  Future updateCustomer(
    Customer newCustomer,
    String curentid,
    Customer curentCustomer,
    Map<String, Map<String, dynamic>> customerData,
  ) async {
    bool isCustomerIdExists =
        customers.any((item) => item.customerId == newCustomer.customerId);
    if (isCustomerIdExists && newCustomer.customerId != curentCustomer.id) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'Kode yang dimasukkan sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } else {
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
  }

  //! delete
  destroyHandle(Customer customer) async {
    Get.defaultDialog(
      title: 'Error',
      middleText: 'Hapus Customer ini?',
      confirm: TextButton(
        onPressed: () async {
          customerServices.deleteCustomer(customer.id!);
          Get.back();
        },
        child: const Text('OK'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  //! edit form
  final numberFormat = NumberFormat("#,##0", "id_ID");
  late String customerId;

  String getCustomerId(String name, String? id) {
    String initials = name.substring(0, 2).toUpperCase();

    if (id != null) {
      int lastNumber = int.tryParse(id.substring(id.length - 1)) ?? 0;
      String newId =
          id.substring(0, id.length - 1) + (lastNumber + 1).toString();
      return newId;
    } else {
      return "${initials}1";
    }
  }

  final formkey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  void bindingEditData(Customer foundCustomer) {
    nameController.text = foundCustomer.name!;
    phoneController.text = foundCustomer.phone!;
    addressController.text = foundCustomer.address!;
  }

  final clickedField = {
    'name': false,
    'phone': false,
    'address': false,
  }.obs;

  // final minNameLenght = 0.obs;

  String? nameValidator(String value) {
    value = value.trim();
    // if (value.length > minNameLenght.value) minNameLenght.value = value.length;
    if (value.isEmpty && clickedField['name'] == true) {
      return 'Nama tidak boleh kosong';
    } else if (value.length < 3 && clickedField['name'] == true) {
      return 'Nama harus di isi minimal 3 karakter';
    }
    return null;
  }

  Future handleSave(Customer? curentCustomer) async {
    clickedField['name'] = true;
    customerId = getCustomerId(nameController.text, curentCustomer?.customerId);
    if (formkey.currentState!.validate()) {
      final customer = Customer(
        customerId: customerId,
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
}
