import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../main.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../widget/other_cost_dialog_widget.dart';
import '../../../widget/payment_dialog_widget.dart';
import '../controllers/invoice_controller.dart';
import 'edit_dialog_widget.dart';
import 'invoice_print.dart';
import 'return_dialog_widget.dart';

void detailDialog(
  BuildContext context,
  InvoiceController controller,
  Invoice invoice,
) async {
  // debugPrint(invoice.totalReturn.toString());
  controller.asignEditData(invoice);
  // var charge = '';
  // if (invoice.change! > 0) {
  //   charge = '(Kembalian: Rp${controller.currency.format(invoice.change)})';
  // }
  // debugPrint(invoice.remainingDebt.toString());
  invoice.updateIsDebtPaid();
  return Get.defaultDialog(
    title: 'Invoice',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (5 / 7),
      width: MediaQuery.of(Get.context!).size.width * (4 / 5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // color: Colors.amber,
          ),
          child: Obx(
            () {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('INVOICE: ',
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .bodyLarge),
                                Text(
                                  invoice.invoiceId!,
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: invoice.isDebtPaid.value
                                          ? Colors.green
                                          : Colors.red),
                                  child: invoice.isDebtPaid.value
                                      ? Text(
                                          'LUNAS',
                                          style: Theme.of(Get.context!)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: Colors.white),
                                        )
                                      : Text(
                                          'BELUM LUNAS',
                                          style: Theme.of(Get.context!)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: Colors.white),
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('DITERBITKAN ATAS NAMA',
                                style:
                                    Theme.of(Get.context!).textTheme.bodyLarge),
                            Text(
                                'Penjual: ${controller.sideMenuC.store.value!.name.value}',
                                style:
                                    Theme.of(Get.context!).textTheme.bodyLarge),
                            Text(
                                'Alamat: ${controller.sideMenuC.store.value!.address.value}',
                                style:
                                    Theme.of(Get.context!).textTheme.bodyLarge),
                            Text(
                                'No Telp: ${controller.sideMenuC.store.value!.phone.value} / ${controller.sideMenuC.store.value!.telp.value}',
                                style:
                                    Theme.of(Get.context!).textTheme.bodyLarge),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('UNTUK',
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .bodyLarge),
                                Row(
                                  children: [
                                    // TextButton(
                                    //     onPressed: () => editDialog(
                                    //           context,
                                    //           controller,
                                    //           invoice,
                                    //         ),
                                    //     child: const Text('Edit Invoice')),
                                    // const SizedBox(width: 10),
                                    // const Text('|'),
                                    // const SizedBox(width: 2),
                                    if (controller.isAdmin)
                                      IconButton(
                                          onPressed: () =>
                                              controller.destroyHandle(invoice),
                                          icon: const Icon(
                                            Symbols.delete_forever,
                                            color: Colors.red,
                                          ))
                                  ],
                                )
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
                                  invoice.customer.value!.name == null
                                      ? ''
                                      : invoice.customer.value!.name!
                                          .toUpperCase(),
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .bodyLarge,
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
                                  invoice.customer.value!.phone ?? '',
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .bodyLarge,
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
                                      invoice.createdAt.value!,
                                    ),
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .bodyLarge,
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
                                  child: Text(
                                      invoice.customer.value!.address == null
                                          ? ''
                                          : invoice.customer.value!.address!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey),
                  const RowTable(isHeader: true),
                  const Divider(color: Colors.grey),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (invoice.isReturn)
                        const Text(
                          'Pesanan Awal:',
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
                          // textAlign: TextAlign.center,
                        ),
                      Container(
                        color: Colors.green[50],
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: invoice.purchaseList.value.items.length,
                          itemBuilder: (context, index) {
                            final purchaseItem =
                                invoice.purchaseList.value.items[index];

                            return RowTable(
                              purchaseItem: purchaseItem,
                              invoice: invoice,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // const Divider(color: Colors.grey),
                  if (invoice.isReturn)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pesanan di Return:',
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
                          // textAlign: TextAlign.center,
                        ),
                        Container(
                          color: Colors.red[50],
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: invoice.purchaseList.value.items.length,
                            itemBuilder: (context, index) {
                              final purchaseItem =
                                  invoice.purchaseList.value.items[index];

                              return Column(
                                children: [
                                  RowTable(
                                    purchaseItem: purchaseItem,
                                    invoice: invoice,
                                    isReturn: true,
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  if (invoice.returnList.value != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 10),
                        const Text(
                          'Tambahan Return:',
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
                          // textAlign: TextAlign.center,
                        ),
                        Container(
                          color: Colors.red[50],
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: invoice.returnList.value!.items.length,
                            itemBuilder: (context, index) {
                              final purchaseItem =
                                  invoice.returnList.value!.items[index];

                              return Column(
                                children: [
                                  RowTable(
                                    purchaseItem: purchaseItem,
                                    invoice: invoice,
                                    isReturn: true,
                                    isAdditionalReturn: true,
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  const Divider(color: Colors.grey),
                  Container(
                    decoration: BoxDecoration(
                        // color: Colors.amber,
                        border: (invoice.isReturn)
                            ? Border(
                                bottom: BorderSide(color: Colors.red[100]!))
                            : null),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (invoice.isReturn)
                              Expanded(
                                child: PropertiesRow(
                                  // primary: true,
                                  subtraction: true,
                                  title: 'Total Pesanan di Return',
                                  value:
                                      'Rp-${currency.format(invoice.subtotalReturn)}',
                                ),
                              ),
                            SizedBox(
                              width: 500,
                              child: PropertiesRow(
                                primary: true,
                                title:
                                    'TOTAL HARGA (${invoice.purchaseList.value.items.length} Barang)',
                                subValue:
                                    'Rp${currency.format((invoice.subTotalPurchase))}',
                                value:
                                    'Rp${currency.format((invoice.subTotalPurchase))}',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (invoice.isReturn)
                              Expanded(
                                child: PropertiesRow(
                                  // primary: true,
                                  subtraction: true,
                                  title: 'Total Tambahan Return',
                                  value:
                                      'Rp-${currency.format(invoice.subtotalAdditionalReturn)}',
                                ),
                              ),
                            SizedBox(
                              width: 500,
                              child: PropertiesRow(
                                subtraction: true,
                                title: 'Total Diskon',
                                value: invoice.isReturn
                                    ? 'Rp-${currency.format((invoice.totalDiscount))}'
                                    : '-',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (invoice.isReturn)
                              Expanded(
                                child: PropertiesRow(
                                  title: 'Biaya Return',
                                  value:
                                      'Rp${currency.format(invoice.returnFee.value)}',
                                ),
                              ),
                            (invoice.totalOtherCosts > 0)
                                ? SizedBox(
                                    width: 500,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: invoice.otherCosts.length,
                                      itemBuilder: (context, index) {
                                        return PropertiesRow(
                                          title: invoice.otherCosts[index].name,
                                          value:
                                              'Rp${currency.format((invoice.otherCosts[index].amount))}',
                                        );
                                      },
                                    ),
                                  )
                                : const SizedBox(
                                    width: 500,
                                    child: PropertiesRow(
                                      title: '',
                                      value: '',
                                    ),
                                  ),
                          ],
                        ),
                        Divider(color: Colors.grey[300]),
                        if (invoice.isReturn)
                          SizedBox(
                            width: 500,
                            child: PropertiesRow(
                              primary: true,
                              title:
                                  'TOTAL TAGIHAN ${invoice.totalReturn != 0 ? '(Sebelum Return)' : ''}',
                              value:
                                  'Rp${currency.format((invoice.totalPurchase))}',
                            ),
                          ),
                        if (invoice.isReturn)
                          Row(
                            children: [
                              Expanded(
                                child: PropertiesRow(
                                  primary: true,
                                  subtraction: true,
                                  title: 'TOTAL RETURN',
                                  value:
                                      'Rp-${currency.format(invoice.totalReturn)}',
                                ),
                              ),
                              SizedBox(
                                width: 500,
                                child: PropertiesRow(
                                  primary: true,
                                  subtraction: true,
                                  title: 'TOTAL RETURN',
                                  value:
                                      'Rp-${currency.format(invoice.totalReturn)}',
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Container(
                    color: invoice.totalPaid > 0
                        ? null
                        : invoice.totalFinal <= 0
                            ? Colors.green[50]
                            : Colors.red[50],
                    width: 500,
                    child: Column(
                      children: [
                        PropertiesRow(
                          primary: true,
                          title:
                              'TOTAL TAGIHAN ${invoice.isReturn ? '(Setelah Return)' : ''}',
                          value: 'Rp${currency.format((invoice.totalFinal))}',
                        ),

                        // Divider(color: Colors.grey[300], indent: 150),

                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.end,
                        //     children: [
                        //       Container(
                        //         padding: const EdgeInsets.symmetric(
                        //             horizontal: 8, vertical: 4),
                        //         margin: const EdgeInsets.only(left: 50),
                        //         decoration: BoxDecoration(
                        //           color: invoice.totalPaid < invoice.total
                        //               ? Colors.red
                        //               : Colors.green,
                        //           borderRadius: BorderRadius.circular(4),
                        //         ),
                        //         child: Text(
                        //           invoice.totalPaid < invoice.total
                        //               ? 'Sisa Tagihan     Rp${decimal.format(invoice.total - invoice.totalPaid + invoice.returnFee.value)}'
                        //               : 'Lunas',
                        //           textAlign: TextAlign.end,
                        //           style: context.textTheme.titleLarge!
                        //               .copyWith(color: Colors.white),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 20),
                        // if (invoice.totalPaid < invoice.total)
                        //   Padding(
                        //     padding: const EdgeInsets.symmetric(horizontal: 20),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.end,
                        //       children: [
                        //         if (!invoice.isDebtPaid.value)
                        //           ElevatedButton(
                        //             onPressed: () async {
                        //               paymentDialogWidget(context, invoice, () {
                        //                 // controller
                        //                 Get.back();
                        //                 Get.back();
                        //               });
                        //               // }
                        //             },
                        //             child: const Text(
                        //               'BAYAR TAGIHAN',
                        //             ),
                        //           )
                        //       ],
                        //     ),
                        //   ),
                        // if (invoice.remainingDebt > 0)
                        // ListTile(
                        //   dense: true,
                        //   title: Row(
                        //     children: [
                        //       Expanded(
                        //         flex: 5,
                        //         child: Text('TOTAL',
                        //             style: Theme.of(Get.context!)
                        //                 .textTheme
                        //                 .titleLarge!
                        //                 .copyWith(
                        //                     color: Theme.of(Get.context!)
                        //                         .colorScheme
                        //                         .primary),
                        //             textAlign: TextAlign.right),
                        //       ),
                        //       Expanded(
                        //         flex: 2,
                        //         child: Text(
                        //           'Rp${currency.format(invoice.total - invoice.totalReturn)}',
                        //           style: Theme.of(Get.context!)
                        //               .textTheme
                        //               .titleLarge!
                        //               .copyWith(
                        //                   color: Theme.of(Get.context!)
                        //                       .colorScheme
                        //                       .primary),
                        //           textAlign: TextAlign.end,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        //   subtitle: Text(charge,
                        //       style: Theme.of(Get.context!)
                        //           .textTheme
                        //           .bodySmall!
                        //           .copyWith(fontStyle: FontStyle.italic),
                        //       textAlign: TextAlign.end),
                        // ),
                        // if (invoice.totalReturn <= 0)

                        // if (invoice.remainingDebt != 0 &&
                        //     invoice.totalReturn != 0)
                        // if (invoice.totalReturn <= 0)
                        //   ListTile(
                        //     dense: true,
                        //     title: Row(
                        //       children: [
                        //         Expanded(
                        //           flex: 5,
                        //           child: Text(
                        //               invoice.change <= 0
                        //                   ? 'KEMBALIAN'
                        //                   : 'KURANG BAYAR',
                        //               style: Theme.of(Get.context!)
                        //                   .textTheme
                        //                   .titleLarge!
                        //                   .copyWith(
                        //                       color: Theme.of(Get.context!)
                        //                           .colorScheme
                        //                           .primary),
                        //               textAlign: TextAlign.right),
                        //         ),
                        //         Expanded(
                        //           flex: 2,
                        //           child: Text(
                        //             'Rp${currency.format(invoice.remainingReturn)}',
                        //             style: Theme.of(Get.context!)
                        //                 .textTheme
                        //                 .titleLarge!
                        //                 .copyWith(
                        //                     color: Theme.of(Get.context!)
                        //                         .colorScheme
                        //                         .primary),
                        //             textAlign: TextAlign.end,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //     subtitle: Text(charge,
                        //         style: Theme.of(Get.context!)
                        //             .textTheme
                        //             .bodySmall!
                        //             .copyWith(fontStyle: FontStyle.italic),
                        //         textAlign: TextAlign.end),
                        //   ),
                      ],
                    ),
                  ),
                  if (invoice.totalPaid > 0)
                    SizedBox(
                      width: 500,
                      child: Obx(
                        () {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: invoice.payments.length,
                            itemBuilder: (context, index) {
                              return PropertiesRow(
                                primary: true,
                                payment: true,
                                title:
                                    'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${index + 1}' ' (${DateFormat('dd MMMM y', 'id').format(invoice.payments[index].date!)})' : ''}',
                                value:
                                    'Rp${currency.format(invoice.payments[index].amountPaid)}',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  if (invoice.totalPaid > 0)
                    SizedBox(
                        width: 500, child: Divider(color: Colors.grey[300])),
                  if (invoice.totalPaid > 0)
                    Container(
                      color: invoice.totalPaid < invoice.totalFinal
                          ? Colors.green[50]
                          : invoice.isReturn
                              ? Colors.yellow[50]
                              : Colors.green[50],
                      width: 500,
                      child: PropertiesRow(
                        primary: true,
                        title: invoice.totalPaid < invoice.totalFinal
                            ? 'SISA TAGIHAN'
                            : invoice.isReturn
                                ? 'Nominal yang harus di return'
                                : 'Kembalian',
                        value:
                            'Rp${currency.format((invoice.totalFinal - invoice.totalPaid))}',
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
    confirm: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // if (controller.isAdmin)
        ElevatedButton(
          onPressed: () {
            controller.editReturnManual.value = false;
            returnDialogWidget(
              context,
              controller,
              invoice,
            );
          },
          child: const Text(
            'Return Barang',
          ),
        ),
        const SizedBox(width: 12),
        // if (controller.isAdmin)
        ElevatedButton(
          onPressed: () => editDialog(
            context,
            controller,
            invoice,
          ),
          child: const Text(
            'Edit Invoice',
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => otherCostDialogWidget(
            context,
            invoice,
          ),
          child: const Text(
            'Tambah Biaya Lainnya',
          ),
        ),
        if (invoice.totalPaid < invoice.totalFinal && controller.isAdmin)
          const SizedBox(width: 12),
        if (invoice.totalPaid < invoice.totalFinal && controller.isAdmin)
          ElevatedButton(
            onPressed: () async {
              paymentDialogWidget(context, invoice, () {
                // controller
                Get.back();
                Get.back();
              });
              // }
            },
            child: Text(
              (invoice.totalPaid > 0) ? 'Tambah Pembayaran' : 'Bayar Tagihan',
            ),
          ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => printInvoiceDialog(
            context,
            invoice,
          ),
          child: const Text(
            'Cetak',
          ),
        ),
        // const SizedBox(width: 12),
        // ElevatedButton(
        //   onPressed: () => printInvoiceDialog(
        //     context,
        //     invoice,
        //   ),
        //   child: const Text(
        //     'Cetak invoice',
        //   ),
        // ),
      ],
    ),
    // : const CircularProgressIndicator(),
    // ),
  );
}

class PropertiesRow extends StatelessWidget {
  const PropertiesRow({
    this.title = '',
    this.value = '',
    this.subValue = '',
    this.primary = false,
    this.subtraction = false,
    this.payment = false,
    super.key,
  });

  final String title;
  final String value;
  final String subValue;
  final bool primary;
  final bool subtraction;
  final bool payment;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              // 'TOTAL HARGA (${controller.filterPurchase(invoice).length} Barang)',
              style: primary
                  ? subtraction
                      ? Theme.of(Get.context!)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.red)
                      : payment
                          ? Theme.of(Get.context!)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.green)
                          : Theme.of(Get.context!).textTheme.titleLarge
                  : subtraction
                      ? Theme.of(Get.context!)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.red)
                      : payment
                          ? Theme.of(Get.context!)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.green)
                          : Theme.of(Get.context!).textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          // Expanded(
          //     flex: 3,
          //     child: Text(
          //       subValue,
          //       style: primary
          //           ? subtraction
          //               ? Theme.of(Get.context!)
          //                   .textTheme
          //                   .titleLarge!
          //                   .copyWith(color: Colors.red)
          //               : Theme.of(Get.context!).textTheme.titleLarge
          //           : subtraction
          //               ? Theme.of(Get.context!)
          //                   .textTheme
          //                   .bodyMedium!
          //                   .copyWith(color: Colors.red)
          //               : Theme.of(Get.context!).textTheme.bodyMedium,
          //       textAlign: TextAlign.end,
          //     )),
          Expanded(
              flex: 4,
              child: Text(
                value,
                style: primary
                    ? subtraction
                        ? Theme.of(Get.context!)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.red)
                        : payment
                            ? Theme.of(Get.context!)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Colors.green)
                            : Theme.of(Get.context!).textTheme.titleLarge
                    : subtraction
                        ? Theme.of(Get.context!)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.red)
                        : payment
                            ? Theme.of(Get.context!)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.green)
                            : Theme.of(Get.context!).textTheme.bodyMedium,
                textAlign: TextAlign.end,
              )),
        ],
      ),
    );
  }
}

class RowTable extends StatelessWidget {
  const RowTable({
    this.invoice,
    this.purchaseItem,
    this.isHeader = false,
    this.isReturn = false,
    this.isAdditionalReturn = false,
    // this.isReturn = false,
    // this.productName = '-',
    // this.price = '-',
    // this.quantity = '-',
    // this.discount = '-',
    // this.subTotal = '-',
    super.key,
  });
  final Invoice? invoice;
  final CartItem? purchaseItem;
  final bool isHeader;
  final bool isReturn;
  final bool isAdditionalReturn;
  // final String productName;
  // final String price;
  // final String quantity;
  // final String discount;
  // final String subTotal;
  @override
  Widget build(BuildContext context) {
    String productName = '-';
    String price = '-';
    // String quantity = '-';
    String discount = '-';
    String totalPurchase = '-';
    String qtyReturnDisplay = '';
    String quantityReturn = '';
    late String subTotalReturn;
    late String quantityPurchase;
    late String subTotalPurchase;
    // bool isReturn = false;
    if (purchaseItem != null && invoice != null) {
      // isReturn = purchaseItem!.quantityReturn.value > 0;
      productName = purchaseItem!.product.productName;

      price =
          'Rp${currency.format(purchaseItem!.product.getPrice(invoice!.priceType.value))}';
      // quantity = '${purchaseItem!.qtyDisplay} ${purchaseItem!.product.unit}';
      if (purchaseItem!.individualDiscount.value != 0) {
        discount =
            'Rp-${currency.format(purchaseItem!.individualDiscount.value)}';
      }
      totalPurchase =
          'Rp${currency.format(purchaseItem!.getTotalPurchase(invoice!.priceType.value) + purchaseItem!.individualDiscount.value)}';

      qtyReturnDisplay = purchaseItem!.qtyReturnDisplay;
      quantityReturn =
          '-${purchaseItem!.qtyReturnDisplay} ${purchaseItem!.product.unit}';
      subTotalReturn =
          'Rp-${currency.format(purchaseItem!.getTotalReturn(invoice!.priceType.value))}';
      quantityPurchase =
          '${purchaseItem!.qtyPurchaseDisplay} ${purchaseItem!.product.unit}';
      subTotalPurchase =
          'Rp${currency.format(purchaseItem!.getTotalPurchase(invoice!.priceType.value))}';
    }

    return (isReturn && (qtyReturnDisplay == '0'))
        ? const SizedBox()
        : ListTile(
            dense: true,
            title: Row(
              children: [
                Expanded(
                    flex: 6,
                    child: Row(
                      children: [
                        Text(
                          isHeader ? 'NAMA BARANG' : productName,
                          style: isHeader
                              ? Theme.of(Get.context!).textTheme.titleLarge
                              : null,
                        ),
                        const SizedBox(width: 16),
                      ],
                    )),
                Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: isHeader ? 4 : 1,
                          child: Text(
                            isHeader ? 'HARGA BARANG' : price,
                            style: isHeader
                                ? Theme.of(Get.context!).textTheme.titleLarge
                                : null,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      isHeader
                          ? 'JUMLAH'
                          : isReturn
                              ? quantityReturn
                              : quantityPurchase,
                      style: isHeader
                          ? Theme.of(Get.context!).textTheme.titleLarge
                          : isReturn
                              ? Theme.of(Get.context!).textTheme.bodySmall
                              : null,
                      textAlign: TextAlign.right,
                    )),
                Expanded(
                    flex: 3,
                    child: Text(
                      isHeader
                          ? 'DISKON'
                          : isReturn || isAdditionalReturn
                              ? ''
                              : discount,
                      style: isHeader
                          ? Theme.of(Get.context!).textTheme.titleLarge
                          : null,
                      textAlign: TextAlign.right,
                    )),
                Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (discount != '-' && !isReturn)
                          Text(
                            totalPurchase,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.lineThrough,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          isHeader
                              ? 'TOTAL HARGA'
                              : isReturn
                                  ? subTotalReturn
                                  : subTotalPurchase,
                          style: isHeader
                              ? Theme.of(Get.context!).textTheme.titleLarge
                              : isReturn
                                  ? const TextStyle(color: Colors.red)
                                  : null,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    )),
              ],
            ),
            // subtitle:
            //  isReturn
            //     ? Row(
            //         children: [
            //           const Expanded(flex: 6, child: Text('')),
            //           Expanded(
            //               flex: 5,
            //               child: Column(
            //                 children: [
            //                   Row(
            //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                     children: [
            //                       const Expanded(
            //                         child: Text(
            //                           'Return:',
            //                           style: TextStyle(color: Colors.grey),
            //                           textAlign: TextAlign.right,
            //                         ),
            //                       ),
            //                       Expanded(
            //                         child: Text(
            //                           price,
            //                           style: const TextStyle(color: Colors.grey),
            //                           textAlign: TextAlign.right,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                   Row(
            //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                     children: [
            //                       const Expanded(
            //                         child: Text(
            //                           'Setelah Return:',
            //                           style: TextStyle(color: Colors.grey),
            //                           textAlign: TextAlign.right,
            //                         ),
            //                       ),
            //                       Expanded(
            //                         child: Text(
            //                           price,
            //                           style: const TextStyle(color: Colors.grey),
            //                           textAlign: TextAlign.right,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ],
            //               )),
            //           Expanded(
            //               flex: 2,
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.end,
            //                 children: [
            //                   Text(
            //                     quantityReturn,
            //                     style: const TextStyle(color: Colors.grey),
            //                     textAlign: TextAlign.right,
            //                   ),
            //                   Text(
            //                     quantity,
            //                     style: const TextStyle(color: Colors.grey),
            //                     textAlign: TextAlign.right,
            //                   ),
            //                 ],
            //               )),
            //           Expanded(
            //               flex: 3,
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.end,
            //                 children: [
            //                   const Text(''),
            //                   Text(
            //                     discount,
            //                     style: const TextStyle(color: Colors.grey),
            //                     textAlign: TextAlign.right,
            //                   ),
            //                 ],
            //               )),
            //           Expanded(
            //               flex: 4,
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.end,
            //                 children: [
            //                   Text(
            //                     subTotalReturn,
            //                     style: const TextStyle(color: Colors.grey),
            //                     textAlign: TextAlign.right,
            //                   ),
            //                   Text(
            //                     subTotal,
            //                     style: const TextStyle(color: Colors.grey),
            //                     textAlign: TextAlign.right,
            //                   ),
            //                 ],
            //               )),
            //         ],
            //       )
            //     : null,
          );
  }
}
