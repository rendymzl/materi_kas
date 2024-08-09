import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// import '../models/invoice_model.dart';
import '../models/sales_invoice_model.dart';
// import 'auth_services.dart';
import 'stores_services.dart';

class SalesInvoiceService extends GetxController {
  final StoreServices storesService = Get.find();
  final CollectionReference _invoicesCollection =
      FirebaseFirestore.instance.collection('sales_invoice');

  var invoices = <SalesInvoice>[].obs;
  var foundInvoices = <SalesInvoice>[].obs;

  Future<void> fetchInvoices() async {
    try {
      DocumentSnapshot docSnapshot = await _invoicesCollection
          .doc(storesService.account.value.ownerUid)
          .get();
      if (docSnapshot.exists) {
        var invoiceData = docSnapshot.data() as Map<String, dynamic>;
        invoices.value = invoiceData.values
            .map((invoiceJson) => SalesInvoice.fromJson(invoiceJson))
            .toList();
        searchInvoicesByName('');
      } else {
        invoices.value = [];
        foundInvoices.value = [];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String> getId() async {
    return _invoicesCollection.doc().id;
  }

  Future<void> addInvoices(
      Map<String, Map<String, dynamic>> invoicesMap) async {
    try {
      DocumentReference docRef =
          _invoicesCollection.doc(storesService.account.value.ownerUid);
      debugPrint('sebelum add');
      debugPrint(invoicesMap.toString());
      await docRef.set(invoicesMap, SetOptions(merge: true));
      debugPrint('sesudah add');
      await fetchInvoices();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateInvoice(SalesInvoice newInvoice) async {
    if (newInvoice.id == null) {
      debugPrint('Invoice ID is null');
      return;
    }

    try {
      await _invoicesCollection
          .doc(storesService.account.value.ownerUid)
          .update({newInvoice.id!: newInvoice.toJson()});
      await fetchInvoices();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _invoicesCollection
          .doc(storesService.account.value.ownerUid)
          .update({invoiceId: FieldValue.delete()});
      invoices.removeWhere((invoice) => invoice.id == invoiceId);
      foundInvoices.removeWhere((invoice) => invoice.id == invoiceId);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void searchInvoicesByName(String invoiceName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (invoiceName == '') {
        Timestamp sevenDaysAgo = Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 7)));

        List<SalesInvoice> subList = invoices.where((invoice) {
          return invoice.createdAt.value!
              .toDate()
              .isAfter(sevenDaysAgo.toDate());
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
          DateTime invoiceDate = invoice.createdAt.value!.toDate();
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
