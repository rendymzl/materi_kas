import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materi_kas/app/routes/app_pages.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/models/cart_model.dart';
import '../../../data/models/customer_model.dart';
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
                child: ProductListCard(
                    controller: controller,
                    formatter: formatter), //! 1 ProductListCard
              ),
              SelectedProductCard(
                  controller: controller,
                  formatter: formatter), //! 2 SelectedProductCard
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
    required this.formatter,
  });

  final HomeController controller;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: "Cari Barang",
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Symbols.search),
                ),
                onChanged: (value) => controller.filterProducts(value),
              ),
              Expanded(
                child: Obx(
                  () => Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: ListView.builder(
                            itemCount: controller.foundProducts.length,
                            itemBuilder: (BuildContext context, int index) {
                              final foundProducts =
                                  controller.foundProducts[index];
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    horizontal:
                                        BorderSide(color: Colors.grey[200]!),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Text(
                                    foundProducts.productId!,
                                    style: context.textTheme.bodySmall,
                                  ),
                                  title: Text(
                                    '${foundProducts.productName}',
                                    style: context.textTheme.titleLarge,
                                  ),
                                  trailing: Text(
                                    'Rp. ${formatter.format(foundProducts.sellPrice)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onTap: () =>
                                      controller.addToCart(foundProducts),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // const Divider(color: Colors.grey),
                      Container(
                        color: Colors.white,
                        height: 170,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomerData(controller: controller),
                          ],
                        ),
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
  }
}

class CustomerData extends StatelessWidget {
  const CustomerData({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder outlineRed =
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                            controller: controller.customerNameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Nama',
                              labelStyle: const TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                              focusedErrorBorder: outlineRed,
                              errorBorder: outlineRed,
                            ),
                            onChanged: (value) {
                              controller.handleCustomer(value);
                              controller.displayName.value = value;
                            }),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: controller.customerPhoneController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'No. Telp',
                            labelStyle: const TextStyle(color: Colors.grey),
                            floatingLabelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                            focusedErrorBorder: outlineRed,
                            errorBorder: outlineRed,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                          onChanged: (value) =>
                              controller.handleCustomer(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => controller.handleCheckBox(null),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Checkbox(
                                  value: controller.isRegisteredCustomer.value,
                                  onChanged: (value) =>
                                      controller.handleCheckBox(value)),
                              Text(
                                'Customer terdaftar  ',
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.isRegisteredCustomer.value)
                        dropdownMenu(controller, context),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller.customerAddressController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Alamat',
                  alignLabelWithHint: true,
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                ),
                onChanged: (value) => controller.handleCustomer(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget dropdownMenu(HomeController controller, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
    ),
    child: DropdownButton<Customer>(
      icon: const Icon(Icons.arrow_drop_down),
      hint: Text(
        'Pilih Customer',
        style: context.textTheme.bodySmall,
      ),
      dropdownColor: Colors.white,
      value: controller.selectedCustomer.value,
      onChanged: (Customer? selectedCustomer) {
        controller.selectedCustomer.value = selectedCustomer;
        controller.customerNameController.text = selectedCustomer!.name!;
        controller.customerPhoneController.text = selectedCustomer.phone!;
        controller.customerAddressController.text = selectedCustomer.address!;
        controller.displayName.value = selectedCustomer.name!;
      },
      items: controller.customers.map((customer) {
        return DropdownMenuItem<Customer>(
          value: customer,
          child: Text(customer.name!),
        );
      }).toList(),
    ),
  );
}

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
      width: 380,
      child: Column(
        children: [
          Expanded(
            child: Card(
              child: Obx(
                () {
                  final cartList = controller.cartList;
                  controller.totalPrice.value = 0;
                  for (var item in cartList) {
                    controller.totalPrice.value +=
                        (item.product!.sellPrice! * item.quantity!);
                  }
                  return Column(
                    children: [
                      Container(
                        height: 12,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      controller.cartList.isNotEmpty
                          ? Expanded(
                              flex: 8,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: SelectedProductList(
                                    cartList: cartList,
                                    formatter: formatter,
                                    controller: controller),
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
                      controller.cartList.isNotEmpty
                          ? Expanded(
                              flex: 7,
                              child: Obx(
                                () => Container(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              controller.displayName.value
                                                  .toUpperCase(),
                                              style: context
                                                  .textTheme.bodySmall!
                                                  .copyWith(
                                                      fontStyle:
                                                          FontStyle.italic),
                                            ),
                                            Text(
                                              controller.invoiceId.value,
                                              style: context
                                                  .textTheme.bodySmall!
                                                  .copyWith(
                                                      fontStyle:
                                                          FontStyle.italic),
                                            ),
                                          ],
                                        ),
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
                        // const Text(' = ')
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: SizedBox(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Rp. ${formatter.format(productCart.product!.sellPrice! * productCart.quantity!)}',
                        style: context.textTheme.titleMedium,
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text('Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Rp. ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: Text(
                                formatter.format(controller.totalPrice.value),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text('Kembalian',
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
                                child: Obx(
                                  () => Text(
                                    formatter.format(
                                        controller.moneyChange.value -
                                            controller.totalPrice.value),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      )
                    ],
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
