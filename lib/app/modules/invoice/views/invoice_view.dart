import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

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
                child: ProductListCard(
                    controller: controller, formatter: formatter),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                foundInvoice.change! <= 0 ? Colors.red[100] : Colors.green[100],
            child: InkWell(
              splashColor: foundInvoice.change! <= 0
                  ? Colors.red[200]!.withOpacity(0.2)
                  : Colors.green[200]!.withOpacity(0.3),
              highlightColor: foundInvoice.change! <= 0
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
                              DateFormat('dd MMMM y HH:mm', 'id')
                                  .format(foundInvoice.createdAt!),
                              style: context.theme.textTheme.bodySmall),
                        ),
                        foundInvoice.change! <= 0
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
                                cart!.product!.sellPrice! * cart.quantity!;
                            if (index < crossAxisCount) {
                              return ListTile(
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
                                        'Rp. ${formatter.format(foundInvoice.productsCart?.cartList![index].product!.sellPrice)}',
                                        style:
                                            context.theme.textTheme.bodySmall,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 70,
                                      child: Text('   x   ${cart.quantity}   =',
                                          style: context
                                              .theme.textTheme.bodySmall),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        'Rp. ${formatter.format(totalPrice)}',
                                        style:
                                            context.theme.textTheme.bodySmall,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
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
                                  foundInvoice.change! <= 0
                                      ? 'Belum Lunas'
                                      : 'Lunas',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.theme.textTheme.bodySmall!
                                      .copyWith(
                                          color: foundInvoice.change! <= 0
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
  Get.defaultDialog(
    title: 'Invoice',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (2 / 3),
      width: MediaQuery.of(context).size.width * (6 / 10),
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
                          Text(invoice!.invoiceId!,
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
                          children: [
                            Text('UNTUK',
                                style: context.theme.textTheme.bodyLarge),
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
                                DateFormat('dd MMMM y', 'id').format(
                                  invoice.createdAt!,
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
                          child: Text(
                            'Rp. ${formatter.format(cart.product!.sellPrice! * cart.quantity!)}',
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
                        flex: 2,
                        child: Text('TOTAL TAGIHAN',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.right)),
                    const Expanded(
                        flex: 2, child: Text('', textAlign: TextAlign.right)),
                    Expanded(
                        flex: 2,
                        child: Text('Rp. ${formatter.format(invoice.bill)}',
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.end)),
                  ],
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              invoice.change! > 0 ? Colors.green : Colors.red),
                      child: invoice.change! > 0
                          ? Text(
                              'LUNAS',
                              style: context.textTheme.bodyMedium!
                                  .copyWith(color: Colors.white),
                            )
                          : Text(
                              'BELUM DI BAYAR',
                              style: context.textTheme.bodyMedium!
                                  .copyWith(color: Colors.white),
                            ),
                    ),
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
