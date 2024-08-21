import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/customer_model.dart';
import '../data/models/invoice_model.dart';
// import '../data/providers/auth_services.dart';
import '../data/providers/customer_services.dart';

class CustomerInputFieldController extends GetxController {
  // final AuthService authService = Get.find();
  late CustomerServices customerServices = Get.find();
  late final customers = customerServices.customers;

  final displayName = ''.obs;
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();
  final showSuffixClear = false.obs;
  Rx<Customer?> selectedCustomer = Rx<Customer?>(null);

  void asignCustomer(Customer customer) {
    customerNameController.text = customer.name!;
    customerPhoneController.text = customer.phone!;
    customerAddressController.text = customer.address!;
    selectedCustomer.value = customer;
  }

  void updateSelectedCustomer(Customer customer) {
    customer.name = customerNameController.text;
    customer.phone = customerPhoneController.text;
    customer.address = customerAddressController.text;
    selectedCustomer.value = customer;
  }

  void clear() {
    showSuffixClear.value = false;
    displayName.value = '';
    customerNameController.text = '';
    customerPhoneController.text = '';
    customerAddressController.text = '';
    Customer customer = Customer(
        name: customerNameController.text,
        phone: customerPhoneController.text,
        address: customerAddressController.text);
    selectedCustomer.value = customer;
  }

  bool validateCustomer() {
    return customerNameController.text == '' ||
        customerPhoneController.text == '' ||
        customerAddressController.text == '';
  }

  Future addCustomer(Invoice invoice) async {
    invoice.customer.value = selectedCustomer.value;
  }
}
