import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// import '../../../data/models/cart_model.dart';
// import '../../../data/models/customer_model.dart';
// import '../../../data/models/invoice_model.dart';
// import '../../../widget/customer_input_field_widget.dart';
// import '../../../widget/return_widget.dart';
import '../../../widget/side_menu_widget.dart';
import '../controllers/invoice_controller.dart';
import 'detail_dialog_widget.dart';

class InvoiceView extends GetView<InvoiceController> {
  const InvoiceView({super.key});
  @override
  Widget build(BuildContext context) {
    // final formatter = NumberFormat('#,##0', 'id_ID');
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
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: InvoiceGridCard(
                      controller: controller,
                      // formatter: formatter,
                    ),
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

class InvoiceGridCard extends StatelessWidget {
  const InvoiceGridCard({
    super.key,
    required this.controller,
    // required this.formatter,
  });

  final InvoiceController controller;
  // final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    // final formatter = NumberFormat('#,##0', 'id_ID');
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Cari Invoice (Contoh: INV001/G052824)",
                          labelStyle: TextStyle(color: Colors.grey),
                          suffixIcon: Icon(Symbols.search),
                        ),
                        onChanged: (value) => controller.filterInvoices(value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Tampilkan berdasarkan tanggal:'),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () async =>
                            controller.handleFilteredDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            controller.displayFilteredDate.value == ''
                                ? 'Pilih Tanggal'
                                : controller.displayFilteredDate.value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (controller.dateIsSelected.value)
                        TextButton(
                          onPressed: () => controller.clearHandle(),
                          child: const Text('Clear'),
                        ),
                      const SizedBox(width: 80),
                    ],
                  ),
                  Text(
                      'Total invoice: ${controller.invoices.length.toString()}')
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 10,
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return BuildGridView(
                      controller: controller,
                      // formatter: formatter,
                      crossAxisCount: 1);
                }
                if (constraints.maxWidth < 1200) {
                  return BuildGridView(
                      controller: controller,
                      // formatter: formatter,
                      crossAxisCount: 2);
                } else {
                  return BuildGridView(
                      controller: controller,
                      // formatter: formatter,
                      crossAxisCount: 3);
                }
              }),
            ), //! Build GridView
            // ),
            // Expanded(
            //   flex: 1,
            //   child: SizedBox(
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Obx(() => Text(
            //             'Total invoice: ${controller.invoiceList.length.toString()}'))
            //       ],
            //     ),
            //   ),
            // ),
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
    // required this.formatter,
    required this.crossAxisCount,
  });

  final InvoiceController controller;
  // final NumberFormat formatter;
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
          final invoice = controller.foundInvoices[index];
          return Card(
            color: !invoice.isDebtPaid ? Colors.red[100] : Colors.green[100],
            child: InkWell(
              splashColor: !invoice.isDebtPaid
                  ? Colors.red[200]!.withOpacity(0.2)
                  : Colors.green[200]!.withOpacity(0.3),
              highlightColor: !invoice.isDebtPaid
                  ? Colors.red[200]!.withOpacity(0.2)
                  : Colors.green[200]!.withOpacity(0.3),
              onTap: () async {
                await detailDialog(context, controller, invoice);
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(invoice.invoiceId!,
                            style: context.theme.textTheme.bodySmall),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                              DateFormat('dd MMMM y HH:mm', 'id')
                                  .format(invoice.createdAt!.toDate()),
                              style: context.theme.textTheme.bodySmall),
                        ),
                        !invoice.isDebtPaid
                            ? const Icon(
                                Symbols.info,
                                color: Colors.red,
                              )
                            : const Icon(
                                Symbols.check_circle,
                                color: Colors.green,
                              ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Expanded(
                      child: SizedBox(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: invoice.purchaseList.length,
                          itemBuilder: (context, index) {
                            final purchaseCart = invoice.purchaseList[index];
                            final totalPurchase =
                                purchaseCart.getTotal(invoice.priceType);
                            var discount = '';
                            if (purchaseCart.individualDiscount.value > 0) {
                              discount =
                                  '(-Rp.${controller.currency.format(purchaseCart.individualDiscount.value)})';
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
                                            purchaseCart.product.productName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context
                                                .theme.textTheme.titleMedium,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            'Rp.${controller.currency.format(purchaseCart.product.getPrice(invoice.priceType))}',
                                            style: context
                                                .theme.textTheme.bodySmall,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 70,
                                          child: Text(
                                              '  x   ${purchaseCart.quantity}   =',
                                              style: context
                                                  .theme.textTheme.bodySmall),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            'Rp.${controller.currency.format(totalPurchase)}',
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
                                  (invoice.purchaseList.length -
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
                                Text(
                                    'Pembeli: ${invoice.customer?.name ?? '-'}',
                                    style: context.theme.textTheme.bodySmall),
                                Text(
                                  !invoice.isDebtPaid
                                      ? 'Belum Lunas Rp${controller.currency.format(invoice.remainingDebt)}'
                                      : 'Lunas',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.theme.textTheme.bodySmall!
                                      .copyWith(
                                          color: !invoice.isDebtPaid
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
                              'Rp.${controller.currency.format(invoice.total)}',
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
