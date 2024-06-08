import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../main.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/providers/customer_provider.dart';

class CustomerController extends GetxController {
  late final String uuid;
  late final List<Customer> customerList = <Customer>[].obs;

  final foundCustomers = <Customer>[].obs;

  @override
  void onInit() async {
    super.onInit();
    uuid = supabase.auth.currentUser!.id;
    List<Customer> newData = await CustomerProvider.fetchData(uuid);
    refreshFetch(newData);
  }

  void filterCustomers(String name) {
    var result = <Customer>[];
    name.isEmpty
        ? result = customerList
        : result = customerList
            .where((customer) =>
                customer.name.toString().toLowerCase().contains(name))
            .toList();

    foundCustomers.value = result;
  }

  //! Fetch
  void refreshFetch(List<Customer> newData) async {
    customerList.clear();
    customerList.assignAll(newData);
    foundCustomers.value = customerList;
  }

  //! create
  void addCustomer(Customer customer) async {
    bool isCustomerExists =
        customerList.any((item) => item.customerId == customer.customerId);
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
        List<Customer> newData = await CustomerProvider.create(customer);
        await Get.defaultDialog(
          title: 'Berhasil',
          middleText: 'Customer berhasil ditambahkan',
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
        refreshFetch(newData);
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
      Customer newCustomer, String curentid, String curentCustomerId) async {
    bool isCustomerIdExists =
        customerList.any((item) => item.customerId == newCustomer.customerId);
    if (isCustomerIdExists && newCustomer.customerId != curentCustomerId) {
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
        Map<String, Object?> data = {
          'name': newCustomer.name,
          'phone': newCustomer.phone,
          'address': newCustomer.address,
        };
        List<Customer> newData =
            await CustomerProvider.update(data, curentid, uuid);
        await Get.defaultDialog(
          title: 'Berhasil',
          middleText: 'Customer berhasil diupdate',
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
        refreshFetch(newData);
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

  //! delete
  destroyHandle(Customer customer) async {
    try {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Hapus Customer ini?',
        confirm: TextButton(
          onPressed: () async {
            List<Customer> newData = await CustomerProvider.destroy(customer);
            refreshFetch(newData);
            Get.back();
          },
          child: const Text('OK'),
        ),
        cancel: TextButton(
          onPressed: () => Get.back(),
          child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
        ),
      );
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

  final maxNameLenght = 0.obs;

  String? nameValidator(String value) {
    value = value.trim();
    if (value.length > maxNameLenght.value) maxNameLenght.value = value.length;
    if (value.isEmpty && clickedField['name'] == true) {
      return 'Nama tidak boleh kosong';
    } else if (value.length < 3 &&
        maxNameLenght >= 3 &&
        clickedField['name'] == true) {
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
        uuid: uuid,
      );
      curentCustomer != null
          ? await updateCustomer(
              customer, curentCustomer.id!, curentCustomer.customerId!)
          : addCustomer(customer);
    }
  }
}
