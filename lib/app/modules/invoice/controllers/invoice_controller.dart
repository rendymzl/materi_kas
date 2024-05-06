import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../main.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/providers/invoice_provider.dart';

class InvoiceController extends GetxController {
  late final String uuid;
  late final List<Invoice> invoiceList = <Invoice>[].obs;
  final foundInvoices = <Invoice>[].obs;

  @override
  void onInit() async {
    super.onInit();
    uuid = supabase.auth.currentUser!.id;
    List<Invoice> newData = await InvoiceProvider.fetchData(uuid);
    refreshFetch(newData);
  }

  //! Fetch
  void refreshFetch(List<Invoice> newData) async {
    invoiceList.clear();
    invoiceList.assignAll(newData);
    foundInvoices.value = invoiceList;
  }

  // void filterProducts(String productName) {
  //   var result = <Invoice>[];
  //   productName.isEmpty
  //       ? result = invoiceList
  //       : result = invoiceList
  //           .where((invoice) => invoice.productsCart!.cartList
  //               .toString()
  //               .toLowerCase()
  //               .contains(productName))
  //           .toList();

  //   foundProducts.value = result;
  // }

  // void filterProducts(String productName) {
  //   var result = <Invoice>[];
  //   productName.isEmpty
  //       ? result = invoiceList
  //       : result = invoiceList
  //           .where((product) => product.productName
  //               .toString()
  //               .toLowerCase()
  //               .contains(productName))
  //           .toList();

  //   foundProducts.value = result;
  // }

  destroyHandle(Invoice invoice) async {
    try {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Hapus Invoice ini?',
        confirm: TextButton(
          onPressed: () async {
            refreshFetch(await InvoiceProvider.destroy(invoice));
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
}
