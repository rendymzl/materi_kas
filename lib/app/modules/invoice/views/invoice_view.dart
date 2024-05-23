import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/models/cart_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../widget/side_menu_widget.dart';
import '../controllers/invoice_controller.dart';

class InvoiceView extends GetView<InvoiceController> {
  const InvoiceView({super.key});
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Text('Invoice'),
        centerTitle: true,
      ),
      body: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SideMenuWidget(),
              Expanded(
                flex: 13,
                child: InvoiceGridCard(
                    controller: controller, formatter: formatter),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceGridCard extends StatelessWidget {
  const InvoiceGridCard({
    super.key,
    required this.controller,
    required this.formatter,
  });

  final InvoiceController controller;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // TextField(
            //   decoration: const InputDecoration(
            //     labelText: "Cari Barang",
            //     labelStyle: TextStyle(color: Colors.grey),
            //     suffixIcon: Icon(Symbols.search),
            //   ),
            //   onChanged: (value) => controller.filterInvoices(value),
            // ),
            Expanded(
              flex: 10,
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return BuildGridView(
                      controller: controller,
                      formatter: formatter,
                      crossAxisCount: 1);
                }
                if (constraints.maxWidth < 1200) {
                  return BuildGridView(
                      controller: controller,
                      formatter: formatter,
                      crossAxisCount: 2);
                } else {
                  return BuildGridView(
                      controller: controller,
                      formatter: formatter,
                      crossAxisCount: 3);
                }
              }), //! Build GridView
            ),
            Expanded(
              flex: 1,
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => Text(
                        'Total invoice: ${controller.invoiceList.length.toString()}'))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//! Build GridView
class BuildGridView extends StatelessWidget {
  const BuildGridView({
    super.key,
    required this.controller,
    required this.formatter,
    required this.crossAxisCount,
  });

