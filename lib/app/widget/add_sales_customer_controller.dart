// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/sales_model.dart';
import '../data/providers/sales_customer_services.dart';
import '../modules/sales/controllers/sales_controller.dart';
import 'side_menu_controller.dart';

class AddSalesController extends GetxController {
  late SideMenuController sideMenuC = Get.find();
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

  //! binding data
  void bindingEditData(Sales foundCustomer) {
    int lastIdSalesNumber = int.parse(lastId.substring(2));
    idController.text = foundCustomer.salesId ?? 'SL${lastIdSalesNumber + 1}';
    nameController.text = foundCustomer.name ?? '';
    phoneController.text = foundCustomer.phone ?? '';
    addressController.text = foundCustomer.address ?? '';
  }

  //! create
  Future addCustomer(Sales salesCustomer) async {
    bool isCustomerExists =
        salesCustomers.any((item) => item.salesId == salesCustomer.salesId);
    if (isCustomerExists) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'ID Sales sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } else {
      await Sales.insert(salesCustomer);
      await salesCustomerServices.fetch();
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Sales berhasil ditambahkan',
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
    Sales newSalesCustomer,
    Sales curentSalesCustomer,
  ) async {
    newSalesCustomer.id = curentSalesCustomer.id;
    await newSalesCustomer.update();
    await salesCustomerServices.fetch();
    salesC.selectedSalesHandle(newSalesCustomer);
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Sales berhasil diupdate',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
    Get.back();
  }

  //! delete
  destroyHandle(Sales sales) async {
    Get.defaultDialog(
      title: 'Error',
      middleText: 'Hapus Sales ini?',
      confirm: TextButton(
        onPressed: () async {
          // await salesCustomerServices.deleteCustomer(sales.id!);
          sales.delete();
          await salesCustomerServices.fetch();
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

  //! handle save
  Future handleSave(Sales? curentCustomer) async {
    clickedField['id'] = true;
    clickedField['name'] = true;
    if (formkey.currentState!.validate()) {
      final customer = Sales(
        salesId: idController.text,
        name: nameController.text,
        phone: phoneController.text,
        address: addressController.text,
        storeId: sideMenuC.store.value!.id,
        createdAt: DateTime.now(),
      );
      curentCustomer != null
          ? await updateCustomer(customer, curentCustomer)
          : await addCustomer(customer);
    }
  }
}
