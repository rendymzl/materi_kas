import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';

import '../../../../main.dart';
import '../../../data/models/operating_costs_model.dart';
import '../../../data/providers/operating_cost_services.dart';
import '../controllers/statistic_controller.dart';

void addOperatingCostDialog(
    BuildContext context, StatisticController controller) {
  late OperatingCostServices operatingCostServices =
      Get.put(OperatingCostServices());

  final operatingCostNameTextC = TextEditingController();
  final operatingCostAmountTextC = TextEditingController();
  final operatingCostNoteTextC = TextEditingController();

  Future process() async {
    // operatingCostServices.fetchOperatingCost();
    Get.defaultDialog(
      title: 'Menambahkan biaya operasional',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      Map<String, Map<String, dynamic>> operatingCostMap = {};
      OperatingCost operatingCost = OperatingCost(
          createdAt: Timestamp.now(),
          name: operatingCostNameTextC.text,
          amount: int.parse(operatingCostAmountTextC.text.replaceAll('.', '')),
          note: operatingCostNoteTextC.text);
      String newCustomerId = await operatingCostServices.getId();
      operatingCost.id = newCustomerId;
      operatingCostMap[newCustomerId] = operatingCost.toJson();
      await operatingCostServices.addOperatingCost(operatingCostMap);
      Get.back();
      return Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Biaya operasional berhasil ditambahkan',
        confirm: TextButton(
          onPressed: () {
            controller.rangePickerHandle(controller.args.value);
            controller.selectedSection.value = 'daily';
            // invoice.updateIsDebtPaid();
            // invoice.updateReturn();
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    } catch (e) {
      Get.back();
      Get.defaultDialog(
        title: 'Gagal menambahkan biaya operasional',
        middleText: e.toString(),
      );
    }
  }

  void saveOperatingCost() {
    if (operatingCostNameTextC.text != '' &&
        operatingCostAmountTextC.text != '') {
      process();
    }
  }

  Get.defaultDialog(
    title: 'Tambah Biaya Operasional',
    content: SizedBox(
      height: 100,
      width: 350,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          // shrinkWrap: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: operatingCostNameTextC,
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
                    // onChanged: (value) {
                    //   // invoice.addOtherCost(name, amount)
                    //   // invoice.updateIsDebtPaid();
                    // },
                    // validator: (value) {
                    //   if (value == '') {
                    //     return 'Kode tidak boleh kosong';
                    //   } else {
                    //     return null;
                    //   }
                    // },
                  ),
                ),
                const Text('  :   '),
                Expanded(
                  child: TextFormField(
                    controller: operatingCostAmountTextC,
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

                        if (newValue != operatingCostAmountTextC.text) {
                          operatingCostAmountTextC.value = TextEditingValue(
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
            const SizedBox(height: 12),
            Expanded(
              child: TextFormField(
                controller: operatingCostNoteTextC,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  labelStyle: context.textTheme.bodySmall!
                      .copyWith(fontStyle: FontStyle.italic),
                  counterText: '',
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  contentPadding: const EdgeInsets.all(10),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  isDense: true,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                // onChanged: (value) {
                //   // invoice.addOtherCost(name, amount)
                //   // invoice.updateIsDebtPaid();
                // },
                // validator: (value) {
                //   if (value == '') {
                //     return 'Kode tidak boleh kosong';
                //   } else {
                //     return null;
                //   }
                // },
              ),
            ),
          ],
        ),
      ),
    ),
    confirm: ElevatedButton(
      onPressed: () => saveOperatingCost(),
      child: const Text(
        'Simpan Biaya Operasional',
      ),
    ),
  );
}
