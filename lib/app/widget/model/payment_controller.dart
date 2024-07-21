import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/invoice_model.dart';

// import '../data/models/customer_model.dart';
// import '../data/providers/auth_services.dart';
// import '../data/providers/customer_services.dart';

class PaymentController extends GetxController {
  // final AuthService authService = Get.find();
  // late CustomerServices customerServices = Get.find();

  // late final customers = customerServices.customers;

  final moneyChange = 0.obs;
  final currency = NumberFormat('#,##0', 'id_ID');
  final paymentMethod = ['cash', 'transfer'].obs;
  final selectedPaymentMethod = ''.obs;

  final paymentTextC = TextEditingController();

  void addPayment(Invoice invoice) {
    invoice.addPayment(
      int.parse(paymentTextC.text),
      method: selectedPaymentMethod.value,
      date: Timestamp.now(),
    );
  }
  // Rx<Customer?> selectedCustomer = Rx<Customer?>(null);

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    // debugPrint(selectedPaymentMethod.value);
  }

  void asignPayment() {
    // customerInputFieldC.resetCustomerField();
    selectedPaymentMethod.value = '';
  }

  void onPayChanged(String value) {
    if (value.isNotEmpty) {
      String newValue = currency.format(int.parse(value.replaceAll('.', '')));
      if (newValue != paymentTextC.text) {
        paymentTextC.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }

    // if (debounce?.isActive ?? false) debounce!.cancel();
    // debounce = Timer(const Duration(milliseconds: 500), () {
    moneyChange.value = value == '' ? 0 : int.parse(value.replaceAll('.', ''));
    // });
  }
}
