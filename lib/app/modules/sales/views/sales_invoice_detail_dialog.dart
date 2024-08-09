import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../main.dart';
import '../../../data/models/sales_invoice_model.dart';
import '../../../widget/other_cost_dialog_widget.dart';
import '../../../widget/payment_dialog_widget.dart';
import '../controllers/sales_controller.dart';
import 'payment_sales_dialog.dart';

void detailDialogInvoiceSales(
  BuildContext context,
  SalesController controller,
  SalesInvoice invoice,
) async {
  // controller.asignEditData(invoice);
  var charge = '';
  debugPrint(invoice.remainingDebt.toString());
  invoice.updateIsDebtPaid();
  return Get.defaultDialog(
    title: 'Sales Invoice',
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (5 / 7),
      width: MediaQuery.of(Get.context!).size.width * (7 / 10),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('SALES INVOICE: ',
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
                          Text('DITERBITKAN UNTUK',
                              style:
                                  Theme.of(Get.context!).textTheme.bodyLarge),
                          Text('Pembeli: Nama Toko',
                              style:
                                  Theme.of(Get.context!).textTheme.bodyLarge),
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
                                Text('DARI',
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .bodyLarge),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () =>
                                            controller.destroyInvoice(invoice),
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
                                      Text('Sales'),
                                      Text(' : '),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                  invoice.sales.value!.name == null
                                      ? ''
                                      : invoice.sales.value!.name!
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
                                  invoice.sales.value!.phone ?? '',
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
                                      invoice.createdAt.value!.toDate(),
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
                                      invoice.sales.value!.address == null
                                          ? ''
                                          : invoice.sales.value!.address!),
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
                          child: Row(
                            children: [
                              Text(
                                'NAMA BARANG',
                                style:
                                    Theme.of(Get.context!).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'HARGA SATUAN',
                            style: Theme.of(Get.context!).textTheme.titleLarge,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Text('JUMLAH',
                                style:
                                    Theme.of(Get.context!).textTheme.titleLarge,
                                textAlign: TextAlign.right)),
                        Expanded(
                            flex: 2,
                            child: Text('DISKON',
                                style:
                                    Theme.of(Get.context!).textTheme.titleLarge,
                                textAlign: TextAlign.right)),
                        Expanded(
                            flex: 3,
                            child: Text('TOTAL HARGA',
                                style:
                                    Theme.of(Get.context!).textTheme.titleLarge,
                                textAlign: TextAlign.end)),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: invoice.purchaseList.value.items.length,
                    itemBuilder: (context, index) {
                      final purchaseItem =
                          invoice.purchaseList.value.items[index];

                      var discount = '-';
                      if (purchaseItem.individualDiscount.value != 0) {
                        discount =
                            '-Rp${currency.format(purchaseItem.individualDiscount.value)}';
                      }
                      return ListTile(
                        dense: true,
                        title: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(purchaseItem.product.productName),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Rp${currency.format(purchaseItem.product.costPrice.value)}',
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${purchaseItem.totalQuantity}',
                                  textAlign: TextAlign.right),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(discount, textAlign: TextAlign.right),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Rp${currency.format(purchaseItem.getTotalCost())}',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Expanded(
                      //   child: Column(
                      //     children: [
                      //       const SizedBox(height: 12),
                      //       if (invoice.totalReturn != 0)
                      //         Container(
                      //           decoration: BoxDecoration(
                      //               border:
                      //                   Border.all(color: Colors.red[100]!)),
                      //           child: Column(
                      //             children: [
                      //               ListView.builder(
                      //                 shrinkWrap: true,
                      //                 itemCount: invoice
                      //                     .purchaseList.value.items.length,
                      //                 itemBuilder: (context, index) {
                      //                   final returnItem = invoice
                      //                       .purchaseList.value.items[index];
                      //                   return Column(
                      //                     children: [
                      //                       if (returnItem
                      //                               .quantityReturn.value !=
                      //                           0)
                      //                         ListTile(
                      //                           dense: true,
                      //                           title: Row(
                      //                             children: [
                      //                               Expanded(
                      //                                 flex: 6,
                      //                                 child: Text(
                      //                                   returnItem.product
                      //                                       .productName,
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                 ),
                      //                               ),
                      //                               Expanded(
                      //                                 flex: 3,
                      //                                 child: Text(
                      //                                   'Rp${controller.currency.format(returnItem.product.getPrice(invoice.priceType.value))}',
                      //                                   textAlign:
                      //                                       TextAlign.end,
                      //                                 ),
                      //                               ),
                      //                               Expanded(
                      //                                 flex: 1,
                      //                                 child: Text(
                      //                                     'x ${returnItem.quantityReturn.value}',
                      //                                     textAlign:
                      //                                         TextAlign.center),
                      //                               ),
                      //                               Expanded(
                      //                                 flex: 4,
                      //                                 child: Text(
                      //                                   'Rp${controller.currency.format(returnItem.getTotalReturn(invoice.priceType.value))}',
                      //                                   textAlign:
                      //                                       TextAlign.end,
                      //                                 ),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                     ],
                      //                   );
                      //                 },
                      //               ),
                      //               const Padding(
                      //                 padding:
                      //                     EdgeInsets.symmetric(horizontal: 20),
                      //                 child: Divider(),
                      //               ),
                      //               ListTile(
                      //                 title: Column(
                      //                   crossAxisAlignment:
                      //                       CrossAxisAlignment.end,
                      //                   children: [
                      //                     Text(
                      //                         'Rp${controller.currency.format(invoice.subtotalReturn)}'),
                      //                     Row(
                      //                       children: [
                      //                         const Expanded(
                      //                             flex: 5, child: Text('')),
                      //                         Expanded(
                      //                           flex: 5,
                      //                           child: Text(
                      //                             'Biaya Return',
                      //                             textAlign: TextAlign.right,
                      //                             style: Theme.of(Get.context!)
                      //                                 .textTheme
                      //                                 .bodyLarge,
                      //                           ),
                      //                         ),
                      //                         Expanded(
                      //                           flex: 4,
                      //                           child: Text(
                      //                             'Rp-${controller.currency.format(invoice.returnFee.value)}',
                      //                             textAlign: TextAlign.end,
                      //                             style: Theme.of(Get.context!)
                      //                                 .textTheme
                      //                                 .bodyLarge,
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       if (invoice.totalReturn != 0)
                      //         Column(
                      //           children: [
                      //             Divider(color: Colors.grey[200]),
                      //             ListTile(
                      //               // dense: true,
                      //               title: Row(
                      //                 children: [
                      //                   const Expanded(
                      //                       flex: 5, child: Text('')),
                      //                   Expanded(
                      //                     flex: 5,
                      //                     child: Text(
                      //                       'TOTAL RETURN',
                      //                       textAlign: TextAlign.right,
                      //                       style: Theme.of(Get.context!)
                      //                           .textTheme
                      //                           .bodyLarge!
                      //                           .copyWith(
                      //                               color:
                      //                                   Theme.of(Get.context!)
                      //                                       .colorScheme
                      //                                       .primary),
                      //                     ),
                      //                   ),
                      //                   Expanded(
                      //                     flex: 4,
                      //                     child: Text(
                      //                       'Rp${controller.currency.format(invoice.totalReturn)}',
                      //                       textAlign: TextAlign.end,
                      //                       style: Theme.of(Get.context!)
                      //                           .textTheme
                      //                           .bodyLarge!
                      //                           .copyWith(
                      //                               color:
                      //                                   Theme.of(Get.context!)
                      //                                       .colorScheme
                      //                                       .primary),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //             Divider(color: Colors.grey[200]),
                      //           ],
                      //         ),
                      //     ],
                      //   ),
                      // ),
                      SizedBox(
                        width: 450,
                        child: Column(
                          children: [
                            ListTile(
                              dense: true,
                              title: Row(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Text(
                                          'TOTAL HARGA (${invoice.purchaseList.value.items.length} Barang)',
                                          style: Theme.of(Get.context!)
                                              .textTheme
                                              .titleLarge,
                                          textAlign: TextAlign.right)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          'Rp${currency.format((invoice.subtotalCost))}',
                                          style: Theme.of(Get.context!)
                                              .textTheme
                                              .titleLarge,
                                          textAlign: TextAlign.end)),
                                ],
                              ),
                            ),
                            if (invoice.totalDiscount > 0)
                              ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Expanded(
                                        flex: 5,
                                        child: Text('Total Diskon',
                                            style: Theme.of(Get.context!)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                    color:
                                                        Theme.of(Get.context!)
                                                            .colorScheme
                                                            .primary),
                                            textAlign: TextAlign.right)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            'Rp-${currency.format((invoice.totalDiscount))}',
                                            style: Theme.of(Get.context!)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                    color:
                                                        Theme.of(Get.context!)
                                                            .colorScheme
                                                            .primary),
                                            textAlign: TextAlign.end)),
                                  ],
                                ),
                              ),
                            // if (invoice.totalOtherCosts > 0)
                            //   ListView.builder(
                            //     shrinkWrap: true,
                            //     itemCount: invoice.otherCosts.length,
                            //     itemBuilder: (context, index) {
                            //       return ListTile(
                            //         dense: true,
                            //         title: Row(
                            //           children: [
                            //             Expanded(
                            //                 flex: 5,
                            //                 child: Text(
                            //                     invoice.otherCosts[index].name,
                            //                     style: Theme.of(Get.context!)
                            //                         .textTheme
                            //                         .titleSmall!
                            //                         .copyWith(
                            //                             color: Theme.of(
                            //                                     Get.context!)
                            //                                 .colorScheme
                            //                                 .primary),
                            //                     textAlign: TextAlign.right)),
                            //             Expanded(
                            //                 flex: 2,
                            //                 child: Text(
                            //                     'Rp${controller.currency.format((invoice.otherCosts[index].amount))}',
                            //                     style: Theme.of(Get.context!)
                            //                         .textTheme
                            //                         .titleSmall!
                            //                         .copyWith(
                            //                             color: Theme.of(
                            //                                     Get.context!)
                            //                                 .colorScheme
                            //                                 .primary),
                            //                     textAlign: TextAlign.end)),
                            //           ],
                            //         ),
                            //       );
                            //     },
                            //   ),
                            if (invoice.subtotalCost != invoice.totalCost)
                              Column(
                                children: [
                                  Divider(color: Colors.grey[200], indent: 150),
                                  ListTile(
                                    dense: true,
                                    title: Row(
                                      children: [
                                        Expanded(
                                            flex: 5,
                                            child: Text('TOTAL BELANJA',
                                                style: Theme.of(Get.context!)
                                                    .textTheme
                                                    .titleLarge,
                                                textAlign: TextAlign.right)),
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                'Rp${currency.format((invoice.totalCost))}',
                                                style: Theme.of(Get.context!)
                                                    .textTheme
                                                    .titleLarge,
                                                textAlign: TextAlign.end)),
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.grey[200], indent: 150),
                                ],
                              ),
                            Obx(
                              () {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: invoice.payments.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      dense: true,
                                      title: Row(
                                        children: [
                                          Expanded(
                                              flex: 5,
                                              child: Text(
                                                  'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${index + 1}' ' (${DateFormat('dd MMMM y', 'id').format(invoice.payments[index].date!.toDate())})' : ''}',
                                                  style: Theme.of(Get.context!)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          color: Colors.green),
                                                  textAlign: TextAlign.right)),
                                          Expanded(
                                              flex: 2,
                                              child: Text(
                                                  'Rp${currency.format(invoice.payments[index].amountPaid)}',
                                                  style: Theme.of(Get.context!)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          color: Colors.green),
                                                  textAlign: TextAlign.end)),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            // if (invoice.totalReturn != 0)
                            //   Column(
                            //     children: [
                            //       Divider(color: Colors.grey[200]),
                            //       ListTile(
                            //         // dense: true,
                            //         title: Row(
                            //           children: [
                            //             Expanded(
                            //                 flex: 5,
                            //                 child: Text('TOTAL RETURN',
                            //                     style: Theme.of(Get.context!)
                            //                         .textTheme
                            //                         .titleLarge!
                            //                         .copyWith(
                            //                             color: Theme.of(
                            //                                     Get.context!)
                            //                                 .colorScheme
                            //                                 .primary),
                            //                     textAlign: TextAlign.right)),
                            //             Expanded(
                            //                 flex: 2,
                            //                 child: Text(
                            //                     'Rp${controller.currency.format(invoice.totalReturn)}',
                            //                     style: Theme.of(Get.context!)
                            //                         .textTheme
                            //                         .titleLarge!
                            //                         .copyWith(
                            //                             color: Theme.of(
                            //                                     Get.context!)
                            //                                 .colorScheme
                            //                                 .primary),
                            //                     textAlign: TextAlign.end)),
                            //           ],
                            //         ),
                            //       ),
                            //       Divider(color: Colors.grey[200]),
                            //     ],
                            //   ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 450,
                    child: Column(
                      children: [
                        if (invoice.remainingDebt > 0)
                          ListTile(
                            dense: true,
                            title: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text('SISA HUTANG:',
                                      style: Theme.of(Get.context!)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontStyle: FontStyle.italic),
                                      textAlign: TextAlign.right),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Rp${currency.format(invoice.remainingDebt)}',
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                            color: Theme.of(Get.context!)
                                                .colorScheme
                                                .primary),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(charge,
                                style: Theme.of(Get.context!)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontStyle: FontStyle.italic),
                                textAlign: TextAlign.end),
                          ),
                        // if (invoice.remainingDebt != 0 &&
                        //     invoice.totalReturn != 0)
                        //   ListTile(
                        //     dense: true,
                        //     title: Row(
                        //       children: [
                        //         Expanded(
                        //           flex: 5,
                        //           child: Text('SISA RETURN:',
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
                        //             'Rp${controller.currency.format(invoice.remainingReturn)}',
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
                        // const SizedBox(height: 20),
                        // if (invoice.remainingReturn <= 0)
                        //   Row(
                        //     mainAxisAlignment: MainAxisAlignment.end,
                        //     children: [
                        //       if (!invoice.isDebtPaid.value)
                        //         ElevatedButton(
                        //           onPressed: () async {
                        //             paymentDialogWidget(context, invoice, () {
                        //               // controller
                        //               Get.back();
                        //               Get.back();
                        //             });
                        //             // }
                        //           },
                        //           child: const Text(
                        //             'BAYAR TAGIHAN',
                        //           ),
                        //         )
                        //     ],
                        //   ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
    confirm: SizedBox(
      width: 700,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Expanded(
            // child: ElevatedButton(
            //   onPressed: () {},
            //   // returnDialogWidget(
            //   //   context,
            //   //   controller,
            //   //   invoice,
            //   // ),
            //   child: const Text(
            //     'Return Barang',
            //   ),
            // ),
            // ),
            // const SizedBox(width: 12),
            // ElevatedButton(
            //   onPressed: () {},
            //   // editDialog(
            //   //   context,
            //   //   controller,
            //   //   invoice,
            //   // ),
            //   child: const Text(
            //     'Edit Invoice',
            //   ),
            // ),
            const SizedBox(width: 12),
            if (!invoice.isDebtPaid.value)
              ElevatedButton(
                onPressed: () => paymentSalesDialogWidget(context, invoice, () {
                  // controller
                  Get.back();
                  Get.back();
                }),
                // otherCostDialogWidget(
                //   context,
                //   invoice,
                // ),
                child: const Text(
                  'Bayar Hutang',
                ),
              ),
            // Expanded(
            //   child: ElevatedButton(
            //     onPressed: () {},
            //     // otherCostDialogWidget(
            //     //   context,
            //     //   invoice,
            //     // ),
            //     child: const Text(
            //       'Tambah Biaya Lainnya',
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    ),
    // : const CircularProgressIndicator(),
    // ),
  );
}
