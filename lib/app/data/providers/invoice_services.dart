import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../widget/side_menu_controller.dart';
import '../models/invoice_model.dart';

class InvoiceService extends GetxController {
  late SideMenuController sideMenuC = Get.find();

  var invoices = <Invoice>[].obs;
  var foundInvoices = <Invoice>[].obs;

  Future<void> subscribe() async {
    final subs = await Invoice.subscribe(sideMenuC.store.value!.id!);
    subs.listen((updatedInvoices) {
      invoices.assignAll(updatedInvoices);
      searchInvoicesByName('');
    });
  }

  void searchInvoicesByName(String invoiceName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (invoiceName == '') {
        DateTime sevenDaysAgo =
            DateTime.now().subtract(const Duration(days: 7));

        List<Invoice> subList = invoices.where((invoice) {
          return invoice.createdAt.value!.isAfter(sevenDaysAgo);
        }).toList();
        List<Invoice> sortInvoice = sortByDate(subList);
        foundInvoices.clear();
        foundInvoices.addAll(sortInvoice);
      } else {
        List<Invoice> sortList = invoices.where((invoice) {
          return invoice.invoiceId!
                  .toLowerCase()
                  .contains(invoiceName.toLowerCase()) ||
              invoice.customer.value!.name!
                  .toLowerCase()
                  .contains(invoiceName.toLowerCase());
        }).toList();
        List<Invoice> sortInvoice = sortByDate(sortList);
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

  List<Invoice> sortByDate(List<Invoice> invoicesList) {
    invoicesList
        .sort((a, b) => b.createdAt.value!.compareTo(a.createdAt.value!));
    return invoicesList;
  }
}
