import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../main.dart';
import '../../../data/models/sales_invoice_model.dart';
import '../../../widget/add_sales_customer.dart';
import '../../../widget/side_menu_widget.dart';
import '../../product/views/buy_product_dialog.dart';
import '../controllers/sales_controller.dart';
import 'sales_invoice_detail_dialog.dart';

class SalesView extends GetView<SalesController> {
  const SalesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const SideMenuWidget(title: 'Sales'),
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
                child: SalesListCard(
                  controller: controller,
                ), //! 1 SalesListCard
              ),
              Expanded(
                flex: 5,
                child: SelectedSalesInvoiceCard(
                  controller: controller,
                ),
              ), //! 2 SelectedSalesInvoiceCard
            ],
          ),
        ),
      ),
    );
  }
}

//! 1 SalesListCard ==================================================================
class SalesListCard extends StatelessWidget {
  const SalesListCard({
    super.key,
    required this.controller,
    // required this.formatter,
  });

  final SalesController controller;
  // final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
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
                          labelText: "Cari Sales",
                          labelStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Symbols.search),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) => controller.filterSales(value),
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
                      onPressed: () => addEditSalesDialog(context, null),
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
                () {
                  var sales = controller.foundSalesCustomer;
                  return ListView.builder(
                    itemCount: sales.length,
                    itemBuilder: (BuildContext context, int index) {
                      var foundSales = sales[index];
                      // var selectedSales = controller.selectedSales.value;

                      // int getPrice =
                      //     foundSales.getPrice(controller.priceType.value);
                      // int sellPrice = getPrice.toInt() != 0
                      //     ? getPrice
                      //     : foundSales.sellPrice1;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Obx(
                          () => ListTile(
                            selected:
                                foundSales == controller.selectedSales.value,
                            selectedTileColor: Colors.grey[100],
                            // tileColor:
                            //     foundSales.totalDebt > 0 ? Colors.red[100] : null,
                            // leading: SizedBox(
                            //   width: 60,
                            //   child: Text(
                            //     foundSales.,
                            //     style: context.textTheme.bodySmall,
                            //   ),
                            // ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  foundSales.name!,
                                  style: context.textTheme.titleLarge,
                                ),
                                if (foundSales.getTotalDebt(
                                        controller.salesInvoices) >
                                    0)
                                  Text(
                                    'Hutang Rp${currency.format(foundSales.getTotalDebt(controller.salesInvoices))}',
                                    style: context.textTheme.bodySmall!
                                        .copyWith(
                                            color: Colors.red,
                                            fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                            subtitle: foundSales.phone != null
                                ? Text(
                                    foundSales.phone ?? '',
                                    style: context.textTheme.bodySmall,
                                  )
                                : null,
                            trailing: const Icon(Symbols.arrow_right),
                            //  totalDebt > 0
                            //     ? Text(
                            //         totalDebt ?? '',
                            //         style: context.textTheme.titleLarge,
                            //       )
                            //     : null,
                            onTap: () =>
                                controller.selectedSalesHandle(foundSales),
                          ),
                        ),
                      );
                    },
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

//! 2 SelectedSalesInvoiceCard ==================================================================
class SelectedSalesInvoiceCard extends StatelessWidget {
  const SelectedSalesInvoiceCard({
    super.key,
    required this.controller,
  });

  final SalesController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(
          () {
            List<SalesInvoice> invoiceById =
                controller.selectedSales.value != null
                    ? controller.selectedSales.value!
                        .getInvoiceListBySalesId(controller.salesInvoices)
                    : [];

            // String totalDebt = controller.selectedSales.value != null
            //     ? 'Rp${currency.format(controller.selectedSales.value!.getTotalDebt(controller.salesInvoices))}'
            //     : '';

            String totalInvoice = controller.selectedSales.value != null
                ? 'Total Invoice ${controller.selectedSales.value!.getInvoiceListBySalesId(controller.salesInvoices).length}'
                : '';
            return controller.selectedSales.value != null
                ? Column(
                    children: [
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(totalInvoice),
                            Text(
                              controller.selectedSales.value!.name!,
                              style: context.textTheme.titleLarge!,
                            ),
                            IconButton(
                              onPressed: () => controller.destroySales(
                                  controller.selectedSales.value!),
                              icon: const Icon(
                                Symbols.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey[300]),
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          shrinkWrap: true,
                          itemCount: invoiceById.length,
                          itemBuilder: (BuildContext context, int index) {
                            String invoiceId =
                                invoiceById[index].invoiceId != null
                                    ? invoiceById[index].invoiceId!
                                    : '';

                            String invoiceCreatedAt =
                                invoiceById[index].createdAt.value != null
                                    ? DateFormat('dd MMM', 'id').format(
                                        invoiceById[index]
                                            .createdAt
                                            .value!
                                            .toDate())
                                    : '';
                            double remainingDebt =
                                invoiceById[index].remainingDebt;

                            return Card(
                              color: remainingDebt > 0
                                  ? Colors.red[100]
                                  : Colors.green[100],
                              child: ListTile(
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(invoiceCreatedAt),
                                          Text(invoiceId),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: invoiceById[index]
                                                .purchaseList
                                                .value
                                                .items
                                                .length,
                                            itemBuilder: (context, i) {
                                              return Text(
                                                  '- ${invoiceById[index].purchaseList.value.items[i].product.productName}');
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (remainingDebt > 0)
                                            Text(
                                              'Rp${currency.format(remainingDebt)}',
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () => detailDialogInvoiceSales(
                                    context, controller, invoiceById[index]),
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => buyProductDialog(
                                context,
                                controller.selectedSales.value,
                              ),
                              child: const Text('Beli Barang'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => addEditSalesDialog(
                                  context, controller.selectedSales.value),
                              child: const Text('Edit Sales'),
                            ),
                            // const SizedBox(width: 12),
                            // if (totalDebt != 'Rp0')
                            //   ElevatedButton(
                            //     onPressed: () {},
                            //     child: Text('Bayar Hutang $totalDebt'),
                            //   ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text('Sales yang dipilih akan ditampilkan disini'));
          },
        ),
      ),
    );
  }
}
