// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../main.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/product_model.dart';
// import '../../../data/providers/invoice_services.dart';
// import '../../../data/providers/product_services.dart';
import '../../../widget/customer_input_field_controller.dart';
import '../../../widget/customer_input_field_widget.dart';
import '../../../widget/date_picker_controller.dart';
import '../../../widget/date_picker_widget.dart';
import '../../../widget/payment_card.dart';
import '../../../widget/payment_controller.dart';
import '../../../widget/properties_row_widget.dart';
import '../controllers/invoice_controller.dart';
// import 'add_product_dialog.dart';
// import 'cart_card.dart';
import 'add_product_dialog.dart';
import 'list_cart_widget.dart';

void editDialog(
  BuildContext context,
  InvoiceController controller,
  Invoice invoice,
) async {
  // controller.asignEditData(invoice);
  Get.lazyPut(() => DatePickerController());
  late DatePickerController datePickerC = Get.find();
  // late InvoiceService invoiceServices = Get.find();
  late PaymentController paymentController = Get.put(PaymentController());
  late CustomerInputFieldController customerInputFieldC =
      Get.put(CustomerInputFieldController());
  // late ProductService productService = Get.find();
  if (invoice.customer.value != null) {
    customerInputFieldC.asignCustomer(invoice.customer.value!);
  }

  Invoice editInvoice = await controller.reCreateInvoice(invoice);
  if (!context.mounted) return;

  controller.asignEditData(editInvoice);
  controller.initCartItems.clear();
  paymentController.clear();
  controller.editReturnManual.value = true;
  Get.defaultDialog(
    title: 'Edit Invoice ${editInvoice.invoiceId}',
    content: Obx(
      () {
        return Container(
          margin: const EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * (5 / 7),
          width: MediaQuery.of(context).size.width * (2 / 3),
          child: ListView(
            shrinkWrap: true,
            controller: controller.scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text('Edit Harga', style: context.textTheme.titleLarge),
                  ),
                ],
              ),
              Card(
                child: Container(
                  height: 30,
                  color: Colors.white,
                  margin: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              editInvoice.priceType.value == 2
                                  ? editInvoice.priceType.value = 1
                                  : editInvoice.priceType.value = 2;
                              editInvoice.updateIsDebtPaid();
                            },
                            child: SizedBox(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: editInvoice.priceType.value == 2,
                                    onChanged: (value) {
                                      editInvoice.priceType.value == 2
                                          ? editInvoice.priceType.value = 1
                                          : editInvoice.priceType.value = 2;
                                      editInvoice.updateIsDebtPaid();
                                    },
                                  ),
                                  Text(
                                    'Harga masuk gang',
                                    style: editInvoice.priceType.value == 2
                                        ? context.textTheme.bodySmall!.copyWith(
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
                            onTap: () {
                              editInvoice.priceType.value == 3
                                  ? editInvoice.priceType.value = 1
                                  : editInvoice.priceType.value = 3;
                              editInvoice.updateIsDebtPaid();
                            },
                            child: SizedBox(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: editInvoice.priceType.value == 3,
                                    onChanged: (value) {
                                      editInvoice.priceType.value == 3
                                          ? editInvoice.priceType.value = 1
                                          : editInvoice.priceType.value = 3;
                                      editInvoice.updateIsDebtPaid();
                                    },
                                  ),
                                  Text(
                                    'Harga material',
                                    style: editInvoice.priceType.value == 3
                                        ? context.textTheme.bodySmall!.copyWith(
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Edit Pelanggan',
                        style: context.textTheme.titleLarge),
                  ),
                ],
              ),
              const CustomerInputFieldCard(),
              // CartCard(controller: controller, invoice: editInvoice),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Edit Barang',
                        style: context.textTheme.titleLarge),
                  ),
                ],
              ),
              Card(
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Obx(
                      () {
                        final returnFeeTextC = TextEditingController();
                        returnFeeTextC.text = editInvoice.returnFee.value == 0
                            ? '-'
                            : currency.format(editInvoice.returnFee.value);
                        returnFeeTextC.selection = TextSelection.fromPosition(
                          TextPosition(offset: returnFeeTextC.text.length),
                        );
                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (editInvoice.purchaseList.value
                                        .getTotalReturn(
                                            editInvoice.priceType.value) !=
                                    -1)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text('Return',
                                            style: Theme.of(Get.context!)
                                                .textTheme
                                                .titleLarge,
                                            textAlign: TextAlign.end),
                                        const SizedBox(height: 12),
                                        ListCartWidget(
                                          invoice: editInvoice,
                                          isEdit:
                                              controller.editReturnManual.value,
                                          controller: controller,
                                          isReturn: true,
                                        ),
                                        const SizedBox(height: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                child: TextField(
                                                  controller: returnFeeTextC,
                                                  textAlign: TextAlign.center,
                                                  maxLength: 15,
                                                  decoration: InputDecoration(
                                                    labelText: 'Biaya Return',
                                                    labelStyle: context
                                                        .textTheme.bodySmall!
                                                        .copyWith(
                                                            fontStyle: FontStyle
                                                                .italic),
                                                    prefixText: 'Rp',
                                                    counterText: '',
                                                    filled: true,
                                                    fillColor: Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(0.2),
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    border:
                                                        const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide
                                                                    .none),
                                                    isDense: true,
                                                  ),
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(r'[0-9]'))
                                                  ],
                                                  onChanged: (value) {
                                                    editInvoice
                                                            .returnFee.value =
                                                        value == ''
                                                            ? 0
                                                            : double.parse(value
                                                                .replaceAll(
                                                                    '.', ''));
                                                    // debugPrint(editInvoice.returnFee.value
                                                    //     .toString());
                                                    editInvoice.updateReturn();
                                                    // debugPrint(value);
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: Row(
                                                  children: [
                                                    const Expanded(
                                                        flex: 5,
                                                        child: Text('')),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Text(
                                                        'TOTAL RETURN',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: Theme.of(
                                                                Get.context!)
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
                                                      child: Obx(
                                                        () => Text(
                                                          'Rp${currency.format(editInvoice.totalReturn)}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: Theme.of(
                                                                  Get.context!)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                  color: Theme.of(
                                                                          Get.context!)
                                                                      .colorScheme
                                                                      .primary),
                                                        ),
                                                      ),
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
                                Expanded(
                                  child: SizedBox(
                                    child: Column(
                                      children: [
                                        Text('Pembelian',
                                            style: Theme.of(Get.context!)
                                                .textTheme
                                                .titleLarge,
                                            textAlign: TextAlign.end),
                                        const SizedBox(height: 12),
                                        ListCartWidget(
                                          invoice: editInvoice,
                                          isEdit:
                                              controller.editReturnManual.value,
                                          controller: controller,
                                          isReturn: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.defaultDialog(
                                  content: Container(
                                    margin: const EdgeInsets.all(8),
                                    height: MediaQuery.of(context).size.height *
                                        (3 / 4),
                                    width: MediaQuery.of(context).size.width *
                                        (4 / 9),
                                    child: AddProductDialog(
                                      invoice: editInvoice,
                                      controller: controller,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Tambah Barang',
                              ),
                            ),
                          ],
                        );
                      },
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Edit Pembayaran',
                        style: context.textTheme.titleLarge),
                  ),
                ],
              ),
              Card(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 24),
                      CalculatePrice(
                        controller: controller,
                        editInvoice: editInvoice,
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.showPaymentCard.value &&
                  !editInvoice.isDebtPaid.value)
                PaymentCard(
                  invoice: editInvoice,
                  onClick: () async {
                    await paymentController.addPayment(editInvoice);
                    paymentController.clear();
                    controller.showPaymentCard.value = false;
                  },
                )
            ],
          ),
        );
      },
    ),
    confirm: ElevatedButton(
        onPressed: () async {
          Future process() async {
            DateTime dateTime = DateTime(
              datePickerC.selectedDate.value.year,
              datePickerC.selectedDate.value.month,
              datePickerC.selectedDate.value.day,
              controller.selectedTime.value.hour,
              controller.selectedTime.value.minute,
            );

            // Timestamp timestampDateTime = Timestamp.fromDate(dateTime);

            customerInputFieldC.addCustomer(editInvoice);

            Get.defaultDialog(
              title: 'Menyimpan perubahan',
              content: const CircularProgressIndicator(),
              barrierDismissible: false,
            );
            try {
              Invoice prevInvoice = Invoice.fromJson(invoice.toJson());

              invoice.id = editInvoice.id;
              invoice.invoiceId = editInvoice.invoiceId;
              invoice.createdAt.value = dateTime;
              invoice.customer.value =
                  customerInputFieldC.selectedCustomer.value;
              invoice.purchaseList.value = editInvoice.purchaseList.value;
              invoice.priceType.value = editInvoice.priceType.value;
              invoice.discount.value = editInvoice.discount.value;
              invoice.payments.value = editInvoice.payments;
              invoice.debtAmount.value = editInvoice.debtAmount.value;
              invoice.isDebtPaid.value = editInvoice.isDebtPaid.value;
              invoice.otherCosts.value = editInvoice.otherCosts;

              List<Product> updatedProductList = [];
              for (var stockP in controller.updatedInvQty) {
                final invProduct = invoice.purchaseList.value.items
                    .firstWhereOrNull(
                        (inv) => inv.product.id == stockP.product.id);
                if (invProduct != null) {
                  final existPrevQty = prevInvoice.purchaseList.value.items
                      .firstWhereOrNull(
                          (itm) => itm.product.id == stockP.product.id);

                  double prevQty =
                      existPrevQty != null ? existPrevQty.quantity.value : 0;

                  invProduct.product
                      .updateStock(stockP.product.stock.value, prevQty);

                  updatedProductList.add(invProduct.product);
                } else {
                  final existPrevQty = prevInvoice.purchaseList.value.items
                      .firstWhereOrNull(
                          (itm) => itm.product.id == stockP.product.id);

                  double prevQty =
                      existPrevQty != null ? existPrevQty.quantity.value : 0;

                  existPrevQty!.product.updateStock(0, prevQty);

                  updatedProductList.add(existPrevQty.product);
                }
              }

              // for (var i in updatedProductList) {
              //   debugPrint(i.stock.value.toString());
              // }
// debugPrint(updatedProductList.toString());
              await invoice.update();
              // await invoiceServices.updateInvoice(invoice);
              // await productService.updateMultipleProducts(updatedProductList);
              controller.initCartItems.clear();
              Get.back();
              return Get.defaultDialog(
                title: 'Berhasil',
                middleText: 'Perubahan berhasil disimpan.',
                confirm: TextButton(
                  onPressed: () {
                    invoice.updateIsDebtPaid();
                    Get.back();
                    Get.back();
                    Get.back();
                  },
                  child: const Text('OK'),
                ),
              );
            } catch (e) {
              Get.back();
              Get.defaultDialog(
                title: 'Gagal Melakukan Perubahan',
                middleText: e.toString(),
                barrierDismissible: false,
              );
            }
          }

          Get.defaultDialog(
            title: 'Simpan',
            middleText: 'Simpan perubahan?',
            confirm: TextButton(
              onPressed: () async {
                await process();
              },
              child: const Text('Simpan'),
            ),
            cancel: TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.black.withOpacity(0.5)),
              ),
            ),
          );
        },
        child: const Text('Simpan Perubahan')),
  );
}

