//! 2 CartCard ==================================================================
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';

import '../../../data/models/invoice_model.dart';
import 'purchase_widget.dart';
import '../controllers/invoice_controller.dart';

class CartCard extends StatelessWidget {
  const CartCard({
    super.key,
    this.source,
    required this.controller,
    required this.invoice,
  });

  final String? source;
  final InvoiceController controller;
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    controller.totalPurchase.value = 0;
    final editPurchaseCart = controller.editPurchaseCart;
    final editReturnCart = controller.editReturnCart;
    controller.totalDiscount.value = 0;
    for (var item in editPurchaseCart) {
      controller.totalPurchase.value +=
          (item.product!.sellPrice! * item.quantity! -
              item.individualDiscount!);

      controller.totalDiscount.value += item.individualDiscount!;
    }

    controller.totalChange.value =
        (int.parse(controller.payTextController.text.replaceAll('.', '')) -
            controller.totalPurchase.value);

    // TimeOfDay selectedTime = controller.selectedTime.value;
    // DateTime convertedTime =
    //     DateTime(2024, 1, 1, selectedTime.hour, selectedTime.minute);
    controller.returnFeeTextController.text =
        controller.currency.format(controller.returnFee.value);
    return Column(
      children: [
        Obx(
          () {
            return SizedBox(
              height: (editPurchaseCart.length > editReturnCart.length
                          ? editPurchaseCart.length
                          : editReturnCart.length) *
                      105 +
                  230,
              child: Card(
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      color: Colors.white,
                      margin: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () async =>
                                    controller.handleDate(context),
                                child: Obx(
                                  () => Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      controller.displayDate.value,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              InkWell(
                                onTap: () async =>
                                    controller.handleTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    controller.displayTime.value,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    PurchaseWidget(
                      // returnCart: editReturnCart,
                      controller: controller,
                      invoice: invoice,
                      purchaseCart: editPurchaseCart,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
