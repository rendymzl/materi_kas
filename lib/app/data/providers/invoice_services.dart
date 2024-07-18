import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../models/invoice_model.dart';
import 'auth_services.dart';

class InvoiceService extends GetxController {
  final AuthService authService = Get.find();
  final CollectionReference _invoicesCollection =
      FirebaseFirestore.instance.collection('invoices');

  var invoices = <Invoice>[].obs;
  var foundInvoices = <Invoice>[].obs;
  // var recentInvoices = <Invoice>[].obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchProducts();
  // }

  Future<void> fetchInvoices() async {
    try {
      DocumentSnapshot docSnapshot =
          await _invoicesCollection.doc(authService.uid.value).get();
      if (docSnapshot.exists) {
        var invoiceData = docSnapshot.data() as Map<String, dynamic>;
        invoices.value = invoiceData.values
            .map((invoiceJson) => Invoice.fromJson(invoiceJson))
            .toList();
        searchInvoicesByName('');
      } else {
        // Handle case where the document does not exist
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

  // Future<void> addProducts(Map<String?, Map<String, dynamic>> data,
  //     List<Product> productsList) async {
  //   try {
  //     DocumentReference docRef = _invoicesCollection.doc(authService.uid.value);
  //     // product.id = await getId();
  //     // product.createdAt = Timestamp.now();
  //     await docRef.set(data, SetOptions(merge: true));
  //     products.addAll(productsList);
  //     // foundProducts.add(product);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // Future<void> addProducts(List<Product> productsList) async {
  //   List<List<Product>> productChunks = _chunkProducts(productsList, 500);

  //   for (List<Product> chunk in productChunks) {
  //     WriteBatch batch = FirebaseFirestore.instance.batch();
  //     DocumentReference userDocRef =
  //         _invoicesCollection.doc(authService.uid.value);

  //     for (Product product in chunk) {
  //       String newProductId = _invoicesCollection.doc().id;
  //       product.id = newProductId;
  //       product.createdAt = Timestamp.now();
  //       batch.set(userDocRef, {newProductId: product.toJson()},
  //           SetOptions(merge: true));
  //     }

  //     try {
  //       debugPrint(chunk.length.toString());
  //       await batch.commit();
  //       debugPrint("commited");
  //       // products.addAll(productsList);
  //       // foundProducts.addAll(productsList);
  //       await fetchProducts();
  //     } catch (e) {
  //       debugPrint(e.toString());
  //     }
  //   }
  // }

  Future<void> addInvoices(
      Map<String, Map<String, dynamic>> invoicesMap) async {
    // List<List<Product>> productChunks = _chunkProducts(productsList, 500);
    try {
      DocumentReference docRef = _invoicesCollection.doc(authService.uid.value);
      // var invoiceId = await getId();
      // invoice.id = invoiceId;
      // invoice.customer = invoice.customer as Map<String, dynamic>;
      debugPrint('sebelum add');
      debugPrint(invoicesMap.toString());
      await docRef.set(invoicesMap, SetOptions(merge: true));
      debugPrint('sesudah add');
      // await docRef.set({invoice.id: invoice.toJson()}, SetOptions(merge: true));
      // products.addAll(productsList);
      // foundProducts.addAll(productsList);
      await fetchInvoices();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // List<List<Product>> _chunkProducts(List<Product> products, int chunkSize) {
  //   List<List<Product>> chunks = [];
  //   for (var i = 0; i < products.length; i += chunkSize) {
  //     chunks.add(products.sublist(i,
  //         i + chunkSize > products.length ? products.length : i + chunkSize));
  //   }
  //   return chunks;
  // }

  Future<void> updateInvoice(Invoice newInvoice) async {
    // debugPrint(currentProduct.id);
    if (newInvoice.id == null) {
      debugPrint('Invoice ID is null');
      return;
    }

    try {
      await _invoicesCollection
          .doc(authService.uid.value)
          .update({newInvoice.id!: newInvoice.toJson()});
      await fetchInvoices();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _invoicesCollection
          .doc(authService.uid.value)
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
        // invoicesList.addAll(invoices);

        Timestamp sevenDaysAgo = Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 7)));

        List<Invoice> subList = invoices.where((invoice) {
          return invoice.createdAt != null &&
              invoice.createdAt!.toDate().isAfter(sevenDaysAgo.toDate());
        }).toList();
        List<Invoice> sortInvoice = sortByDate(subList);
        // List<Invoice> subList = productsList.take(50).toList();
        foundInvoices.clear();
        foundInvoices.addAll(sortInvoice);
      } else {
        List<Invoice> sortList = invoices.where((invoice) {
          return invoice.invoiceId!
              .toLowerCase()
              .contains(invoiceName.toLowerCase());
        }).toList();
        List<Invoice> sortInvoice = sortByDate(sortList);
        foundInvoices.addAll(sortInvoice);
      }
    });
  }

  void searchInvoicesByPickerDateRange(PickerDateRange? invoiceCreatedAt) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // debugPrint(invoiceCreatedAt.toString());
    // debugPrint('invoice DateTime $invoiceCreatedAt');
    if (invoiceCreatedAt != null) {
      // final formattedStartDate = DateFormat('yyyy-MM-dd HH:mm:ss')
      //     .format(invoiceCreatedAt.startDate!);
      // final formattedEndDate =
      //     DateFormat('yyyy-MM-dd HH:mm:ss').format(invoiceCreatedAt.endDate!);
      foundInvoices.clear();
      foundInvoices.value = invoices.where((invoice) {
        if (invoice.createdAt != null) {
          DateTime invoiceDate = invoice.createdAt!.toDate();
          return invoiceDate.isAfter(invoiceCreatedAt.startDate!) &&
              invoiceDate.isBefore(invoiceCreatedAt.endDate!);
        }
        return false;
      }).toList();
      // sortByDate();
    } else {
      searchInvoicesByName('');
    }
    // });
  }

  List<Invoice> sortByDate(List<Invoice> invoicesList) {
    invoicesList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return invoicesList;
  }
}
