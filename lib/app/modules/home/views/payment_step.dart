import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/invoice_model.dart';
import '../../../data/models/product_model.dart';
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
  late HomeController homeC = Get.find();
  late CustomerInputFieldController customerInputFieldC =
      Get.put(CustomerInputFieldController());
  late PaymentController paymentController = Get.put(PaymentController());

  customerInputFieldC.clear();
  paymentController.clear();

  Future process() async {
    await customerInputFieldC.addCustomer(invoice);
    invoice.invoiceId = await homeC.generateInvoiceId(invoice.customer.value!);
    // debugPrint(invoice.customer.value!.id!);
    await paymentController.addPayment(invoice);

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

    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      await Invoice.insert(invoice);

      if (updatedProducts.isNotEmpty) {
        for (var updatedProduct in updatedProductList) {
          await updatedProduct.update();
        }
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
          },
          child: const Text('OK'),
        ),
      );

      await Get.defaultDialog(
        title: 'Print',
        middleText: 'Cetak invoice?',
        confirm: TextButton(
          onPressed: () async {
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
      await Get.defaultDialog(
        title: 'Gagal Menyimpan Invoice!',
        middleText: e.toString(),
      );
      Get.back();
      Get.back();
    }
  }

  bool validateCustomer = false;
  bool validateTotal = false;
  void saveInvoice() async {
    if (customerInputFieldC.validateCustomer()) {
      await Get.defaultDialog(
        title: 'Ups',
        middleText: 'Data Customer tidak lengkap. lanjutkan?',
        confirm: TextButton(
          onPressed: () async {
            validateCustomer = true;
            Get.back();
          },
          child: const Text('Simpan'),
        ),
        cancel: TextButton(
          onPressed: () {
            Get.back();
            validateCustomer = false;
          },
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ),
      );
    } else {
      validateCustomer = true;
    }
    double pay = paymentController.paymentTextC.text == ''
        ? 0
        : double.parse(paymentController.paymentTextC.text.replaceAll('.', ''));
    if (validateCustomer & (pay < invoice.remainingDebt)) {
      await Get.defaultDialog(
        title: 'Ups',
        middleText: 'Total tagihan belum terpenuhi. lanjutkan?',
        confirm: TextButton(
          onPressed: () async {
            validateTotal = true;
            Get.back();
          },
          child: const Text('Simpan'),
        ),
        cancel: TextButton(
          onPressed: () {
            validateTotal = false;
            Get.back();
          },
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ),
      );
    } else {
      validateTotal = true;
    }
    if (validateCustomer & validateTotal) {
      process();
    }
  }

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
