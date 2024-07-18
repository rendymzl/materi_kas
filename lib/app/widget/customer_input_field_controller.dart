import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/customer_model.dart';
import '../data/providers/auth_services.dart';
import '../data/providers/customer_services.dart';

class CustomerInputFieldController extends GetxController {
  final AuthService authService = Get.find();
  late CustomerServices customerServices = Get.find();
  late final customers = customerServices.customers;

  final displayName = ''.obs;
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();
  Rx<Customer?> selectedCustomer = Rx<Customer?>(null);

  void asignCustomer(Customer customer) {
    displayName.value = customer.name!;
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

  void resetCustomerField() {
    displayName.value = '';
    customerNameController.text = '';
    customerPhoneController.text = '';
    customerAddressController.text = '';
  }
}
