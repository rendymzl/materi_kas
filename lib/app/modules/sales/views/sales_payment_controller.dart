import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../main.dart';
import '../../../data/models/sales_invoice_model.dart';

// import '../data/models/invoice_model.dart';

// import '../data/models/customer_model.dart';
// import '../data/providers/auth_services.dart';
// import '../data/providers/customer_services.dart';

class SalesPaymentController extends GetxController {
  // final AuthService authService = Get.find();
  // late CustomerServices customerServices = Get.find();

  // late final customers = customerServices.customers;

  final paymentMethod = ['cash', 'transfer'].obs;
  final selectedPaymentMethod = ''.obs;
  final moneyChange = 0.0.obs;

  final paymentTextC = TextEditingController();

  final scrollC = ScrollController();
  final textFocusNode = FocusNode();

  // final status = ''.obs;
  Future addPayment(SalesInvoice invoice) async {
    if (paymentTextC.text != '') {
      invoice.addPayment(
        double.parse(paymentTextC.text.replaceAll('.', '')),
        method: selectedPaymentMethod.value,
        date: DateTime.now(),
      );
    }
  }
  // Rx<Customer?> selectedCustomer = Rx<Customer?>(null);

  void setPaymentMethod(String method) async {
    selectedPaymentMethod.value = method;
    textFocusNode.requestFocus();
    await Future.delayed(const Duration(milliseconds: 50), () async {
      if (scrollC.hasClients) {
        await scrollC.animateTo(
          scrollC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void clear() {
    selectedPaymentMethod.value = '';
    paymentTextC.text = '';
    moneyChange.value = 0;
  }

  void onPayChanged(SalesInvoice invoice, String value) {
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
    double valueInt = value == '' ? 0 : double.parse(value.replaceAll('.', ''));
    moneyChange.value = invoice.remainingDebt - valueInt;
    // });
  }
}
