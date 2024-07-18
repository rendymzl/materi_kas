import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:materi_kas/app/routes/app_pages.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/models/cart_model.dart';
// import '../../../data/models/customer_model.dart';
import '../../../widget/customer_input_field_widget.dart';
import '../../../widget/side_menu_widget.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nama Toko'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F8FF),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Get.toNamed(Routes.PRODUCT);
          //   },
          //   icon: const Icon(Symbols.box),
          // ),
          // IconButton(
          //   onPressed: () {
          //     Get.toNamed(Routes.INVOICE);
          //   },
          //   icon: const Icon(Symbols.document_scanner),
          // ),
          IconButton(
            onPressed: () async {
              Get.defaultDialog(
                title: 'Logout?',
                middleText: 'Logout akun?',
                confirm: TextButton(
                  onPressed: () => controller.signOut(),
                  child: const Text('Logout'),
                ),
                cancel: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal'),
                ),
              );
            },
            icon: const Icon(Symbols.logout),
          ),
        ],
      ),
      body: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SideMenuWidget(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: ProductListCard(controller: controller)),
                    const CustomerInputField(),
                  ],
                ), //! 1 ProductListCard
              ),
              Expanded(
                child: SelectedProductCard(
                    controller: controller, formatter: formatter),
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
    // required this.formatter,
  });

  final HomeController controller;
  // final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
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
                            foundProducts.productId!,
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                        title: Text(
                          '${foundProducts.productName}',
                          style: context.textTheme.titleLarge,
                        ),
                        trailing: Text(
                          'Rp. ${controller.numberFormat.format(foundProducts.sellPrice)}',
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
      ),
    );
  }
}

// class CustomerInputField extends StatelessWidget {
//   const CustomerInputField({
//     super.key,
//     required this.controller,
//   });

//   final HomeController controller;

