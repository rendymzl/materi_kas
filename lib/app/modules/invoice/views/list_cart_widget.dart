//* 1.0 ListCartWidget ==================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../main.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/invoice_model.dart';
import '../controllers/invoice_controller.dart';

class ListCartWidget extends StatelessWidget {
  const ListCartWidget({
    super.key,
    required this.invoice,
    required this.controller,
    // this.priceType,
    // required this.cartList,
    required this.isEdit,
    required this.isReturn,
  });

  // final int? priceType;
  // final Cart cartList;
  final Invoice invoice;
  final InvoiceController controller;
  final bool isEdit;
  final bool isReturn;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Divider(
            color: Colors.grey[200],
          ),
        ),
        itemCount: invoice.purchaseList.value.items.length,
        itemBuilder: (BuildContext context, int index) {
          final productCart = invoice.purchaseList.value.items[index];

          final quantityTextC = TextEditingController();
          String displayQtyValue = productCart.quantity.value % 1 == 0
              ? productCart.quantity.value.toInt().toString()
              : productCart.quantity.value.toString().replaceAll('.', ',');
          quantityTextC.text = displayQtyValue;
          // quantityTextC.selection = TextSelection.fromPosition(
          //   TextPosition(offset: quantityTextC.text.length),
          // );

          final quantityReturnTextC = TextEditingController();
          String displayReturnQtyValue =
              productCart.quantityReturn.value % 1 == 0
                  ? productCart.quantityReturn.value.toInt().toString()
                  : productCart.quantityReturn.value
                      .toString()
                      .replaceAll('.', ',');
          quantityReturnTextC.text = displayReturnQtyValue;
          quantityReturnTextC.selection = TextSelection.fromPosition(
            TextPosition(offset: quantityReturnTextC.text.length),
          );

          final discountTextC = TextEditingController();
          discountTextC.text = productCart.individualDiscount.value == 0
              ? '-'
              : currency.format(productCart.individualDiscount.value);
          discountTextC.selection = TextSelection.fromPosition(
            TextPosition(offset: discountTextC.text.length),
          );

          bool emptyQty = ((productCart.quantity.value == 0 && !isReturn) ||
              (productCart.quantityReturn.value == 0 && isReturn));

          return Obx(
            () => Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child:
                  //  (emptyQty)
                  // ? const ListTile(
                  //     title: SizedBox(
                  //       height: 30,
                  //     ),
                  //     subtitle: SizedBox(height: 47),
                  //   )
                  // :
                  ListTile(
                enabled: !emptyQty,
                tileColor: emptyQty
                    ? Colors.grey[100]!.withOpacity(0.3)
                    : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                title: SizedBox(
                  height: 30,
                  // margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${index + 1}. ${productCart.product.productName}',
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  // style: context.textTheme.titleMedium,
                                ),
                              ),
                              // const SizedBox(width: 12),
                              // if (!isReturn &&
                              //     invoice.priceType.value != 1)
                              //   Text(
                              //     'Rp${controller.currency.format(productCart.getPrice(1))}',
                              //     style: context.textTheme.bodySmall!
                              //         .copyWith(
                              //             fontStyle: FontStyle.italic,
                              //             decoration:
                              //                 TextDecoration.lineThrough),
                              //   ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          (!isEdit)
                              ? !isReturn
                                  ? emptyQty
                                      ? const SizedBox()
                                      : InkWell(
                                          onTap: !emptyQty
                                              ? () {
                                                  bool qtyLessThan1 =
                                                      productCart
                                                              .quantity.value <
                                                          1;

                                                  double remainQty = productCart
                                                      .quantity.value;

                                                  double value = qtyLessThan1
                                                      ? remainQty
                                                      : 1;

                                                  controller.addToStock(
                                                      productCart,
                                                      invoice,
                                                      value,
                                                      isReturn);
                                                }
                                              : null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Symbols.arrow_left,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  'Return',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                  : emptyQty
                                      ? const SizedBox()
                                      : InkWell(
                                          onTap: !emptyQty
                                              ? () {
                                                  bool qtyLessThan1 =
                                                      productCart.quantityReturn
                                                              .value <
                                                          1;

                                                  double remainQty = productCart
                                                      .quantityReturn.value;

                                                  double value = qtyLessThan1
                                                      ? remainQty
                                                      : 1;

                                                  controller.addToStock(
                                                      productCart,
                                                      invoice,
                                                      value,
                                                      isReturn);
                                                }
                                              : null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Row(
                                              children: [
                                                Text(
                                                  'Batal Return',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                                Icon(
                                                  Symbols.arrow_right,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                              : const SizedBox()
                          // Container(
                          //     height: 28,
                          //     width: 28,
                          //     decoration: BoxDecoration(
                          //         color:
                          //             Theme.of(context).colorScheme.primary,
                          //         borderRadius: const BorderRadius.all(
                          //             Radius.circular(5))),
                          //     child: IconButton(
                          //       onPressed: () {
                          //         // invoice.purchaseList.value
                          //         //     .removeItem(productCart.product.id);
                          //         // invoice.updateIsDebtPaid();
                          //         controller.removeFromCart(
                          //             productCart, invoice, isReturn);
                          //       },
                          //       icon: const Icon(
                          //         Symbols.close,
                          //         size: 12,
                          //         color: Colors.white,
                          //       ),
                          //     ),
                          //   )
                        ],
                      ),
                    ],
                  ),
                ),
                subtitle: SizedBox(
                  // color: Colors.amber,
                  height: 47,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          child: Text(
                            'Rp${currency.format(productCart.product.getPrice(invoice.priceType.value))}',
                            // style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          child: Row(
                            children: [
                              isReturn
                                  ? Expanded(
                                      child: QuantityTextField(
                                        invoice: invoice,
                                        quantityTextC: quantityReturnTextC,
                                        controller: controller,
                                        productCart: productCart,
                                        isEdit: isEdit,
                                        isReturn: isReturn,
                                      ),
                                    )
                                  : isEdit
                                      ? Expanded(
                                          child: QuantityTextField(
                                            invoice: invoice,
                                            quantityTextC: quantityTextC,
                                            controller: controller,
                                            productCart: productCart,
                                            isEdit: isEdit,
                                            isReturn: isReturn,
                                          ),
                                        )
                                      : Text(
                                          'x ${decimal.format(productCart.quantity.value)}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (!isReturn)
                        isEdit
                            ? Expanded(
                                flex: 5,
                                child: SizedBox(
                                  child: DiscountTextfield(
                                      invoice: invoice,
                                      discountTextC: discountTextC,
                                      productCart: productCart),
                                ),
                              )
                            : Text(productCart.individualDiscount.value > 0
                                ? 'Rp-${currency.format(productCart.individualDiscount.value)}'
                                : ''),
                      Expanded(
                        flex: 7,
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isReturn
                                  ? Text(
                                      'Rp${currency.format(productCart.getTotalReturn(invoice.priceType.value))}')
                                  : Text(
                                      'Rp${currency.format(productCart.getTotal(invoice.priceType.value))}'),
                              if (!isReturn &&
                                  productCart.individualDiscount.value > 0)
                                Text(
                                  'Rp${currency.format(productCart.getSubtotal(invoice.priceType.value))}',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.lineThrough),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//* 1.1 QuantityTextField ==================================================================
class QuantityTextField extends StatelessWidget {
  const QuantityTextField({
    super.key,
    required this.invoice,
    required this.quantityTextC,
    required this.controller,
    required this.productCart,
    required this.isEdit,
    required this.isReturn,
  });

  final Invoice invoice;
  final TextEditingController quantityTextC;
  final InvoiceController controller;
  final CartItem productCart;
  final bool isEdit;
  final bool isReturn;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: quantityTextC,
        textAlign: TextAlign.center,
        // maxLength: 3,
        decoration: InputDecoration(
          labelText: 'Jumlah',
          labelStyle: context.textTheme.bodySmall!
              .copyWith(fontStyle: FontStyle.italic),
          prefixText: 'x',
          counterText: '',
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          contentPadding: const EdgeInsets.all(10),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d*'))
        ],
        onChanged: (value) {
          if (!value.endsWith(',')) {
            controller.isComa.value = false;
            value == '' ? 0 : value;
            String unformattedValue = value.replaceAll('.', '');
            String processedValue = unformattedValue.replaceAll(',', '.');
            isEdit
                ? controller.quantityEditHandle(productCart, processedValue,
                    invoice, quantityTextC, isReturn)
                : controller.quantityReturnHandle(
                    productCart, processedValue, invoice, quantityTextC);
          } else {
            controller.isComa.value = true;
          }
        });
  }
}

//* 1.2 discountTextfield ==================================================================
class DiscountTextfield extends StatelessWidget {
  const DiscountTextfield({
    super.key,
    required this.invoice,
    required this.discountTextC,
    // required this.controller,
    required this.productCart,
  });

  final Invoice invoice;
  final TextEditingController discountTextC;
  // final InvoiceController controller;
  final CartItem productCart;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: discountTextC,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Discount',
        labelStyle:
            context.textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic),
        prefixText: 'Rp',
        counterText: '',
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        contentPadding: const EdgeInsets.all(10),
        border: const OutlineInputBorder(borderSide: BorderSide.none),
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      onChanged: (value) {
        String newValue =
            currency.format(double.parse(value.replaceAll('.', '')));
        productCart.individualDiscount.value =
            value == '' ? 0 : double.parse(value.replaceAll('.', ''));
        if (newValue != discountTextC.text) {
          discountTextC.value = TextEditingValue(
            text: newValue,
            selection: TextSelection.collapsed(offset: newValue.length),
          );
        }
        invoice.updateIsDebtPaid();
      },
    );
  }
}
