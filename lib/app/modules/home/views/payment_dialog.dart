import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/invoice_model.dart';
import '../../../data/providers/invoice_services.dart';
import '../../../data/providers/product_services.dart';
import '../../../widget/customer_input_field_controller.dart';
import '../../../widget/customer_input_field_widget.dart';
import '../../../widget/model/payment_card.dart';
import '../../../widget/model/payment_controller.dart';
import '../controllers/home_controller.dart';

void paymentDialog(
    BuildContext context, Invoice invoice, HomeController controller) {
  late ProductService productService = Get.find();
  late InvoiceService invoiceServices = Get.find();
  final CustomerInputFieldController customerInputFieldC = Get.find();
  final PaymentController paymentController = Get.find();

  // void saveInvoice(Invoice invoice) async {
  Future success() async {
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
      await invoiceServices.addInvoices(invoicesMap);
      Get.back();
      return Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Invoice berhasil disimpan.',
        confirm: TextButton(
          onPressed: () {
            controller.resetData();
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

  Future validate(String validateCode) async {
    Get.defaultDialog(
      title: 'Ups',
      middleText: validateCode == 'debt'
          ? 'Total tagihan belum terpenuhi. lanjutkan?'
          : 'Data Customer tidak lengkap. lanjutkan?',
      confirm: TextButton(
        onPressed: () async {
          await success();
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
    (customerInputFieldC.customerNameController.text == '' ||
            customerInputFieldC.customerPhoneController.text == '' ||
            customerInputFieldC.customerAddressController.text == '')
        ? validate('Customer')
        : !invoice.isDebtPaid
            ? validate('debt')
            : success();
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
        children: [
          const CustomerInputFieldCard(),
          PaymentCard(
            invoice: invoice,
            onClick: () async {
              await paymentController.addPayment(invoice);
              saveInvoice();
            },
          ),
        ],
      ),
    ),
  );
}
