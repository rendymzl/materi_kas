import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/invoice_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/invoice_services.dart';
import '../../../data/providers/product_services.dart';
import '../../../widget/customer_input_field_controller.dart';
import '../../../widget/customer_input_field_widget.dart';
import '../../../widget/payment_card.dart';
import '../../../widget/payment_controller.dart';
import '../../invoice/views/invoice_print.dart';
import '../controllers/home_controller.dart';

void paymentStep(
  BuildContext context,
  Invoice invoice,
  List<Product> updatedProducts,
) {
  late ProductService productService = Get.find();
  late HomeController homeC = Get.find();
  late InvoiceService invoiceServices = Get.find();
  late CustomerInputFieldController customerInputFieldC = Get.find();
  late PaymentController paymentController = Get.put(PaymentController());

  customerInputFieldC.clear();
  paymentController.clear();

  // void saveInvoice(Invoice invoice) async {
  Future process() async {
    await customerInputFieldC.addCustomer(invoice);
    await paymentController.addPayment(invoice);
    Map<String, Map<String, dynamic>> invoicesMap = {};

    List<Product> updatedProductList = [];
    for (var stockP in updatedProducts) {
      final invProduct = invoice.purchaseList.value.items
          .firstWhereOrNull((inv) => inv.product.id == stockP.id);
      if (invProduct != null) {
        invProduct.product.updateStock(stockP.stock.value, null);
        updatedProductList.add(invProduct.product);
      }
    }

    Invoice printInvoice = Invoice.fromJson(invoice.toJson());
    String newInvioceId = await productService.getId();
    invoice.id = newInvioceId;
    invoicesMap[newInvioceId] = invoice.toJson();

    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      await invoiceServices.addInvoices(invoicesMap);

      if (updatedProducts.isNotEmpty) {
        await productService.updateMultipleProducts(updatedProductList);
        updatedProducts.clear();
      }
      Get.back();
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Invoice berhasil disimpan.',
        confirm: TextButton(
          onPressed: () {
            homeC.resetData();
            Get.back();
            Get.back();
            homeC.lastInvoice.value = invoice;
            // await Future.delayed(const Duration(milliseconds: 1000));
            // if (context.mounted) {

            // }
          },
          child: const Text('OK'),
        ),
      );

      await Get.defaultDialog(
        title: 'Print',
        middleText: 'Cetak invoice?',
        confirm: TextButton(
          onPressed: () async {
            debugPrint(printInvoice.purchaseList.value.items.length.toString());

            printInvoiceDialog(
              context,
              printInvoice,
            );
          },
          child: const Text('Cetak'),
        ),
        cancel: TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'Tidak',
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ),
      );
    } catch (e) {
      // Get.back();
      Get.defaultDialog(
        title: 'Gagal Menyimpan Invoice!',
        middleText: e.toString(),
        // barrierDismissible: false,
      );
    }
  }

  Future validate(String validateCode) async {
    Get.defaultDialog(
      title: 'Ups',
      middleText: validateCode == 'debt'
          ? 'Total tagihan belum terpenuhi. lanjutkan?'
          : 'Data Customer tidak lengkap. lanjutkan?',
      confirm: TextButton(
        onPressed: () async {
          await process();
          Get.back();
        },
        child: const Text('Simpan'),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text(
          'Batal',
          style: TextStyle(color: Colors.black.withOpacity(0.5)),
        ),
      ),
    );
  }

  void saveInvoice() {
    customerInputFieldC.validateCustomer() ? validate('Customer') : process();
    // debugPrint('wdwad');
  }
  // }

  Get.defaultDialog(
    title: 'Pembayaran',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (3 / 4),
      width: MediaQuery.of(context).size.width * (1 / 3),
      child: ListView(
        controller: paymentController.scrollC,
        children: [
          const CustomerInputFieldCard(),
          PaymentCard(
            invoice: invoice,
            onClick: () async {
              saveInvoice();
            },
          ),
        ],
      ),
    ),
  );
}