//   @override
//   Widget build(BuildContext context) {
//     OutlineInputBorder outlineRed =
//         const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
//     return Card(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         height: 250,
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: const BorderRadius.all(
//                   Radius.circular(12),
//                 ),
//               ),
//               child: Autocomplete<Customer>(
//                 optionsBuilder: (TextEditingValue customerTextC) {
//                   if (customerTextC.text.isEmpty) {
//                     return const Iterable<Customer>.empty();
//                   } else {
//                     return controller.customers.where((Customer customer) {
//                       final String customerName =
//                           customer.name?.toLowerCase() ?? '';
//                       final String input = customerTextC.text.toLowerCase();
//                       return customerName.contains(input);
//                     });
//                   }
//                 },
//                 displayStringForOption: (Customer customer) =>
//                     customer.name ?? '',
//                 fieldViewBuilder: (BuildContext context,
//                     TextEditingController textEditingController,
//                     FocusNode focusNode,
//                     VoidCallback onFieldSubmitted) {
//                   return TextField(
//                     controller: textEditingController,
//                     focusNode: focusNode,
//                     onSubmitted: (String value) {
//                       onFieldSubmitted();
//                     },
//                     decoration: const InputDecoration(
//                       labelText: "Cari Pelanggan",
//                       labelStyle: TextStyle(color: Colors.grey),
//                       prefixIcon: Icon(Symbols.search),
//                       border: InputBorder.none,
//                     ),
//                   );
//                 },
//                 optionsViewBuilder: (BuildContext context,
//                     AutocompleteOnSelected<Customer> onSelected,
//                     Iterable<Customer> options) {
//                   final int optionsLength = options.length;
//                   const double itemHeight = 56.0;
//                   final double maxHeight = itemHeight * optionsLength;

//                   return Align(
//                     alignment: Alignment.topLeft,
//                     child: Material(
//                       elevation: 4.0,
//                       child: SizedBox(
//                         width: 400.0,
//                         height: maxHeight > 150 ? 150 : maxHeight,
//                         child: ListView.builder(
//                           padding: const EdgeInsets.all(8.0),
//                           itemCount: optionsLength,
//                           itemBuilder: (BuildContext context, int index) {
//                             final Customer option = options.elementAt(index);
//                             return ListTile(
//                               title: Text(option.name ?? ''),
//                               onTap: () {
//                                 onSelected(option);
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//                 onSelected: (Customer customer) {
//                   controller.asignCustomer(customer);
//                 },
//               ),
//             ),
//             const SizedBox(height: 5),
//             Expanded(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: TextField(
//                         controller: controller.customerNameController,
//                         decoration: InputDecoration(
//                           border: const OutlineInputBorder(),
//                           labelText: 'Nama Pelanggan',
//                           labelStyle: const TextStyle(color: Colors.grey),
//                           floatingLabelStyle: TextStyle(
//                               color: Theme.of(context).colorScheme.primary),
//                           focusedErrorBorder: outlineRed,
//                           errorBorder: outlineRed,
//                         ),
//                         onChanged: (value) {
//                           controller.customerNameController.text = value;
//                           controller.displayName.value = value;
//                         }),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     flex: 2,
//                     child: TextField(
//                       controller: controller.customerPhoneController,
//                       decoration: InputDecoration(
//                         border: const OutlineInputBorder(),
//                         labelText: 'No. Telp',
//                         labelStyle: const TextStyle(color: Colors.grey),
//                         floatingLabelStyle: TextStyle(
//                             color: Theme.of(context).colorScheme.primary),
//                         focusedErrorBorder: outlineRed,
//                         errorBorder: outlineRed,
//                       ),
//                       keyboardType:
//                           const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
//                       ],
//                       onChanged: (value) =>
//                           controller.customerPhoneController.text = value,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               flex: 2,
//               child: TextField(
//                 controller: controller.customerAddressController,
//                 minLines: 3,
//                 maxLines: 5,
//                 decoration: InputDecoration(
//                   border: const OutlineInputBorder(),
//                   labelText: 'Alamat',
//                   alignLabelWithHint: true,
//                   labelStyle: const TextStyle(color: Colors.grey),
//                   floatingLabelStyle:
//                       TextStyle(color: Theme.of(context).colorScheme.primary),
//                   focusedErrorBorder: outlineRed,
//                   errorBorder: outlineRed,
//                 ),
//                 onChanged: (value) =>
//                     controller.customerAddressController.text = value,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//! 2 SelectedProductCard ==================================================================
class SelectedProductCard extends StatelessWidget {
  const SelectedProductCard({
    super.key,
    required this.controller,
    required this.formatter,
  });

  final HomeController controller;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: 500,
      child: Column(
        children: [
          Expanded(
            child: Card(
              child: Obx(
                () {
                  final cartList = controller.purchaseList;
                  controller.totalPrice.value = 0;
                  controller.totalDiscount.value = 0;
                  for (var item in cartList) {
                    controller.totalPrice.value +=
                        (item.product!.sellPrice! * item.quantity! -
                            item.individualDiscount!);

                    controller.totalDiscount.value += item.individualDiscount!;
                  }

                  TimeOfDay selectedTime = controller.selectedTime.value;
                  DateTime convertedTime = DateTime(
                      2024, 1, 1, selectedTime.hour, selectedTime.minute);
                  return Column(
                    children: [
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => controller.dateTimeCheckBox(),
                              child: SizedBox(
                                child: Row(
                                  children: [
                                    Checkbox(
                                        value: controller.isDateTimeNow.value,
                                        onChanged: (value) =>
                                            controller.dateTimeCheckBox()),
                                    Text(
                                      'Tanggal Invoice saat ini',
                                      style: controller.isDateTimeNow.value
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
                            Row(
                              children: [
                                InkWell(
                                  onTap: controller.isDateTimeNow.value
                                      ? null
                                      : () async =>
                                          controller.handleDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: controller.isDateTimeNow.value
                                          ? Colors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      controller.displayDate.value == ''
                                          ? 'Pilih Tanggal'
                                          : DateFormat('dd MMMM y', 'id')
                                              .format(controller
                                                  .selectedDate.value),
                                      style: controller.isDateTimeNow.value
                                          ? context.textTheme.bodySmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontStyle: FontStyle.italic,
                                            )
                                          : const TextStyle(
                                              color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                InkWell(
                                  onTap: controller.isDateTimeNow.value
                                      ? null
                                      : () async =>
                                          controller.handleTime(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: controller.isDateTimeNow.value
                                          ? Colors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      controller.displayTime.value == ''
                                          ? 'Pilih Jam'
                                          : DateFormat('HH:mm', 'id')
                                              .format(convertedTime),
                                      style: controller.isDateTimeNow.value
                                          ? context.textTheme.bodySmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontStyle: FontStyle.italic,
                                            )
                                          : const TextStyle(
                                              color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      controller.purchaseList.isNotEmpty
                          ? Expanded(
                              flex: 10,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: SelectedProductList(
                                  cartList: cartList,
                                  formatter: formatter,
                                  controller: controller,
                                ),
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
                      controller.purchaseList.isNotEmpty
                          ? SizedBox(
                              height: 250,
                              child: Obx(
                                () => Container(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            controller.displayName.value
                                                .toUpperCase(),
                                            style: context.textTheme.bodySmall!
                                                .copyWith(
                                                    fontStyle:
                                                        FontStyle.italic),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          // Text(
                                          //   controller.invoiceId.value,
                                          //   style: context
                                          //       .textTheme.bodySmall!
                                          //       .copyWith(
                                          //           fontStyle:
                                          //               FontStyle.italic),
                                          // ),
                                        ],
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: CalculatePrice(
                                            formatter: formatter,
                                            controller: controller),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ) //* 2.0 CalculatePrice
                          : const SizedBox(),
                    ],
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

//* 1.0 SelectedProductList ==================================================================
class SelectedProductList extends StatelessWidget {
  const SelectedProductList({
    super.key,
    required this.cartList,
    required this.formatter,
    required this.controller,
  });

  final RxList<Cart> cartList;
  final NumberFormat formatter;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller.scrollController,
      itemCount: cartList.length,
      itemBuilder: (BuildContext context, int index) {
        final productCart = cartList[index];
        final qty = TextEditingController();
        qty.text = '${productCart.quantity}';
        qty.selection = TextSelection.fromPosition(
          TextPosition(offset: qty.text.length),
        );

        final discount = TextEditingController();
        discount.text = formatter.format(productCart.individualDiscount);
        discount.selection = TextSelection.fromPosition(
          TextPosition(offset: discount.text.length),
        );

        return SizedBox(
          child: ListTile(
            tileColor: index.isEven ? Colors.white : Colors.grey[100],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            title: Row(
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
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: IconButton(
                    onPressed: () => controller.removeFromCart(productCart),
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
                  flex: 4,
                  child: SizedBox(
                    child: Text(
                      'Rp. ${formatter.format(productCart.product!.sellPrice)}',
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    child: Row(
                      children: [
                        Expanded(
                          child: QuantityTextField(
                              qty: qty,
                              controller: controller,
                              productCart:
                                  productCart), //* 1.1 QuantityTextField
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
                              discount: discount,
                              controller: controller,
                              productCart:
                                  productCart), //* 1.1 QuantityTextField
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
                          'Rp. ${formatter.format(productCart.product!.sellPrice! * productCart.quantity! - productCart.individualDiscount!)}',
                          style: context.textTheme.titleMedium,
                        ),
                        if (productCart.individualDiscount! > 0)
                          Text(
                            'Rp. ${formatter.format(productCart.product!.sellPrice! * productCart.quantity!)}',
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
    required this.qty,
    required this.controller,
    required this.productCart,
  });

  final TextEditingController qty;
  final HomeController controller;
  final Cart productCart;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: qty,
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
          value == '' ? 0 : value;
          qty.text = value;
          controller.quantityHandle(productCart, value);
        });
  }
}

//* 1.2 discountTextfield ==================================================================
class DiscountTextfield extends StatelessWidget {
  const DiscountTextfield({
    super.key,
    required this.discount,
    required this.controller,
    required this.productCart,
  });

  final TextEditingController discount;
  final HomeController controller;
  final Cart productCart;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: discount,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: 'Discount',
          labelStyle: context.textTheme.bodySmall!
              .copyWith(fontStyle: FontStyle.italic),
          prefixText: 'Rp. ',
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
          controller.discountHandle(productCart, discount, value);
        });
  }
}

//* 2.0 CalculatePrice ==================================================================
class CalculatePrice extends StatelessWidget {
  const CalculatePrice({
    super.key,
    required this.formatter,
    required this.controller,
  });

  final HomeController controller;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(
                        width: 150,
                        child: Text('TAGIHAN:',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Row(
                          children: [
                            if (controller.totalDiscount.value > 0)
                              Text(
                                'Rp.${formatter.format(controller.totalDiscount.value + controller.totalPrice.value)}',
                                style: context.textTheme.bodySmall!.copyWith(
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            const SizedBox(width: 16),
                            Text(
                              'Rp.${formatter.format(controller.totalPrice.value)}',
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
                            controller: controller.pay,
                            decoration: const InputDecoration(
                              prefixIcon: Text('Rp. ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              prefixIconConstraints:
                                  BoxConstraints(minWidth: 0, minHeight: 0),
                              hintText: '0',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
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
                  const SizedBox(height: 5),
                  Obx(
                    () {
                      int change = controller.moneyChange.value -
                          controller.totalPrice.value;
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
                                    formatter.format(change),
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
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () async {
                              if (controller.totalPrice > 0) {
                                await controller.saveInvoice();
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
                            child: const Text('Simpan Invoice')),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