//* 2.0 CalculatePrice ==================================================================
class CalculatePrice extends StatelessWidget {
  const CalculatePrice({
    super.key,
    required this.controller,
    required this.editInvoice,
  });

  final InvoiceController controller;
  final Invoice editInvoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(left: 450),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      color: Colors.white,
      child: Obx(
        () {
          Cart editPurchaseList = editInvoice.purchaseList.value;
          bool showTotalPurchase =
              editPurchaseList.getSubtotal(editInvoice.priceType.value) !=
                  editPurchaseList.getTotal(editInvoice.priceType.value);
          bool showDiscount = editPurchaseList.totalIndividualDiscount > 0;
          bool showOtherCost = editInvoice.totalOtherCosts > 0;
          // bool showChange = editPurchaseList.totalIndividualDiscount > 0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Divider(color: Colors.grey[400]),
              // ListCartWidget(
              //   invoice: editInvoice,
              //   isEdit: true,
              //   controller: controller,
              //   isReturn: false,
              // ),
              // Divider(color: Colors.grey[200]),
              // ListTile(
              //   title: Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       ElevatedButton(
              //         onPressed: () {
              //           Get.defaultDialog(
              //             content: Container(
              //               margin: const EdgeInsets.all(8),
              //               height:
              //                   MediaQuery.of(context).size.height * (3 / 4),
              //               width: MediaQuery.of(context).size.width * (4 / 9),
              //               child: AddProductDialog(
              //                 invoice: editInvoice,
              //                 controller: controller,
              //               ),
              //             ),
              //           );
              //         },
              //         child: const Text(
              //           'Tambah Barang',
              //         ),
              //       )
              //     ],
              //   ),
              // ),
              // Divider(color: Colors.grey[400]),
              PropertiesRowWidget(
                title: 'TOTAL HARGA (${editPurchaseList.items.length} Barang)',
                value: currency.format(
                    editPurchaseList.getSubtotal(editInvoice.priceType.value)),
                primary: true,
              ),
              if (showDiscount)
                PropertiesRowWidget(
                  title: 'Total Diskon',
                  value:
                      '-${currency.format(editPurchaseList.totalIndividualDiscount)}',
                  color: Theme.of(Get.context!).colorScheme.primary,
                ),
              if (showOtherCost) Divider(color: Colors.grey[200]),
              if (showOtherCost)
                ListView.separated(
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey[200]),
                  shrinkWrap: true,
                  itemCount: editInvoice.otherCosts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: Colors.amber,
                      dense: true,
                      title: Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: Text(editInvoice.otherCosts[index].name,
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .titleSmall,
                                  textAlign: TextAlign.left)),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  'Rp${currency.format(editInvoice.otherCosts[index].amount)}',
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .titleSmall,
                                  textAlign: TextAlign.end)),
                        ],
                      ),
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: IconButton(
                          onPressed: () => editInvoice.removeOtherCost(
                              editInvoice.otherCosts[index].name),
                          icon: const Icon(
                            Symbols.close,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              if (showOtherCost) Divider(color: Colors.grey[200]),
              if (showTotalPurchase) Divider(color: Colors.grey[200]),
              if (showTotalPurchase)
                PropertiesRowWidget(
                  title: 'TOTAL BELANJA',
                  value: currency.format(editInvoice.total),
                  primary: true,
                ),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 20),
              Divider(color: Colors.grey[200]),
              ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[200]),
                shrinkWrap: true,
                itemCount: editInvoice.payments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: Colors.amber,
                    dense: true,
                    title: Row(
                      children: [
                        Expanded(
                            flex: 5,
                            child: Text(
                                'Pembayaran ${!editInvoice.isDebtPaid.value ? index + 1 : ''} (${DateFormat('dd MMMM y', 'id').format(editInvoice.createdAt.value!)}) (${editInvoice.payments[index].method})',
                                style: Theme.of(Get.context!)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: Colors.green),
                                textAlign: TextAlign.left)),
                        Expanded(
                            flex: 3,
                            child: Text(
                                'Rp${currency.format(editInvoice.payments[index].finalAmountPaid)}',
                                style: Theme.of(Get.context!)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: Colors.green),
                                textAlign: TextAlign.end)),
                      ],
                    ),
                    leading: (controller.isAdmin)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: IconButton(
                              onPressed: () => editInvoice
                                  .removePayment(editInvoice.payments[index]),
                              icon: const Icon(
                                Symbols.close,
                                color: Colors.red,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
              Divider(color: Colors.grey[200]),
              if (!editInvoice.isDebtPaid.value)
                ListTile(
                  dense: true,
                  title: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('TAGIHAN YANG BELUM DIBAYAR:',
                            style: Theme.of(Get.context!)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.right),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rp${currency.format((editInvoice.remainingDebt))}',
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
                  leading: const Text(''),
                ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!editInvoice.isDebtPaid.value && controller.isAdmin)
                      ElevatedButton(
                        onPressed: () {
                          controller.showPaymentCard.value = true;
                          controller.scrollHandle();
                        },
                        child: const Text(
                          'Tambah Pembayaran',
                        ),
                      )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
