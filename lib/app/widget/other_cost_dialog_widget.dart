import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/models/invoice_model.dart';
import '../data/providers/invoice_services.dart';
import 'payment_card.dart';
import 'payment_controller.dart';

void otherCostDialogWidget(BuildContext context, Invoice invoice) {
  late InvoiceService invoiceServices = Get.find();

  final NumberFormat currency = NumberFormat("#,##0", "id_ID");
  final otherCostNameTextC = TextEditingController();
  final otherCostAmountTextC = TextEditingController();

  Future process() async {
    Get.defaultDialog(
      title: 'Menambahkan biaya lainnya',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      invoice.addOtherCost(otherCostNameTextC.text,
          double.parse(otherCostAmountTextC.text.replaceAll('.', '')));
      await invoiceServices.updateInvoice(invoice);
      Get.back();
      return Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Biaya lainnya berhasil disimpan.',
        confirm: TextButton(
          onPressed: () {
            invoice.updateIsDebtPaid();
            invoice.updateReturn();
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    } catch (e) {
      Get.back();
      Get.defaultDialog(
        title: 'Gagal menambahkan biaya lainnya',
        middleText: e.toString(),
        barrierDismissible: false,
      );
    }
  }

  void saveOtherCost() {
    // int amountInt = int.parse(otherCostAmountTextC.text.replaceAll('.', ''));

    if (otherCostNameTextC.text != '' && otherCostAmountTextC.text != '') {
      process();
      // debugPrint('procesing');
    }
  }

  Get.defaultDialog(
    title: 'Tambah Biaya Lainnya',
    content: SizedBox(
      width: 350,
      child: Column(
        // shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: otherCostNameTextC,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Nama Biaya',
                      labelStyle: context.textTheme.bodySmall!
                          .copyWith(fontStyle: FontStyle.italic),
                      counterText: '',
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      contentPadding: const EdgeInsets.all(10),
                      border:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      isDense: true,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      // invoice.addOtherCost(name, amount)
                      // invoice.updateIsDebtPaid();
                    },
                    validator: (value) {
                      if (value == '') {
                        return 'Kode tidak boleh kosong';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                const Text('  :   '),
                Expanded(
                  child: TextFormField(
                    controller: otherCostAmountTextC,
                    textAlign: TextAlign.center,
                    maxLength: 15,
                    decoration: InputDecoration(
                      labelText: 'Jumlah Biaya',
                      labelStyle: context.textTheme.bodySmall!
                          .copyWith(fontStyle: FontStyle.italic),
                      prefixText: 'Rp',
                      counterText: '',
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      contentPadding: const EdgeInsets.all(10),
                      border:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      isDense: true,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        String newValue = currency
                            .format(int.parse(value.replaceAll('.', '')));

                        // final textController = textControllers[field];

                        if (newValue != otherCostAmountTextC.text) {
                          otherCostAmountTextC.value = TextEditingValue(
                            text: newValue,
                            selection: TextSelection.collapsed(
                                offset: newValue.length),
                          );
                        }
                      }
                      // invoice.addOtherCost(name, amount)
                      // invoice.updateIsDebtPaid();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    confirm: ElevatedButton(
      onPressed: () => saveOtherCost(),
      child: const Text(
        'Simpan Tambah Biaya',
      ),
    ),
  );
}
