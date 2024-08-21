import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../main.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../widget/add_product.dart';
import '../../../widget/date_picker_widget.dart';
import '../../../widget/properties_row_widget.dart';
import '../../../widget/side_menu_widget.dart';
import '../../invoice/views/invoice_print.dart';
import '../controllers/home_controller.dart';
import 'payment_step.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const SideMenuWidget(title: 'Transaksi'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(child: ProductListCard(controller: controller)),
                    // const CustomerInputField(),
                  ],
                ), //! 1 ProductListCard
              ),
              Expanded(
                flex: 4,
                child: SelectedProductCard(controller: controller),
              ), //! 2 SelectedProductCard
            ],
          ),
        ),
      ),
    );
  }
}

//! 1 ProductListCard ==================================================================
class ProductListCard extends StatelessWidget {
  const ProductListCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
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
                  ),
                  const SizedBox(width: 20),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: IconButton(
                      onPressed: () => addEditDialogProduct(context, null),
                      icon: const Icon(
                        Symbols.add,
                        // size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.foundProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final foundProducts = controller.foundProducts[index];
                    double getPrice =
                        foundProducts.getPrice(controller.priceType.value);
                    double sellPrice = getPrice.toInt() != 0
                        ? getPrice
                        : foundProducts.sellPrice1;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: ListTile(
                        leading: SizedBox(
                          width: 80,
                          child: Text(
                            '${decimal.format(foundProducts.stock.value)} ${foundProducts.unit}',
                            style: context.textTheme.bodySmall,
                            // textAlign: TextAlign.right,
                          ),
                        ),
                        title: Text(
                          foundProducts.productName,
                          style: context.textTheme.titleLarge,
                        ),
                        trailing: Text(
                          'Rp ${currency.format(sellPrice)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => controller.addToCart(foundProducts),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (controller.lastInvoice.value != null)
              ElevatedButton(
                onPressed: () => printInvoiceDialog(
                  context,
                  controller.lastInvoice.value!,
                ),
                child: const Text(
                  'Cetak invoice terakhir',
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
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

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: 500,
      child: Column(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Obx(
                  () {
                    final cartItems = controller.cart.value.items;

                    // TimeOfDay selectedTime = controller.selectedTime.value;
                    // DateTime convertedTime = DateTime(
                    //     2024, 1, 1, selectedTime.hour, selectedTime.minute);
                    return Column(
                      children: [
                        Container(
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            // border: Border(
                            //   bottom: BorderSide(
                            //     color: Colors.grey[200]!,
                            //   ),
                            // ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        controller.priceTypeHandleCheckBox(2),
                                    child: SizedBox(
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value:
                                                controller.priceType.value == 2,
                                            onChanged: (value) => controller
                                                .priceTypeHandleCheckBox(2),
                                          ),
                                          Text(
                                            'Harga masuk gang',
                                            style: controller.priceType.value ==
                                                    2
                                                ? context.textTheme.bodySmall!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary)
                                                : context.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  InkWell(
                                    onTap: () =>
                                        controller.priceTypeHandleCheckBox(3),
                                    child: SizedBox(
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value:
                                                controller.priceType.value == 3,
                                            onChanged: (value) => controller
                                                .priceTypeHandleCheckBox(3),
                                          ),
                                          Text(
                                            'Harga material',
                                            style: controller.priceType.value ==
                                                    3
                                                ? context.textTheme.bodySmall!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary)
                                                : context.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const DatePickerWidget(),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey[100]),
                        cartItems.isNotEmpty
                            ? Expanded(
                                flex: 10,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  controller: controller.scrollController,
                                  itemCount: cartItems.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final item = cartItems[index];
                                    final discountTextC =
                                        TextEditingController();
                                    discountTextC.text = currency
                                        .format(item.individualDiscount.value);
                                    discountTextC.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                          offset: discountTextC.text.length),
                                    );
                                    // controller.reload.value++;
                                    return CartItemWidget(
                                      item: item,
                                      controller: controller,
                                      index: index,
                                      // qtyTextC: qtyTextC,
                                      discountTextC: discountTextC,
                                    );
                                  },
                                ),
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
                        cartItems.isNotEmpty
                            ? SizedBox(
                                child: Column(
                                  children: [
                                    Divider(color: Colors.grey[200]),
                                    Container(
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: CalculatePrice(
                                          controller: controller),
                                    ),
                                  ],
                                ),
                              ) //* 2.0 CalculatePrice
                            : const SizedBox(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.item,
    required this.controller,
    required this.index,
    required this.discountTextC,
  });

  final CartItem item;
  final HomeController controller;
  final int index;
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

        double getPrice = item.getPrice(controller.priceType.value);
        double sellPrice = getPrice != 0 ? getPrice : item.product.sellPrice1;
        return Container(
          // height: 120,
          color: index.isEven ? Colors.grey[100] : Colors.white,
          child: ListTile(
            // tileColor: index.isEven ? Colors.white : Colors.grey[100],
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${index + 1}. ${item.product.productName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
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
                  flex: 5,
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp${currency.format(sellPrice)}',
                          style: context.textTheme.bodyMedium,
                        ),
                        if (controller.priceType.value != 1 &&
                            sellPrice != item.product.sellPrice1)
                          Text(
                            'Rp${currency.format(item.product.sellPrice1)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall!.copyWith(
                                decoration: TextDecoration.lineThrough),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
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
                  flex: 5,
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
                          'Rp ${currency.format(sellPrice * item.quantity.value - item.individualDiscount.value)}',
                          style: context.textTheme.titleMedium,
                        ),
                        if (item.individualDiscount.value > 0)
                          Text(
                            'Rp ${currency.format(sellPrice * item.quantity.value)}',
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
  final HomeController controller;
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    // CartItem prevItem = CartItem.fromJson(item.toJson());
    return TextField(
      controller: qtyTextC,
      textAlign: TextAlign.center,
      // maxLength: 4,
      decoration: InputDecoration(
        labelText: 'Jumlah',
        labelStyle:
            context.textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic),
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
      },
    );
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
  final HomeController controller;
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
          prefixText: 'Rp ',
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
          controller.discountHandle(item.product.id!, discountTextC, value);
        });
  }
}

//* 2.0 CalculatePrice ==================================================================
class CalculatePrice extends StatelessWidget {
  const CalculatePrice({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Obx(
              () {
                final cart = controller.cart.value;
                final cartItems = cart.items;
                return SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PropertiesRowWidget(
                        title: 'Total Harga (${cartItems.length} Barang)',
                        value: currency.format(
                          cart.getSubtotal(controller.priceType.value),
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
                      SizedBox(
                        height: 48,
                        child: ListTile(
                          title: Row(
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
                              Text(
                                'Rp${currency.format(cart.getTotal(controller.priceType.value))}',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (!controller.isComa.value) {
                                    if (controller.totalBill > 0) {
                                      Invoice invoice =
                                          await controller.createInvoice();
                                      if (context.mounted) {
                                        paymentStep(
                                          context,
                                          invoice,
                                          controller.updatedStockProducts,
                                        );
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
                                },
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
