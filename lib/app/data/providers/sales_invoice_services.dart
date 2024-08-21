import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../widget/side_menu_controller.dart';
import '../models/sales_invoice_model.dart';

class SalesInvoiceService extends GetxController {
  late SideMenuController sideMenuC = Get.find();

  var invoices = <SalesInvoice>[].obs;
  var foundInvoices = <SalesInvoice>[].obs;

  @override
  void onInit() async {
    await subscribe();
    super.onInit();
  }

  Future<void> subscribe() async {
    final subs = await SalesInvoice.subscribe(sideMenuC.store.value!.id!);
    subs.listen((updatedInvoices) {
      invoices.assignAll(updatedInvoices);
      // debugPrint('awdawdw ${updatedInvoices.length}');
      searchInvoicesByName('');
    });
  }

  void searchInvoicesByName(String invoiceName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (invoiceName == '') {
        DateTime sevenDaysAgo =
            DateTime.now().subtract(const Duration(days: 7));

        List<SalesInvoice> subList = invoices.where((invoice) {
          return invoice.createdAt.value!.isAfter(sevenDaysAgo);
        }).toList();
        List<SalesInvoice> sortInvoice = sortByDate(subList);
        foundInvoices.clear();
        foundInvoices.addAll(sortInvoice);
      } else {
        List<SalesInvoice> sortList = invoices.where((invoice) {
          return invoice.invoiceId!
              .toLowerCase()
              .contains(invoiceName.toLowerCase());
        }).toList();
        List<SalesInvoice> sortInvoice = sortByDate(sortList);
        foundInvoices.clear();
        foundInvoices.addAll(sortInvoice);
      }
    });
  }

  void searchInvoicesByPickerDateRange(PickerDateRange? invoiceCreatedAt) {
    if (invoiceCreatedAt != null) {
      foundInvoices.clear();
      foundInvoices.value = invoices.where((invoice) {
        if (invoice.createdAt.value != null) {
          DateTime invoiceDate = invoice.createdAt.value!;
          return invoiceDate.isAfter(invoiceCreatedAt.startDate!) &&
              invoiceDate.isBefore(invoiceCreatedAt.endDate!);
        }
        return false;
      }).toList();
    } else {
      searchInvoicesByName('');
    }
    // });
  }

  List<SalesInvoice> sortByDate(List<SalesInvoice> invoicesList) {
    invoicesList
        .sort((a, b) => b.createdAt.value!.compareTo(a.createdAt.value!));
    return invoicesList;
  }
}
