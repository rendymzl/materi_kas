import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/cart_model.dart';
import '../../../data/models/invoice_model.dart';
import '../controllers/invoice_controller.dart';
import 'list_cart_widget.dart';

class ReturnWidget extends StatelessWidget {
  const ReturnWidget({
    super.key,
    required this.returnCart,
    required this.controller,
    required this.invoice,
    required this.purchaseCart,
  });

  final RxList<Cart> returnCart;
  final InvoiceController controller;
  final Invoice invoice;
  final RxList<Cart> purchaseCart;

  @override
  Widget build(BuildContext context) {
    const source = 'returnWidget';
    return Flexible(
      child: Row(
        children: [
          if (returnCart.isNotEmpty)
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Return',
                      style: context.textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListCartWidget(
                        source: source,
                        cartList: returnCart,
                        controller: controller,
                        isReturn: true,
                      ),
                    ),
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Total:',
                                textAlign: TextAlign.right,
                                style: Theme.of(Get.context!)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(Get.context!)
                                            .colorScheme
                                            .primary),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  'Rp.${controller.currency.format(controller.totalReturn.value)}',
                                  textAlign: TextAlign.end,
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: Theme.of(Get.context!)
                                              .colorScheme
                                              .primary),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Biaya Return:',
                                style: context.textTheme.titleLarge,
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller:
                                      controller.returnFeeTextController,
                                  style: context.textTheme.titleLarge,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey,
                                    prefixIcon: Text(
                                      'Rp.',
                                      style: context.textTheme.titleLarge,
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                        minWidth: 0, minHeight: 0),
                                    hintText: '0',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  onChanged: (value) {
                                    controller.returnFeeHandle(value, invoice);
                                  },
                                ),
                              ),
                            ],
                          ),
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'TOTAL RETURN:',
                                  textAlign: TextAlign.right,
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: Theme.of(Get.context!)
                                              .colorScheme
                                              .primary),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Rp.${controller.currency.format(controller.totalReturnFinal.value)}',
                                    textAlign: TextAlign.end,
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: Theme.of(Get.context!)
                                                .colorScheme
                                                .primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pembelian',
                  style: context.textTheme.titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListCartWidget(
                    source: source,
                    cartList: purchaseCart,
                    controller: controller,
                    isReturn: false,
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              controller.saveReturnInvoice(invoice),
                          child: const Text('Simpan Return'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
