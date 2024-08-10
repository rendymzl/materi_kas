import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../main.dart';
import '../../../data/models/cart_item_model.dart';
// import '../../../data/models/customer_model.dart';
// import '../../../data/models/invoice_model.dart';
import '../../../data/models/sales_invoice_model.dart';
import '../../../data/models/sales_model.dart';
import '../../../widget/date_picker_widget.dart';
import '../../../widget/properties_row_widget.dart';
import '../../sales/views/sales_payment.dart';
import 'buy_product_controller.dart';

void buyProductDialog(
  BuildContext context,
  Sales? selectecSales,
) async {
  late BuyProductController controller = Get.put(BuyProductController());
  controller.clear();
  controller.cart.value.items.clear();
  controller.updatedStockProducts.clear();
  if (selectecSales != null) {
    controller.selectedSales.value = selectecSales;
    controller.salesTextC.text = selectecSales.name!;
  }

  Get.defaultDialog(
    title: 'Beli Barang',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (7 / 9),
      width: MediaQuery.of(context).size.width * (9 / 11),
      child: Card(
        child: Obx(
          () => SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.selectedSales.value != null)
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                        child: ProductListCard(controller: controller)),
                  ),
                if (controller.selectedSales.value != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: VerticalDivider(
                      thickness: 2,
                      color: Colors.grey[200],
                    ),
                  ),
                Expanded(
                  flex: 5,
                  child: SelectedProductCard(controller: controller),
                ), //! 2 SelectedProductCard
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

//! 2 ProductListCard ==================================================================
class ProductListCard extends StatelessWidget {
  const ProductListCard({
    super.key,
    required this.controller,
  });

  final BuyProductController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            // color: Colors.amber,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            height: 50,
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Cari Barang",
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Symbols.search),
                border: InputBorder.none,
              ),
              onChanged: (value) => controller.filterProducts(value),
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.foundProducts.length,
                itemBuilder: (BuildContext context, int index) {
                  final foundProducts = controller.foundProducts[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: ListTile(
                      leading: SizedBox(
                        width: 60,
                        child: Text(
                          foundProducts.productId,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                      title: Text(
                        foundProducts.productName,
                        style: context.textTheme.titleLarge,
                      ),
                      trailing: Text(
                        'Rp${currency.format(foundProducts.costPrice.value)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () => controller.addToCart(foundProducts),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//! 2 SelectedProductCard ==================================================================
class SelectedProductCard extends StatelessWidget {
  const SelectedProductCard({
    super.key,
    required this.controller,
  });

  final BuyProductController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Obx(
        () {
          final cartItems = controller.cart.value.items;
          return ListView(
            shrinkWrap: true,
            children: [
              Column(
                children: [
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            // margin: const EdgeInsets.only(bottom: 12),
                            // color: Colors.amber,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            height: 50,
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: "Nomor Invoice",
                                labelStyle: TextStyle(color: Colors.grey),
                                // prefixIcon: Icon(Symbols.search),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) =>
                                  controller.nomorInvoice.value = value,
                            ),
                          ),
                        ),
                        const SizedBox(width: 50),
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            height: 50,
                            child: Autocomplete<Sales>(
                              initialValue: controller.salesTextC.value,
                              optionsBuilder: (TextEditingValue salesTextC) {
                                return controller.sales.where((Sales sales) {
                                  final String customerName =
                                      sales.name?.toLowerCase() ?? '';
                                  final String input =
                                      salesTextC.text.toLowerCase();
                                  return customerName.contains(input);
                                });
                              },
                              displayStringForOption: (Sales customer) =>
                                  customer.name ?? '',
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController salesTextC,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return Obx(
                                  () => TextField(
                                    key: controller.textFieldKey,
                                    controller: salesTextC,
                                    focusNode: focusNode,
                                    onChanged: (value) {
                                      controller.showSuffixClear.value =
                                          value != '';
                                      debugPrint((value != '').toString());
                                    },
                                    onSubmitted: (String value) {
                                      onFieldSubmitted();
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Cari Sales",
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
                                      prefixIcon: const Icon(Symbols.search),
                                      suffixIconColor: Colors.red,
                                      suffixIcon: controller
                                              .showSuffixClear.value
                                          ? IconButton(
                                              onPressed: () {
                                                salesTextC.text = '';
                                                controller.clear();
                                              },
                                              icon: const Icon(Symbols.close))
                                          : null,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                );
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<Sales> onSelected,
                                  Iterable<Sales> options) {
                                final int optionsLength = options.length;
                                final RenderBox renderBox = controller
                                    .textFieldKey.currentContext
                                    ?.findRenderObject() as RenderBox;
                                final double textFieldWidth =
                                    renderBox.size.width;

                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                        horizontal: BorderSide(
                                            color: Colors.grey[200]!),
                                      ),
                                    ),
                                    width: textFieldWidth,
                                    child: Card(
                                      color: Colors.grey[100],
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.all(8.0),
                                        itemCount: optionsLength,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final Sales option =
                                              options.elementAt(index);
                                          return ListTile(
                                            // hoverColor: Colors.white,
                                            title: Text(option.name ?? ''),
                                            onTap: () {
                                              onSelected(option);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              onSelected: (Sales customer) {
                                controller.selectedSalesHandle(customer);
                                // controller.showSuffixClear.value = true;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 50),
                        const DatePickerWidget(),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey[100]),
                  cartItems.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          controller: controller.scrollController,
                          itemCount: cartItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = cartItems[index];
                            final discountTextC = TextEditingController();
                            discountTextC.text =
                                currency.format(item.individualDiscount.value);
                            discountTextC.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: discountTextC.text.length),
                            );

                            final costPriceTextC = TextEditingController();
                            costPriceTextC.text =
                                currency.format(item.individualDiscount.value);
                            costPriceTextC.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: costPriceTextC.text.length),
                            );
                            return CartItemWidget(
                              item: item,
                              controller: controller,
                              index: index,
                              // qtyTextC: qtyTextC,
                              costPriceTextC: costPriceTextC,
                              discountTextC: discountTextC,
                            );
                          },
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Barang yang Anda klik akan ditampilkan di sini.',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey),
                          ),
                        ),
                  Divider(color: Colors.grey[100]),
                  cartItems.isNotEmpty
                      ?
                      // Obx(
                      //     () =>
                      SizedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: CalculatePrice(controller: controller),
                              ),
                            ],
                          ),
                        )
                      // ) //* 2.0 CalculatePrice
                      : const SizedBox(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

//* 1.0 SelectedProductList ==================================================================
// class SelectedProductList extends StatelessWidget {
//   const SelectedProductList({
//     super.key,
//     // required this.cartItems,
//     required this.formatter,
//     required this.controller,
//   });

//   // final List<CartItem> cartItems;
//   final NumberFormat formatter;
//   final HomeController controller;

//   @override
//   Widget build(BuildContext context) {
//     final cartItems = controller.cart.value.items;
//     return ListView.builder(
//       controller: controller.scrollController,
//       itemCount: cartItems.length,
//       itemBuilder: (BuildContext context, int index) {
//         final cartItem = cartItems[index];
//         final qty = TextEditingController();
//         qty.text = '${cartItem.quantity.value}';
//         qty.selection = TextSelection.fromPosition(
//           TextPosition(offset: qty.text.length),
//         );

//         final discount = TextEditingController();
//         discount.text = formatter.format(cartItem.individualDiscount.value);
//         discount.selection = TextSelection.fromPosition(
//           TextPosition(offset: discount.text.length),
//         );

//         return CartItemWidget(cartItem: cartItem, controller: controller, formatter: formatter, qty: qty, discount: discount);
//       },
//     );
//   }
// }

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.item,
    required this.controller,
    required this.index,
    required this.costPriceTextC,
    required this.discountTextC,
  });

  final CartItem item;
  final BuyProductController controller;
  final int index;
  final TextEditingController costPriceTextC;
  final TextEditingController discountTextC;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final qtyTextC = TextEditingController();
        String displayValue = item.quantity.value % 1 == 0
            ? item.quantity.value.toInt().toString()
            : item.quantity.value.toString().replaceAll('.', ',');
        qtyTextC.text = displayValue;
        qtyTextC.selection = TextSelection.fromPosition(
          TextPosition(offset: qtyTextC.text.length),
        );

        final costPriceTextC = TextEditingController();
        costPriceTextC.text = currency.format(item.product.costPrice.value);
        costPriceTextC.selection = TextSelection.fromPosition(
          TextPosition(offset: costPriceTextC.text.length),
        );

        // int getPrice = item.getPrice(controller.priceType.value);
        // int sellPrice = getPrice != 0 ? getPrice : item.product.sellPrice1;
        return ListTile(
          tileColor: index.isEven ? Colors.grey[100] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          title: Row(
            children: [
              Expanded(
                child: SizedBox(
                  child: Text(
                    '${index + 1}. ${item.product.productName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: IconButton(
                  onPressed: () => controller.removeFromCart(item),
                  icon: const Icon(
                    Symbols.close,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                flex: 6,
                child: SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: CostPriceTextField(
                          // salesInvoice: salesInvoice,
                          costPriceTextC: costPriceTextC,
                          controller: controller,
                          item: item,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded(
              //   flex: 5,
              //   child: SizedBox(
              //     child: Text(
              //       'Rp${controller.currency.format(item.product.costPrice)}',
              //       style: context.textTheme.bodyMedium,
              //     ),
              //   ),
              // ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: QuantityTextField(
                          qtyTextC: qtyTextC,
                          controller: controller,
                          item: item,
                        ), //* 1.1 QuantityTextField
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: DiscountTextfield(
                          discountTextC: discountTextC,
                          controller: controller,
                          item: item,
                        ), //* 1.1 QuantityTextField
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp${currency.format(item.product.costPrice * item.quantity.value - item.individualDiscount.value)}',
                        style: context.textTheme.titleMedium,
                      ),
                      if (item.individualDiscount.value > 0)
                        Text(
                          'Rp${currency.format(item.product.costPrice * item.quantity.value)}',
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
        );
      },
    );
  }
}

//* 1.1 QuantityTextField ==================================================================
class QuantityTextField extends StatelessWidget {
  const QuantityTextField({
    super.key,
    required this.qtyTextC,
    required this.controller,
    required this.item,
  });

  final TextEditingController qtyTextC;
  final BuyProductController controller;
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: qtyTextC,
        textAlign: TextAlign.center,
        maxLength: 7,
        decoration: InputDecoration(
          labelText: 'Jumlah',
          labelStyle: context.textTheme.bodySmall!
              .copyWith(fontStyle: FontStyle.italic),
          prefixText: 'x',
          counterText: '',
          suffixText: item.product.unit,
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
            controller.quantityHandle(item, processedValue);
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
    required this.discountTextC,
    required this.controller,
    required this.item,
  });

  final TextEditingController discountTextC;
  final BuyProductController controller;
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: discountTextC,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: 'Discount',
          labelStyle: context.textTheme.bodySmall!
              .copyWith(fontStyle: FontStyle.italic),
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
          // value == '' ? 0 : value;
          // discount.text = value;
          controller.discountHandle(item.product.id, discountTextC, value);
        });
  }
}

//* 1.2 costPriceTextField ==================================================================
class CostPriceTextField extends StatelessWidget {
  const CostPriceTextField({
    super.key,
    // required this.salesInvoice,
    required this.costPriceTextC,
    required this.controller,
    required this.item,
  });

// final SalesInvoice salesInvoice;
  final TextEditingController costPriceTextC;
  final BuyProductController controller;
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: costPriceTextC,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: 'Harga Sales',
          labelStyle: context.textTheme.bodySmall!
              .copyWith(fontStyle: FontStyle.italic),
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
          item.product.costPrice.value =
              value == '' ? 0 : double.parse(value.replaceAll('.', ''));
          // item.
          // value == '' ? 0 : value;
          // discount.text = value;
          // controller.costPriceHandle(item.product.id, costPriceTextC, value);
        });
  }
}

