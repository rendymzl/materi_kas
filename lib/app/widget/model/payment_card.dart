import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/models/invoice_model.dart';
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
                // crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp${controller.currency.format(invoice.total)}',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  )
                ],
              ),
              // const SizedBox(height: 12),
              if (invoice.totalDiscount > 0)
                Text(
                  'Rp${controller.currency.format(invoice.subtotal)}',
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
                    // int change = controller.moneyChange.value -
                    //     controller.totalBill.value;
                    // String formattedChange =
                    //     change > 0 ? formatter.format(change) : '0';
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
                                  controller.currency.format(
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
