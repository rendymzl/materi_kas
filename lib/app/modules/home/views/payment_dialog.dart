import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widget/customer_input_field_widget.dart';
import '../controllers/home_controller.dart';

void paymentDialog(BuildContext context, HomeController controller) {
  Get.defaultDialog(
    title: 'Pembayaran',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (3 / 4),
      width: MediaQuery.of(context).size.width * (1 / 3),
      child: ListView(
        children: [
          PaymentCard(
            controller: controller,
            // invoice: invoice,
          ),
        ],
      ),
    ),
  );
}

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.controller,
    // required this.invoice,
  });

  final HomeController controller;
  // final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomerInputField(),
        Card(
          child: Obx(
            () => Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: const Text('Cash'),
                          leading: Radio<String>(
                            value: controller.paymentMethod[0],
                            groupValue: controller.selectedPaymentMethod.value,
                            onChanged: (value) {
                              controller.setPaymentMethod(value!);
                            },
                          ),
                          onTap: () => controller
                              .setPaymentMethod(controller.paymentMethod[0]),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('Transfer'),
                          leading: Radio<String>(
                            value: controller.paymentMethod[1],
                            groupValue: controller.selectedPaymentMethod.value,
                            onChanged: (value) {
                              controller.setPaymentMethod(value!);
                            },
                          ),
                          onTap: () => controller
                              .setPaymentMethod(controller.paymentMethod[1]),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 200,
                        child: Text('Total Belanja:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Row(
                          children: [
                            if (controller.totalDiscount.value > 0)
                              Text(
                                'Rp${controller.currency.format(controller.totalDiscount.value + controller.totalBill.value)}',
                                style: context.textTheme.bodySmall!.copyWith(
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            const SizedBox(width: 16),
                            Text(
                              'Rp${controller.currency.format(controller.totalBill.value)}',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (controller.selectedPaymentMethod.value != '')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text('Bayar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: TextField(
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                              controller: controller.payTextC,
                              decoration: const InputDecoration(
                                prefixIcon: Text('Rp. ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                prefixIconConstraints:
                                    BoxConstraints(minWidth: 0, minHeight: 0),
                                hintText: '0',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              onChanged: (value) =>
                                  controller.onPayChanged(value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (controller.selectedPaymentMethod.value != '')
                    Obx(
                      () {
                        int change = controller.moneyChange.value -
                            controller.totalBill.value;
                        // String formattedChange =
                        //     change > 0 ? formatter.format(change) : '0';
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(change > 0 ? 'Kembalian' : 'Kurang',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  )),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp. ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 3),
                                    child: Text(
                                      controller.currency.format(change),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  if (controller.selectedPaymentMethod.value != '')
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (controller.totalBill > 0) {
                                    await controller.saveInvoice();
                                    // paymentDialog(context, controller);
                                  } else {
                                    Get.defaultDialog(
                                      title: 'Error',
                                      middleText:
                                          'Tidak ada Barang yang ditambahkan.',
                                      confirm: TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('OK'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Bayar')),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