//* 2.0 CalculatePrice ==================================================================
class CalculatePrice extends StatelessWidget {
  const CalculatePrice({
    super.key,
    required this.controller,
  });

  final BuyProductController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Obx(
              () {
                final cart = controller.cart.value;
                final cartItems = cart.items;
                return SizedBox(
                  // color: Colors.amber,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PropertiesRowWidget(
                        title: 'Total Harga (${cartItems.length} Barang)',
                        value: currency.format(
                          cart.getSubTotalCost(),
                        ),
                      ),
                      if (controller.totalDiscount.value > 0)
                        PropertiesRowWidget(
                          title: 'Total Diskon',
                          value:
                              '-${currency.format(cart.totalIndividualDiscount)}',
                          // value:
                          //     '-${controller.currency.format(controller.totalDiscount.value)}',
                        ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text('Total Pembelian:',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Text(
                              'Rp${currency.format(cart.getTotalCost())}',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                onPressed: controller.nomorInvoice.value != ''
                                    ? () async {
                                        if (!controller.isComa.value) {
                                          if (controller.totalBill > 0) {
                                            SalesInvoice invoice =
                                                await controller
                                                    .createInvoice();

                                            invoice.updateIsDebtPaid();
                                            if (context.mounted) {
                                              salesPaymentDialog(
                                                  context,
                                                  invoice,
                                                  controller
                                                      .updatedStockProducts);
                                            }
                                            // await controller.saveInvoice();
                                            // controller.asignPayment();
                                            // paymentDialog(context, invo);
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
                                        } else {
                                          Get.defaultDialog(
                                            title: 'Error',
                                            middleText:
                                                'Jumlah yang dimasukkan tidak valid.',
                                          );
                                        }
                                      }
                                    : null,
                                child: const Text('Pilih Pembayaran')),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
