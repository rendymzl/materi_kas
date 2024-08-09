import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../../../data/models/invoice_model.dart';
import '../../../data/models/sales_invoice_model.dart';
import '../../../data/providers/product_services.dart';
import '../../../data/providers/sales_invoice_services.dart';
// import '../../../widget/payment_card.dart';
// import '../../../widget/payment_controller.dart';
import '../../sales/controllers/sales_controller.dart';
import 'sales_payment_card.dart';
import 'sales_payment_controller.dart';

void salesPaymentDialog(BuildContext context, SalesInvoice invoice) {
  late ProductService productService = Get.find();
  late SalesController salesC = Get.find();
  late SalesInvoiceService salesInvoiceServices =
      Get.put(SalesInvoiceService());
  final SalesPaymentController paymentController =
      Get.put(SalesPaymentController());

  // final controller = stringC == 'homeC' ? homeC : salesC;

  paymentController.clear();

  // void saveInvoice(Invoice invoice) async {
  Future process() async {
    await paymentController.addPayment(invoice);
    Map<String, Map<String, dynamic>> invoicesMap = {};
    String newInvioceId = await productService.getId();
    invoice.id = newInvioceId;
    invoicesMap[newInvioceId] = invoice.toJson();
    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      await salesInvoiceServices.addInvoices(invoicesMap);
      Get.back();
      return Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Invoice berhasil disimpan.',
        confirm: TextButton(
          onPressed: () {
            // salesC.resetData();
            Get.back();
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    } catch (e) {
      Get.back();
      Get.defaultDialog(
        title: 'Gagal Menyimpan Invoice!',
        middleText: e.toString(),
        barrierDismissible: false,
      );
    }
  }

  // Future validate(String validateCode) async {
  //   Get.defaultDialog(
  //     title: 'Ups',
  //     middleText: validateCode == 'debt'
  //         ? 'Total tagihan belum terpenuhi. lanjutkan?'
  //         : 'Data Customer tidak lengkap. lanjutkan?',
  //     confirm: TextButton(
  //       onPressed: () async {
  //         await process();
  //         Get.back();
  //       },
  //       child: const Text('Simpan'),
  //     ),
  //     cancel: TextButton(
  //       onPressed: () {
  //         Get.back();
  //       },
  //       child: Text(
  //         'Batal',
  //         style: TextStyle(color: Colors.black.withOpacity(0.5)),
  //       ),
  //     ),
  //   );
  // }

  void saveInvoice() {
    process();
  }
  // }

  Get.defaultDialog(
    title: 'Pembayaran',
    content: SalesPaymentCard(
      invoice: invoice,
      onClick: () async {
        saveInvoice();
      },
    ),
  );
}
