import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/cart_item_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/sales_invoice_model.dart';
import '../../../data/models/sales_model.dart';
import '../../../data/providers/sales_customer_services.dart';
import '../../../data/providers/sales_invoice_services.dart';

class SalesController extends GetxController {
  //! Front View
  late SalesCustomerServices salesCustomerSecvice = Get.find();
  late SalesInvoiceService salesInvoiceService = Get.find();

  late final foundSalesCustomer = salesCustomerSecvice.foundCustomers;

  Rx<Sales?> selectedSales = Rx<Sales?>(null);

  final salesTextC = TextEditingController();
  final showSuffixClear = false.obs;

  void filterSales(String salesName) {
    debugPrint(salesName);
    salesCustomerSecvice.searchCustomers(salesName);
  }

  void selectedSalesHandle(Sales sales) {
    selectedSales.value = sales;
    showSuffixClear.value = true;
    salesTextC.text = selectedSales.value!.name!;
    debugPrint(salesTextC.text);
  }

  destroySales(Sales sales) async {
    Get.defaultDialog(
      title: 'Error',
      middleText: 'Hapus Sales ini?',
      confirm: TextButton(
        onPressed: () async {
          await salesCustomerSecvice.deleteCustomer(sales.id!);
          // await salesCustomerServices.fetchCustomers();
          selectedSales.value = null;
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

  //! Invoice Sales
  late final salesInvoices = salesInvoiceService.invoices;
  final cart = Cart(items: <CartItem>[].obs).obs;

  destroyInvoice(SalesInvoice invoice) async {
    Get.defaultDialog(
      title: 'Error',
      middleText: 'Hapus Invoice ini?',
      confirm: TextButton(
        onPressed: () async {
          salesInvoiceService.deleteInvoice(invoice.id!);
          Get.back();
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

  // void asignEditData(SalesInvoice invoice) {
  //   showPaymentCard.value = false;

  //   DateTime invoiceDateTime = invoice.createdAt.value!.toDate();

  //   DateTime date = DateTime(
  //     invoiceDateTime.year,
  //     invoiceDateTime.month,
  //     invoiceDateTime.day,
  //     invoiceDateTime.hour,
  //     invoiceDateTime.minute,
  //   );

  //   selectedDate.value = date;
  //   displayDate.value =
  //       DateFormat('dd MMMM y', 'id').format(selectedDate.value);

  //   selectedTime.value = TimeOfDay.fromDateTime(date);
  //   displayTime.value = DateFormat('HH:mm', 'id').format(date);
  // }
}
