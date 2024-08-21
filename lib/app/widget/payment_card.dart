import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../main.dart';
import '../data/models/invoice_model.dart';
import 'payment_controller.dart';
// import 'package:material_symbols_icons/symbols.dart';

// import '../data/models/customer_model.dart';
// import 'customer_input_field_controller.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.invoice,
    required this.onClick,
  });

  final Invoice invoice;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    late PaymentController controller = Get.put(PaymentController());
    // OutlineInputBorder outlineRed =
    //     const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    return Card(
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      tileColor: Colors.grey[100],
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: controller.paymentMethod[0],
                            groupValue: controller.selectedPaymentMethod.value,
                            onChanged: (value) {
                              controller.setPaymentMethod(value!);
                              controller.textFocusNode.requestFocus();
                            },
                          ),
                          const Text('Cash'),
                        ],
                      ),
                      onTap: () => controller
                          .setPaymentMethod(controller.paymentMethod[0]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ListTile(
                      tileColor: Colors.grey[100],
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: controller.paymentMethod[1],
                            groupValue: controller.selectedPaymentMethod.value,
                            onChanged: (value) {
                              controller.setPaymentMethod(value!);
                              controller.textFocusNode.requestFocus();
                            },
                          ),
                          const Text('Transfer'),
                        ],
                      ),
                      onTap: () => controller
                          .setPaymentMethod(controller.paymentMethod[1]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Obx(
                () {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                            invoice.total != invoice.remainingDebt
                                ? 'SISA TAGIHAN:'
                                : 'TAGIHAN:',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(
                            () => Text(
                              'Rp${currency.format(invoice.remainingDebt)}',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      )
                    ],
                  );
                },
              ),
              // const SizedBox(height: 12),
              if (invoice.totalDiscount > 0 &&
                  invoice.total == invoice.remainingDebt)
                Text(
                  'Rp${currency.format(invoice.subtotal)}',
                  style: context.textTheme.bodySmall!.copyWith(
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.lineThrough),
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
                          focusNode: controller.textFocusNode,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                          controller: controller.paymentTextC,
                          decoration: const InputDecoration(
                            prefixIcon: Text('Rp. ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            prefixIconConstraints:
                                BoxConstraints(minWidth: 0, minHeight: 0),
                            hintText: '0',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                          onChanged: (value) =>
                              controller.onPayChanged(invoice, value),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              if (controller.moneyChange.value != 0)
                Obx(
                  () {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                              controller.moneyChange.value < 0
                                  ? 'Kembalian'
                                  : 'Kurang',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              )),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  currency.format(
                                      controller.moneyChange.value * -1),
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
                            onPressed: onClick, child: const Text('Bayar')),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
