import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/sales_model.dart';
import '../data/providers/sales_customer_services.dart';
import '../modules/sales/controllers/sales_controller.dart';

class AddSalesController extends GetxController {
  final SalesCustomerServices salesCustomerServices = Get.find();
  final SalesController salesC = Get.put(SalesController());

  late final salesCustomers = salesCustomerServices.customers;
  late final foundSalesCustomers = salesCustomerServices.foundCustomers;
  late final lastId = salesCustomerServices.lastSalesId;

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

  String? idValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['id'] == true) {
      return 'ID tidak boleh kosong';
    }
    return null;
  }

  String? nameValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['name'] == true) {
      return 'Nama tidak boleh kosong';
    } else if (value.length < 3 && clickedField['name'] == true) {
      return 'Nama harus di isi minimal 3 karakter';
    }
    return null;
  }

  late String salesId;

  // String getSalesId(String name, String? id) {
  //   String initials = name.substring(0, 2).toUpperCase();

  //   if (id != null) {
  //     int lastNumber = int.tryParse(id.substring(id.length - 1)) ?? 0;
  //     String newId =
  //         id.substring(0, id.length - 1) + (lastNumber + 1).toString();
  //     return newId;
  //   } else {
  //     return "${initials}1";
  //   }
  // }

  void bindingEditData(Sales foundCustomer) {
    int lastIdSalesNumber = int.parse(lastId.substring(2));
    idController.text = foundCustomer.salesId ?? 'SL${lastIdSalesNumber + 1}';
    nameController.text = foundCustomer.name ?? '';
    phoneController.text = foundCustomer.phone ?? '';
    addressController.text = foundCustomer.address ?? '';
  }

  destroyHandle(Sales sales) async {
    Get.defaultDialog(
      title: 'Error',
      middleText: 'Hapus Sales ini?',
      confirm: TextButton(
        onPressed: () async {
          await salesCustomerServices.deleteCustomer(sales.id!);
          await salesCustomerServices.fetchCustomers();
          salesC.selectedSales.value = null;
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

  //! update
  Future updateCustomer(
    Sales newSalesCustomer,
    String curentid,
    Sales curentSalesCustomer,
    Map<String, Map<String, dynamic>> customerData,
  ) async {
    salesCustomerServices.updateCustomer(newSalesCustomer, curentSalesCustomer);
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

  Future handleSave(Sales? curentCustomer) async {
    clickedField['id'] = true;
    clickedField['name'] = true;
    // salesId = getSalesId(nameController.text, curentCustomer?.salesId);
    if (formkey.currentState!.validate()) {
      final customer = Sales(
        salesId: idController.text,
        name: nameController.text,
        phone: phoneController.text,
        address: addressController.text,
        createdAt: Timestamp.now(),
      );
      Map<String, Map<String, dynamic>> customersMap = {};
      String newCustomerId = await salesCustomerServices.getId();
      customer.id = newCustomerId;
      customersMap[newCustomerId] = customer.toJson();
      curentCustomer != null
          ? await updateCustomer(
              customer, curentCustomer.id!, curentCustomer, customersMap)
          : addCustomer(customer, customersMap);
    }
  }

  //! create
  void addCustomer(Sales salesCustomer,
      Map<String, Map<String, dynamic>> customerData) async {
    bool isCustomerExists =
        salesCustomers.any((item) => item.salesId == salesCustomer.salesId);
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
      await salesCustomerServices.addCustomers(customerData);
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
