//* 1.0 ListCartWidget ==================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/models/cart_model.dart';
import '../controllers/invoice_controller.dart';

class ListCartWidget extends StatelessWidget {
  const ListCartWidget({
    super.key,
    this.source,
    required this.cartList,
    required this.controller,
    required this.isReturn,
  });

  final String? source;
  final List<Cart> cartList;
  final InvoiceController controller;
  final bool isReturn;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Divider(
            color: Colors.grey[200],
          ),
        ),
        itemCount: cartList.length,
        itemBuilder: (BuildContext context, int index) {
          final productCart = cartList[index];

          final quantityTextC = TextEditingController();
          quantityTextC.text = '${productCart.quantity}';
          quantityTextC.selection = TextSelection.fromPosition(
            TextPosition(offset: quantityTextC.text.length),
          );

          final discountTextC = TextEditingController();
          discountTextC.text = productCart.individualDiscount == 0
              ? '-'
              : controller.currency.format(productCart.individualDiscount);
          discountTextC.selection = TextSelection.fromPosition(
            TextPosition(offset: discountTextC.text.length),
          );

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              title: Container(
                height: 30,
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          '${index + 1}. ${productCart.product!.productName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        (source == 'returnWidget')
                            ? !isReturn
                                ? InkWell(
                                    onTap: () {
                                      controller.returnHandle(productCart, -1);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Return',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () =>
                                        controller.returnHandle(productCart, 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Batal Return',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                            : Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5))),
                                child: IconButton(
                                  onPressed: () => controller.removeFromCart(
                                      cartList, productCart),
                                  icon: const Icon(
                                    Symbols.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              )
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
                          'Rp.${controller.currency.format(productCart.product!.sellPrice)}',
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        child: Row(
                          children: [
                            (source == 'returnWidget')
                                ? Text('x ${productCart.quantity}')
                                : Expanded(
                                    child: QuantityTextField(
                                        quantityTextC: quantityTextC,
                                        controller: controller,
                                        productCart:
                                            productCart), //* 1.1 QuantityTextField
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (!isReturn)
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          child: (source == 'returnWidget')
                              ? Text(productCart.individualDiscount! > 0
                                  ? 'Discount ${controller.currency.format(productCart.individualDiscount)}'
                                  : '')
                              : DiscountTextfield(
                                  discountTextC: discountTextC,
                                  controller: controller,
                                  productCart:
                                      productCart), //* 1.1 QuantityTextField,
                        ),
                      ),
                    Expanded(
                      flex: 7,
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Rp.${controller.currency.format(productCart.product!.sellPrice! * productCart.quantity! - (isReturn ? 0 : productCart.individualDiscount!))}',
                              style: context.textTheme.titleMedium,
                            ),
                            if (!isReturn &&
                                productCart.individualDiscount! > 0)
                              Text(
                                'Rp.${controller.currency.format(productCart.product!.sellPrice! * productCart.quantity!)}',
                                style: context.textTheme.bodySmall!.copyWith(
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
    required this.quantityTextC,
    required this.controller,
    required this.productCart,
  });

  final TextEditingController quantityTextC;
  final InvoiceController controller;
  final Cart productCart;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: quantityTextC,
        textAlign: TextAlign.center,
        maxLength: 3,
        decoration: InputDecoration(
          prefixText: 'x',
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
          // value == '' ? 0 : value;
          // int qtyParse = value.isEmpty ? 0 : int.parse(value);
          controller.quantityHandle(productCart, value);
        });
  }
}

//* 1.2 discountTextfield ==================================================================
class DiscountTextfield extends StatelessWidget {
  const DiscountTextfield({
    super.key,
    required this.discountTextC,
    required this.controller,
    required this.productCart,
  });

  final TextEditingController discountTextC;
  final InvoiceController controller;
  final Cart productCart;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: discountTextC,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: 'Discount',
          labelStyle: context.textTheme.bodySmall!
              .copyWith(fontStyle: FontStyle.italic),
          prefixText: 'Rp.',
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
          controller.discountHandle(productCart, discountTextC, value);
        });
  }
}
