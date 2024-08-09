import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/invoice_model.dart';
import '../data/providers/invoice_services.dart';
import 'payment_card.dart';
import 'payment_controller.dart';

void paymentDialogWidget(
    BuildContext context, Invoice invoice, VoidCallback onSuccess) {
  late InvoiceService invoiceServices = Get.find();
  late PaymentController paymentController = Get.put(PaymentController());

  paymentController.clear();

  // void savePayment(Invoice invoice) async {
  Future process() async {
    paymentController.addPayment(invoice);
    // Map<String, Map<String, dynamic>> invoicesMap = {};

    // invoicesMap[invoice.id!] = invoice.toJson();
    Get.defaultDialog(
      title: 'Memproses pembayaran',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      await invoiceServices.updateInvoice(invoice);
      Get.back();
      return Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Pembayaran berhasil disimpan.',
        confirm: TextButton(
          onPressed: onSuccess,
          child: const Text('OK'),
        ),
      );
    } catch (e) {
      Get.back();
      Get.defaultDialog(
        title: 'Gagal Melakukan Pembayaran',
        middleText: e.toString(),
        barrierDismissible: false,
      );
    }
  }

  Future warning() async {
    Get.defaultDialog(
      title: 'Ups',
      middleText: 'Total tagihan belum terpenuhi. lanjutkan?',
      confirm: TextButton(
        onPressed: () async {
          await process();
          Get.back();
        },
        child: const Text('Lanjutkan'),
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

  void savePayment() {
    int paymentInt =
        int.parse(paymentController.paymentTextC.text.replaceAll('.', ''));
    debugPrint(paymentInt.toString());
    paymentInt < invoice.debtAmount.value ? warning() : process();
  }

  Get.defaultDialog(
    title: 'Pembayaran',
    content: PaymentCard(
      invoice: invoice,
      onClick: () async {
        savePayment();
      },
    ),
  );
}
