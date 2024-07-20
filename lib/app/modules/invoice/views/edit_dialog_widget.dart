import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/invoice_model.dart';
import '../../../widget/customer_input_field_widget.dart';
import '../../../widget/properties_row_widget.dart';
import '../controllers/invoice_controller.dart';
import 'cart_card.dart';

void editDialog(
    BuildContext context, InvoiceController controller, Invoice invoice) {
  controller.resetEditData(invoice);

  Get.defaultDialog(
    title: 'Edit Invoice ${invoice.invoiceId}',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (3 / 4),
      width: MediaQuery.of(context).size.width * (7 / 10),
      child: ListView(
        children: [
          const CustomerInputField(),
          CartCard(controller: controller, invoice: invoice),
          Card(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: CalculatePrice(
                      controller: controller,
                      invoice: invoice,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    //   ),
    // ),
    // onCancel: () => controller.init.value = true,
  );
}

//* 2.0 CalculatePrice ==================================================================
class CalculatePrice extends StatelessWidget {
  const CalculatePrice({
    super.key,
    required this.controller,
    required this.invoice,
  });

  final InvoiceController controller;
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 450),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      color: Colors.white,
      child: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PropertiesRowWidget(
              title:
                  'TOTAL HARGA (${controller.editPurchaseCart.length} Barang)',
              value: controller.currency.format(controller.totalPurchase.value +
                  controller.totalDiscount.value),
              // subValue: controller.totalReturn.value > 0
              //     ? controller.currency.format(controller.totalPurchase.value +
              //         controller.totalReturn.value)
              //     : '',
              primary: true,
            ),
            if (controller.totalDiscount.value > 0)
              PropertiesRowWidget(
                title: 'Total Diskon',
                value:
                    '-${controller.currency.format(controller.totalDiscount.value)}',
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
            Divider(color: Colors.grey[200]),
            PropertiesRowWidget(
              title: 'TOTAL BELANJA',
              value: controller.currency.format(controller.totalPurchase.value),
              primary: true,
            ),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 350,
                  child: Text('Bayar', style: context.textTheme.titleLarge!),
                ),
                Expanded(
                  child: SizedBox(
                    child: TextField(
                      style: context.textTheme.titleLarge!,
                      textAlign: TextAlign.right,
                      controller: controller.payTextController, //! PayValue
                      decoration: InputDecoration(
                        prefixIcon:
                            Text('Rp.', style: context.textTheme.titleLarge!),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        hintText: '0',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      onChanged: (value) => controller.onPayHandle(value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            if (controller.totalChange.value != 0)
              PropertiesRowWidget(
                title: controller.totalChange.value > -1
                    ? 'Kembalian'
                    : 'Kurang Bayar',
                value: controller.currency.format(controller.totalChange.value),
                color: Colors.grey,
              ),
            const SizedBox(height: 20),

            // PropertiesRowWidget(
            //   title: 'Total Return',
            //   value:
            //       '-${controller.currency.format(controller.totalReturnFinal.value)}',
            //   color: Theme.of(Get.context!).colorScheme.primary,
            // ),
            // const SizedBox(height: 20),
            // Divider(color: Colors.grey[200]),
            // PropertiesRowWidget(
            //   title: 'TOTAL TAGIHAN',
            //   value: controller.currency.format(controller.totalPurchase.value -
            //       controller.totalReturnFinal.value),
            //   primary: true,
            // ),
            // Divider(color: Colors.grey[200]),
            // const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.totalPurchase > 0) {
                        await controller.saveInvoice(invoice);
                      } else {
                        Get.defaultDialog(
                          title: 'Error',
                          middleText: 'Tidak ada Barang yang ditambahkan.',
                          confirm: TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('OK'),
                          ),
                        );
                      }
                    },
                    child: const Text('Simpan Edit Invoice'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
