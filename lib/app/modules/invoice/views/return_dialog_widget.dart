// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../main.dart';
import '../../../data/models/invoice_model.dart';
// import '../../../data/providers/invoice_services.dart';
import 'add_product_dialog.dart';
import 'list_cart_widget.dart';
import '../controllers/invoice_controller.dart';

void returnDialogWidget(
  BuildContext context,
  InvoiceController controller,
  Invoice invoice,
) async {
  // late InvoiceService invoiceServices = Get.find();
  Invoice editInvoice = await controller.reCreateInvoice(invoice);
  if (!context.mounted) return;

  controller.asignEditData(editInvoice);
  controller.initCartItems.clear();
  controller.updatedInvQty.clear();

  Get.defaultDialog(
    title: 'Return Barang',
    backgroundColor: Colors.white,
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * (5 / 7),
      width: MediaQuery.of(context).size.width * (2 / 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Obx(
          () {
            final returnFeeTextC = TextEditingController();
            returnFeeTextC.text = editInvoice.returnFee.value == 0
                ? '-'
                : currency.format(editInvoice.returnFee.value);
            returnFeeTextC.selection = TextSelection.fromPosition(
              TextPosition(offset: returnFeeTextC.text.length),
            );

            return ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: InkWell(
                        onTap: () => controller.toggleEditReturnManual(),
                        child: SizedBox(
                          child: Row(
                            children: [
                              Checkbox(
                                value: controller.editReturnManual.value,
                                onChanged: (value) =>
                                    controller.toggleEditReturnManual(),
                              ),
                              Text(
                                'Ubah secara manual',
                                style: controller.editReturnManual.value
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
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (editInvoice.purchaseList.value
                            .getTotalReturn(editInvoice.priceType.value) !=
                        -1)
                      Expanded(
                        child: Column(
                          children: [
                            Text('Return',
                                style:
                                    Theme.of(Get.context!).textTheme.titleLarge,
                                textAlign: TextAlign.end),
                            const SizedBox(height: 12),
                            ListCartWidget(
                              invoice: editInvoice,
                              isEdit: controller.editReturnManual.value,
                              controller: controller,
                              isReturn: true,
                            ),
                            if (editInvoice.returnList.value != null)
                              Divider(color: Colors.grey[200]),
                            if (editInvoice.returnList.value != null)
                              const SizedBox(height: 12),
                            if (editInvoice.returnList.value != null)
                              Text('Tambahan Return',
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .titleLarge,
                                  textAlign: TextAlign.end),
                            if (editInvoice.returnList.value != null)
                              const SizedBox(height: 12),
                            if (editInvoice.returnList.value != null)
                              ListCartWidget(
                                invoice: editInvoice,
                                isEdit: controller.editReturnManual.value,
                                controller: controller,
                                isReturn: true,
                                additionalReturn: true,
                              ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ListTile(
                                    title: Row(
                                      children: [
                                        const Expanded(
                                            flex: 5, child: Text('')),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            'NOMINAL RETURN',
                                            textAlign: TextAlign.right,
                                            style: Theme.of(Get.context!)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    color:
                                                        Theme.of(Get.context!)
                                                            .colorScheme
                                                            .primary),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Obx(
                                            () => Text(
                                              'Rp${currency.format(editInvoice.totalReturn + editInvoice.returnFee.value)}',
                                              textAlign: TextAlign.end,
                                              style: Theme.of(Get.context!)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color:
                                                          Theme.of(Get.context!)
                                                              .colorScheme
                                                              .primary),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: TextField(
                                      controller: returnFeeTextC,
                                      textAlign: TextAlign.center,
                                      maxLength: 15,
                                      decoration: InputDecoration(
                                        labelText: 'Biaya Return',
                                        labelStyle: context.textTheme.bodySmall!
                                            .copyWith(
                                                fontStyle: FontStyle.italic),
                                        prefixText: 'Rp',
                                        counterText: '',
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.2),
                                        contentPadding:
                                            const EdgeInsets.all(10),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                        isDense: true,
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]'))
                                      ],
                                      onChanged: (value) {
                                        editInvoice.returnFee.value =
                                            value == ''
                                                ? 0
                                                : double.parse(
                                                    value.replaceAll('.', ''));
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
                                            flex: 5, child: Text('')),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            'TOTAL RETURN',
                                            textAlign: TextAlign.right,
                                            style: Theme.of(Get.context!)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    color:
                                                        Theme.of(Get.context!)
                                                            .colorScheme
                                                            .primary),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Obx(
                                            () => Text(
                                              'Rp${currency.format(editInvoice.totalReturn)}',
                                              textAlign: TextAlign.end,
                                              style: Theme.of(Get.context!)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color:
                                                          Theme.of(Get.context!)
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
                                style:
                                    Theme.of(Get.context!).textTheme.titleLarge,
                                textAlign: TextAlign.end),
                            const SizedBox(height: 12),
                            ListCartWidget(
                              invoice: editInvoice,
                              isEdit: controller.editReturnManual.value,
                              controller: controller,
                              isReturn: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
    confirm: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.editReturnManual.value)
              ElevatedButton(
                onPressed: () {
                  Get.defaultDialog(
                    content: Container(
                      margin: const EdgeInsets.all(8),
                      height: MediaQuery.of(context).size.height * (3 / 4),
                      width: MediaQuery.of(context).size.width * (4 / 9),
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
            if (controller.editReturnManual.value) const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                Future process() async {
                  Get.defaultDialog(
                    title: 'Menyimpan Return',
                    content: const CircularProgressIndicator(),
                    barrierDismissible: false,
                  );
                  try {
                    invoice.updateIsDebtPaid();
                    // debugPrint(editInvoice.isDebtPaid.value.toString());
                    invoice.id = editInvoice.id;
                    invoice.invoiceId = editInvoice.invoiceId;
                    invoice.purchaseList.value = editInvoice.purchaseList.value;
                    // debugPrint(editInvoice.returnFee.value.toString());
                    // debugPrint(editInvoice.purchaseList.value
                    //     .getTotalReturn(editInvoice.priceType.value)
                    //     .toString());

                    if (editInvoice.returnFee.value >= 0) {
                      invoice.returnFee.value = editInvoice.returnFee.value;
                      debugPrint(invoice.returnFee.value.toString());
                    }

                    if (editInvoice.returnList.value != null) {
                      invoice.returnList.value = editInvoice.returnList.value;
                    }

                    // invoice.returnFee.value = editInvoice.purchaseList.value
                    //             .getTotalReturn(editInvoice.priceType.value) ==
                    //         0
                    //     ? 0
                    //     : editInvoice.returnFee.value;
                    invoice.isDebtPaid.value = editInvoice.isDebtPaid.value;
                    invoice.update();
                    Get.back();
                    return Get.defaultDialog(
                      title: 'Berhasil',
                      middleText: 'Return berhasil disimpan.',
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
                      title: 'Gagal Menyimpan Return',
                      middleText: e.toString(),
                    );
                  }
                }

                if (!controller.isComa.value) {
                  Get.defaultDialog(
                    title: 'Simpan',
                    middleText: 'Simpan return?',
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
                } else {
                  Get.defaultDialog(
                    title: 'Error',
                    middleText: 'Jumlah yang dimasukkan tidak valid.',
                  );
                }
              },
              child: const Text('Simpan Return'),
            ),
          ],
        ),
      ),
    ),
  );
}