  final InvoiceController controller;
  final NumberFormat formatter;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 7 / 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.foundInvoices.length,
        itemBuilder: (BuildContext context, int index) {
          final foundInvoice = controller.foundInvoices[index];
          return Card(
            color:
                foundInvoice.change! < 0 ? Colors.red[100] : Colors.green[100],
            child: InkWell(
              splashColor: foundInvoice.change! < 0
                  ? Colors.red[200]!.withOpacity(0.2)
                  : Colors.green[200]!.withOpacity(0.3),
              highlightColor: foundInvoice.change! < 0
                  ? Colors.red[200]!.withOpacity(0.2)
                  : Colors.green[200]!.withOpacity(0.3),
              onTap: () =>
                  detailDialog(context, controller, foundInvoice, formatter),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(foundInvoice.invoiceId!,
                            style: context.theme.textTheme.bodySmall),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                              DateFormat('dd MMMM y HH:mm', 'id').format(
                                  foundInvoice.createdAt!
                                      .add(const Duration(hours: 7))),
                              style: context.theme.textTheme.bodySmall),
                        ),
                        foundInvoice.change! < 0
                            ? const Icon(
                                Symbols.info,
                                color: Colors.red,
                              )
                            : const Icon(
                                Symbols.check_circle,
                                color: Colors.green,
                              ),

                        // IconButton(
                        //   onPressed: () =>
                        //       controller.destroyHandle(foundInvoice),
                        //   icon: const Icon(Symbols.delete, color: Colors.red),
                        // ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Expanded(
                      child: SizedBox(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              foundInvoice.productsCart?.cartList!.length,
                          itemBuilder: (context, index) {
                            final cart =
                                foundInvoice.productsCart?.cartList![index];
                            final totalPrice =
                                cart!.product!.sellPrice! * cart.quantity! -
                                    cart.individualDiscount!;
                            var discount = '';
                            if (cart.individualDiscount != 0) {
                              discount =
                                  '(-Rp ${formatter.format(cart.individualDiscount)})';
                            }
                            if (index < crossAxisCount) {
                              return Column(
                                children: [
                                  ListTile(
                                    dense: true,
                                    title: Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          child: Text('${index + 1}. ',
                                              style: context
                                                  .theme.textTheme.bodySmall),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                              '${cart.product!.productName}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: context
                                                  .theme.textTheme.titleMedium),
                                        ),
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            'Rp ${formatter.format(foundInvoice.productsCart?.cartList![index].product!.sellPrice)}',
                                            style: context
                                                .theme.textTheme.bodySmall,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 70,
                                          child: Text(
                                              '  x   ${cart.quantity}   =',
                                              style: context
                                                  .theme.textTheme.bodySmall),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            'Rp ${formatter.format(totalPrice)}',
                                            style: context
                                                .theme.textTheme.bodySmall,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        discount,
                                        style: context
                                            .theme.textTheme.bodySmall!
                                            .copyWith(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 11),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              int remainingItemCount =
                                  (foundInvoice.productsCart!.cartList!.length -
                                      crossAxisCount);

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: index == crossAxisCount
                                    ? Text(
                                        '+ $remainingItemCount barang lainnya',
                                        style:
                                            context.theme.textTheme.bodySmall,
                                      )
                                    : const SizedBox.shrink(),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          SizedBox(
                            width: 190,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pembeli: ${foundInvoice.customer!.name!}',
                                    style: context.theme.textTheme.bodySmall),
                                Text(
                                  foundInvoice.change! < 0
                                      ? 'Belum Lunas'
                                      : 'Lunas',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.theme.textTheme.bodySmall!
                                      .copyWith(
                                          color: foundInvoice.change! < 0
                                              ? Colors.red
                                              : Colors.green),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(''),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Rp. ${formatter.format(foundInvoice.bill)}',
                              style: context.theme.textTheme.titleMedium,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
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

void detailDialog(BuildContext context, InvoiceController controller,
    Invoice? invoice, NumberFormat formatter) {
  // controller.disabledButton.value = true;
  final pay = TextEditingController();
  var charge = '';
  if (invoice!.change! > 0) {
    charge = '(Kembalian: Rp. ${formatter.format(invoice.change)})';
  }
  Get.defaultDialog(
    title: 'Invoice',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (3 / 4),
      width: MediaQuery.of(context).size.width * (9 / 10),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('INVOICE : ',
                              style: context.theme.textTheme.bodyLarge),
                          Text(invoice.invoiceId!,
                              style: context.theme.textTheme.bodyLarge!
                                  .copyWith(fontStyle: FontStyle.italic)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('DITERBITKAN ATAS NAMA',
                          style: context.theme.textTheme.bodyLarge),
                      Text('Penjual : Nama Toko',
                          style: context.theme.textTheme.bodyLarge),
                    ],
                  ),
                  SizedBox(
                    width: 450,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('UNTUK',
                                style: context.theme.textTheme.bodyLarge),
                            TextButton(
                                onPressed: () => editDialog(
                                    context, controller, invoice, formatter),
                                child: const Text('Edit Invoice'))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Pembeli'),
                                  Text(' : '),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Text(
                              invoice.customer!.name!.toUpperCase(),
                              style: context.textTheme.bodyLarge,
                            )),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('No Telp'),
                                  Text(' : '),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Text(
                              '${invoice.customer!.phone}',
                              style: context.textTheme.bodyLarge,
                            )),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tanggal Pembelian'),
                                  Text(' : '),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                DateFormat('dd MMMM y, HH:mm', 'id').format(
                                  invoice.createdAt!
                                      .add(const Duration(hours: 7)),
                                ),
                                style: context.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Alamat'),
                                  Text(' : '),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(invoice.customer!.address!),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              ListTile(
                dense: true,
                title: Row(
                  children: [
                    Expanded(
                        flex: 5,
                        child: Text('NAMA BARANG',
                            style: context.textTheme.titleLarge)),
                    Expanded(
                        flex: 2,
                        child: Text('HARGA SATUAN',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.right)),
                    Expanded(
                        flex: 2,
                        child: Text('JUMLAH',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.right)),
                    Expanded(
                        flex: 2,
                        child: Text('DISKON',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.right)),
                    Expanded(
                        flex: 3,
                        child: Text('TOTAL HARGA',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.end)),
                  ],
                ),
              ),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: invoice.productsCart!.cartList!.length,
                itemBuilder: (context, index) {
                  final cart = invoice.productsCart!.cartList![index];
                  var discount = '-';
                  if (cart.individualDiscount != 0) {
                    discount =
                        '-Rp ${formatter.format(cart.individualDiscount)}';
                  }
                  return ListTile(
                    dense: true,
                    title: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('${cart.product!.productName}'),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Rp. ${formatter.format(cart.product!.sellPrice)}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('${cart.quantity}',
                              textAlign: TextAlign.right),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(discount, textAlign: TextAlign.right),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Rp ${formatter.format(cart.product!.sellPrice! * cart.quantity! - cart.individualDiscount!)}',
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(color: Colors.grey),
              ListTile(
                dense: true,
                title: Row(
                  children: [
                    const Expanded(flex: 5, child: Text('')),
                    Expanded(
                        flex: 5,
                        child: Text('TOTAL TAGIHAN:',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.right)),
                    Expanded(
                        flex: 2,
                        child: Text('Rp. ${formatter.format(invoice.bill)}',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.end)),
                  ],
                ),
              ),
              ListTile(
                dense: true,
                title: Row(
                  children: [
                    const Expanded(flex: 5, child: Text('')),
                    Expanded(
                        flex: 5,
                        child: Text('BAYAR:',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.right)),
                    Expanded(
                        flex: 2,
                        child: Text('Rp. ${formatter.format(invoice.pay)}',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.end)),
                  ],
                ),
                subtitle: Text(charge,
                    style: context.textTheme.bodySmall!
                        .copyWith(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.end),
              ),
              if (invoice.change! < 0)
                ListTile(
                  dense: true,
                  title: Row(
                    children: [
                      const Expanded(flex: 5, child: Text('')),
                      Expanded(
                          flex: 5,
                          child: Text('TAGIHAN YANG PERLU DIBAYAR:',
                              style: context.textTheme.bodySmall!
                                  .copyWith(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.right)),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rp ${formatter.format(invoice.change! * -1)}',
                          style: context.textTheme.titleLarge!.copyWith(
                              fontStyle: FontStyle.italic, color: Colors.red),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(charge,
                      style: context.textTheme.bodySmall!
                          .copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.end),
                ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: invoice.change! >= 0
                                  ? Colors.green
                                  : Colors.red),
                          child: invoice.change! >= 0
                              ? Text(
                                  'LUNAS',
                                  style: context.textTheme.bodyMedium!
                                      .copyWith(color: Colors.white),
                                )
                              : Text(
                                  'BELUM LUNAS',
                                  style: context.textTheme.bodyMedium!
                                      .copyWith(color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                    if (invoice.change! < 0)
                      ElevatedButton(
                        onPressed: () {
                          pay.text = '';
                          controller.totalCharge.value = 0;
                          controller.showChange.value = false;
                          Get.defaultDialog(
                            title: 'Lunasi Tagihan',
                            content: Obx(
                              () => Column(
                                children: [
                                  const Text('Tagihan yang harus dibayar: '),
                                  Text(
                                    'Rp. ${formatter.format(invoice.change! * -1)}',
                                    style: context.textTheme.bodyLarge,
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                        style: context.textTheme.titleLarge,
                                        textAlign: TextAlign.right,
                                        controller: pay,
                                        decoration: InputDecoration(
                                          prefixIcon: Text(
                                            'Rp. ',
                                            style: context.textTheme.titleLarge,
                                          ),
                                          prefixIconConstraints:
                                              const BoxConstraints(
                                                  minWidth: 0, minHeight: 0),
                                          hintText: '0',
                                        ),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]'))
                                        ],
                                        onChanged: (value) {
                                          // invoice.pay = await controller.onPayChanged(value);
                                          controller.onPayChanged(
                                              value, pay, invoice);
                                        }),
                                  ),
                                  if (controller.showChange.value)
                                    Text(
                                      'Kembalian: Rp. ${formatter.format(controller.totalCharge.value)}',
                                      style: context.textTheme.bodySmall!
                                          .copyWith(
                                              fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                            ),
                            confirm: ElevatedButton(
                              onPressed: () {
                                controller.handleRepayment(invoice, pay);
                              },
                              child: const Text('BAYAR'),
                            ),
                          );
                        },
                        child: const Text(
                          'BAYAR TAGIHAN',
                        ),
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

void editDialog(BuildContext context, InvoiceController controller,
    Invoice? invoice, NumberFormat formatter) {
  controller.isRegisteredCustomer.value = false;
  controller.id.value = invoice!.id!;
  if (invoice.customer!.customerId != null) {
    controller.isRegisteredCustomer.value = true;

    controller.customerNameController.text = invoice.customer!.name!;
    controller.customerPhoneController.text = invoice.customer!.phone!;
    controller.customerAddressController.text = invoice.customer!.address!;
    controller.displayName.value = invoice.customer!.name!;
  } else {
    controller.customerNameController.text = '';
    controller.customerPhoneController.text = '';
    controller.customerAddressController.text = '';
    controller.displayName.value = '';
  }
  controller.cartList.clear();
  for (var item in invoice.productsCart!.cartList!) {
    controller.cartList.add(item);
  }
  controller.payTextController.text = formatter.format(invoice.pay);
  controller.totalCharge.value = invoice.change!;
  controller.totalPrice.value = invoice.bill!;
  controller.addProduct.value = false;

  DateTime date = DateTime(
    invoice.createdAt!.year,
    invoice.createdAt!.month,
    invoice.createdAt!.day,
  ).add(const Duration(hours: 7));

  DateTime time = DateTime(
    invoice.createdAt!.year,
    invoice.createdAt!.month,
    invoice.createdAt!.day,
    invoice.createdAt!.hour,
    invoice.createdAt!.minute,
  ).add(const Duration(hours: 7));
  controller.selectedDate.value = date;
  controller.selectedTime.value = TimeOfDay.fromDateTime(time);

  Get.defaultDialog(
    title: 'Edit Invoice ${invoice.invoiceId}',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (3 / 4),
      width: MediaQuery.of(context).size.width * (7 / 10),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomerData(controller: controller, invoice: invoice),
            const SizedBox(height: 20),
            SelectedProductCard(controller: controller, formatter: formatter),
          ],
        ),
      ),
    ),
    // onCancel: () => controller.init.value = true,
  );
}

//! 1 ProductListCard ==================================================================
class ProductListCard extends StatelessWidget {
  const ProductListCard({
    super.key,
    required this.controller,
    required this.formatter,
  });

  final InvoiceController controller;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Cari Barang",
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Symbols.search),
                ),
                onChanged: (value) => controller.filterProducts(value),
              ),
            ),
            Expanded(
              child: Obx(
                () => Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.foundProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final foundProducts = controller.foundProducts[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
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
                              onTap: () => controller.addToCart(foundProducts),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerData extends StatelessWidget {
  const CustomerData(
      {super.key, required this.controller, required this.invoice});

  final InvoiceController controller;
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder outlineRed =
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    return Obx(
      () => Card(
        child: Container(
          height: 250,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              // const Divider(),
              Row(
                children: [
                  InkWell(
                    onTap: () => controller.handleCheckBox(null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Checkbox(
                              value: controller.isRegisteredCustomer.value,
                              onChanged: (value) =>
                                  controller.handleCheckBox(value)),
                          Text(
                            'Pelanggan terdaftar  ',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (controller.isRegisteredCustomer.value)
                    dropdownMenu(controller, context, invoice),
                ],
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                          controller: controller.customerNameController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Nama Pelanggan',
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
                        onChanged: (value) => controller.handleCustomer(value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
      ),
    );
  }
}

Widget dropdownMenu(
    InvoiceController controller, BuildContext context, Invoice invoice) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: DropdownButton<Customer>(
      icon: const Icon(Icons.arrow_drop_down),
      hint: Text(
        '${invoice.customer!.name}',
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
    // required this.date,
    // required this.time,
    required this.controller,
    required this.formatter,
  });

  // final DateTime date;
  // final DateTime time;
  final InvoiceController controller;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 800,
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () {
                  final cartList = controller.cartList;
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
                        height: 60,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () async =>
                                      controller.handleDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      DateFormat('dd MMMM y', 'id').format(
                                          controller.selectedDate.value),
                                      style:
                                          const TextStyle(color: Colors.white),
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
                                      DateFormat('HH:mm', 'id')
                                          .format(convertedTime),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: SelectedProductList(
                            cartList: cartList,
                            formatter: formatter,
                            controller: controller),
                      ),
                      if (controller.addProduct.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(),
                        ),
                      if (controller.addProduct.value)
                        Expanded(
                          flex: 4,
                          child: ProductListCard(
                              controller: controller,
                              formatter: formatter), //! 1 ProductListCard
                        ),
                      if (!controller.addProduct.value)
                        ElevatedButton(
                            onPressed: () {
                              controller.addProduct.value = true;
                            },
                            child: const Text('Tambah Barang')),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(),
                      ),
                      Expanded(
                        flex: controller.addProduct.value ? 5 : 3,
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
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                                fontStyle: FontStyle.italic),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        controller.invoiceId.value,
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                                fontStyle: FontStyle.italic),
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
                      ), //* 2.0 CalculatePrice
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
  final InvoiceController controller;

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

        return Container(
          padding: const EdgeInsets.all(12),
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
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Rp. ${formatter.format(productCart.product!.sellPrice! * productCart.quantity! - productCart.individualDiscount!)}',
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
  final InvoiceController controller;
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
  final InvoiceController controller;
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

  final InvoiceController controller;
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
                              child: Row(
                                children: [
                                  if (controller.totalDiscount.value > 0)
                                    Text(
                                      '${formatter.format(controller.totalDiscount.value + controller.totalPrice.value)} - ${formatter.format(controller.totalDiscount.value)}',
                                      style: context.textTheme.bodySmall!
                                          .copyWith(
                                              fontStyle: FontStyle.italic),
                                    ),
                                  const SizedBox(width: 16),
                                  Text(
                                    formatter
                                        .format(controller.totalPrice.value),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
                            controller: controller.payTextController,
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
                            onChanged: (value) => controller.onPayHandle(value),
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
                                    formatter
                                        .format(controller.totalCharge.value),
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
                            child: const Text('Simpan Edit Invoice')),
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
