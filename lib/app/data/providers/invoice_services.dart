import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/invoice_model.dart';
import 'auth_services.dart';

class InvoiceService extends GetxController {
  final AuthService authService = Get.find();
  final CollectionReference _invoicesCollection =
      FirebaseFirestore.instance.collection('invoices');

  var invoices = <Invoice>[].obs;
  var foundInvoices = <Invoice>[].obs;
  var recentInvoices = <Invoice>[].obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchProducts();
  // }

  Future<void> fetchInvoices() async {
    debugPrint(authService.uid.value);
    try {
      DocumentSnapshot docSnapshot =
          await _invoicesCollection.doc(authService.uid.value).get();
      if (docSnapshot.exists) {
        var invoiceData = docSnapshot.data() as Map<String, dynamic>;
        invoices.value = invoiceData.values
            .map((invoiceJson) => Invoice.fromJson(invoiceJson))
            .toList();
        searchInvoices('');
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

  Future<void> updateInvoice(Invoice newInvoice, Invoice currentInvoice) async {
    // debugPrint(currentProduct.id);
    if (currentInvoice.id == null) {
      debugPrint('Invoice ID is null');
      return;
    }

    try {
      await _invoicesCollection
          .doc(authService.uid.value)
          .update({currentInvoice.id!: newInvoice.toJson()});
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

  void searchInvoices(String invoiceId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (invoiceId.isEmpty) {
        List<Invoice> productsList = [];
        productsList.addAll(invoices);
        productsList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

        Timestamp sevenDaysAgo = Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 7)));
        recentInvoices.value = invoices.where((invoice) {
          return invoice.createdAt != null &&
              invoice.createdAt!.toDate().isAfter(sevenDaysAgo.toDate());
        }).toList();

        // List<Invoice> subList = productsList.take(50).toList();
        foundInvoices.clear();
        foundInvoices.addAll(recentInvoices);
      } else {
        foundInvoices.value = invoices.where((invoice) {
          return invoice.invoiceId!
              .toLowerCase()
              .contains(invoiceId.toLowerCase());
        }).toList();
      }
    });
  }
}
