import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/models/invoice_model.dart';
import '../controllers/invoice_controller.dart';
import 'edit_dialog_widget.dart';
import 'return_dialog_widget.dart';

Future<void> detailDialog(
  BuildContext context,
  InvoiceController controller,
  Invoice invoice,
) async {
  controller.initDetailInvoice(invoice);
  var charge = '';
  // if (invoice.change! > 0) {
  //   charge = '(Kembalian: Rp${controller.currency.format(invoice.change)})';
  // }
  return Get.defaultDialog(
      title: 'Invoice',
      content: Container(
        margin: const EdgeInsets.all(8),
        height: MediaQuery.of(Get.context!).size.height * (3 / 4),
        width: MediaQuery.of(Get.context!).size.width * (7 / 10),
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
                            Text('INVOICE: ',
                                style:
                                    Theme.of(Get.context!).textTheme.bodyLarge),
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
                                  color: invoice.payment!.debt! > 0
                                      ? Colors.green
                                      : Colors.red),
                              child: invoice.payment!.debt! > 0
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
                            style: Theme.of(Get.context!).textTheme.bodyLarge),
                        Text('Penjual: Nama Toko',
                            style: Theme.of(Get.context!).textTheme.bodyLarge),
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
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .bodyLarge),
                              Row(
                                children: [
                                  TextButton(
                                      onPressed: () => editDialog(
                                            context,
                                            controller,
                                            invoice,
                                          ),
                                      child: const Text('Edit Invoice')),
                                  const SizedBox(width: 10),
                                  const Text('|'),
                                  const SizedBox(width: 2),
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
                                invoice.customer!.name!.toUpperCase(),
                                style:
                                    Theme.of(Get.context!).textTheme.bodyLarge,
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
                                style:
                                    Theme.of(Get.context!).textTheme.bodyLarge,
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
                                    invoice.createdAt!.toDate(),
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
                  itemCount: controller.purchaseCart.length,
                  itemBuilder: (context, index) {
                    final cart = controller.purchaseCart[index];

                    // int idCart = controller.editReturnCart.indexWhere(
                    //     (selectItem) =>
                    //         selectItem.product?.id == cart.product!.id);

                    // final returnCart = controller.editReturnCart[idCart];

                    var discount = '-';
                    if (cart.individualDiscount != 0) {
                      discount =
                          '-Rp.${controller.currency.format(cart.individualDiscount)}';
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
                            flex: 3,
                            child: Text(
                              'Rp.${controller.currency.format(cart.product!.sellPrice)}',
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
                              'Rp.${controller.currency.format(cart.product!.sellPrice! * cart.quantity! - cart.individualDiscount!)}',
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => returnDialog(
                              context,
                              controller,
                              invoice,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Return Barang',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (controller.returnCart.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red[100]!)),
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: controller.returnCart.length,
                                    itemBuilder: (context, index) {
                                      final cart = controller.returnCart[index];
                                      return ListTile(
                                        dense: true,
                                        title: Row(
                                          children: [
                                            Expanded(
                                              flex: 6,
                                              child: Text(
                                                '${cart.product!.productName}',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Rp.${controller.currency.format(cart.product!.sellPrice)}',
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text('x ${cart.quantity}',
                                                  textAlign: TextAlign.center),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                'Rp.${controller.currency.format(cart.product!.sellPrice! * cart.quantity!)}',
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Divider(),
                                  ),
                                  ListTile(
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            'Rp.${controller.currency.format(invoice.payment!.totalReturn)}'),
                                        Row(
                                          children: [
                                            const Expanded(
                                                flex: 5, child: Text('')),
                                            Expanded(
                                              flex: 5,
                                              child: Text(
                                                'BIAYA RETURN:',
                                                textAlign: TextAlign.right,
                                                style: Theme.of(Get.context!)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                '-Rp.${controller.currency.format(invoice.payment!.returnFee)}',
                                                textAlign: TextAlign.end,
                                                style: Theme.of(Get.context!)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Expanded(
                                                flex: 5, child: Text('')),
                                            Expanded(
                                              flex: 5,
                                              child: Text(
                                                'TOTAL RETURN:',
                                                textAlign: TextAlign.right,
                                                style: Theme.of(Get.context!)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        color: Theme.of(
                                                                Get.context!)
                                                            .colorScheme
                                                            .primary),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                'Rp.${controller.currency.format(invoice.payment!.totalReturn! - invoice.payment!.returnFee!)}',
                                                textAlign: TextAlign.end,
                                                style: Theme.of(Get.context!)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        color: Theme.of(
                                                                Get.context!)
                                                            .colorScheme
                                                            .primary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
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
                                        'TOTAL HARGA (${controller.purchaseCart.length} Barang):',
                                        style: Theme.of(Get.context!)
                                            .textTheme
                                            .titleLarge,
                                        textAlign: TextAlign.right)),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        'Rp.${controller.currency.format((invoice.payment!.totalBill))}',
                                        style: Theme.of(Get.context!)
                                            .textTheme
                                            .titleLarge,
                                        textAlign: TextAlign.end)),
                              ],
                            ),
                          ),
                          if (controller.totalReturn.value != 0)
                            ListTile(
                              dense: true,
                              title: Row(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Text('Total Return:',
                                          style: Theme.of(Get.context!)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: Theme.of(Get.context!)
                                                      .colorScheme
                                                      .primary),
                                          textAlign: TextAlign.right)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          '-Rp.${controller.currency.format(invoice.payment!.totalReturn!)}',
                                          style: Theme.of(Get.context!)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: Theme.of(Get.context!)
                                                      .colorScheme
                                                      .primary),
                                          textAlign: TextAlign.end)),
                                ],
                              ),
                            ),
                          if (controller.totalReturn.value != 0)
                            ListTile(
                              dense: true,
                              title: Row(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Text('TOTAL TAGIHAN:',
                                          style: Theme.of(Get.context!)
                                              .textTheme
                                              .titleLarge,
                                          textAlign: TextAlign.right)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          'Rp.${controller.currency.format((invoice.payment!.totalBill! - ((invoice.payment!.totalReturn ?? 0) - (invoice.payment!.returnFee ?? 0))))}',
                                          style: Theme.of(Get.context!)
                                              .textTheme
                                              .titleLarge,
                                          textAlign: TextAlign.end)),
                                ],
                              ),
                            ),
                          if (invoice.payment!.debt! > 0)
                            ListTile(
                              dense: true,
                              title: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text('SUDAH BAYAR:',
                                        style: Theme.of(Get.context!)
                                            .textTheme
                                            .titleSmall,
                                        textAlign: TextAlign.right),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                        'Rp.${controller.currency.format(invoice.payment!.totalPay)}',
                                        style: Theme.of(Get.context!)
                                            .textTheme
                                            .titleSmall,
                                        textAlign: TextAlign.end),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                          if (invoice.payment!.debt! > 0)
                            ListTile(
                              dense: true,
                              title: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text('TAGIHAN YANG PERLU DIBAYAR:',
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
                                      'Rp.${controller.currency.format((invoice.payment!.debt!) - ((invoice.payment!.totalReturn ?? 0) - (invoice.payment!.returnFee ?? 0)))}',
                                      style: Theme.of(Get.context!)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.red),
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
                        ],
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (invoice.payment!.debt! > 0)
                        ElevatedButton(
                          onPressed: () {
                            TextEditingController repaymentCtrlText =
                                controller.repaymentCtrlText;
                            repaymentCtrlText.text = '';
                            controller.totalChange.value = 0;
                            controller.showChange.value =
                                controller.totalChange.value > 0;
                            Get.defaultDialog(
                              title: 'Lunasi Tagihan',
                              content: Obx(
                                () => Column(
                                  children: [
                                    const Text('Tagihan yang harus dibayar: '),
                                    Text(
                                      'Rp.${controller.currency.format((0 * -1) - controller.totalReturnFinal.value)}',
                                      style: context.textTheme.bodyLarge,
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: TextField(
                                          style: context.textTheme.titleLarge,
                                          textAlign: TextAlign.right,
                                          controller: repaymentCtrlText,
                                          decoration: InputDecoration(
                                            prefixIcon: Text(
                                              'Rp.',
                                              style:
                                                  context.textTheme.titleLarge,
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
                                            controller.onPayChanged(
                                                value, invoice);
                                          }),
                                    ),
                                    if (controller.showChange.value)
                                      Text(
                                        'Kembalian: Rp.${controller.currency.format(controller.totalChange.value)}',
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                                fontStyle: FontStyle.italic),
                                      ),
                                  ],
                                ),
                              ),
                              confirm: ElevatedButton(
                                onPressed: () {
                                  controller.handleRepayment(invoice);
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
      )
      // : const CircularProgressIndicator(),
      // ),
      );
}
