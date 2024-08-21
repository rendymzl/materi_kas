import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/models/product_model.dart';
import 'add_product_controller.dart';

//* addEditDialog ==================================================================
void addEditDialogProduct(
  BuildContext context,
  Product? foundProduct,
) {
  AddProductController controller = Get.put(AddProductController());

  controller.bindingEditData(foundProduct);

  controller.clickedField['code'] = false;
  controller.clickedField['productName'] = false;
  controller.clickedField['unit'] = false;
  controller.clickedField['sell1'] = false;
  controller.clickedField['sell2'] = false;
  controller.clickedField['sell3'] = false;
  controller.clickedField['stock'] = false;
  controller.clickedField['min_stock'] = false;
  controller.clickedField['cost'] = false;

  Get.defaultDialog(
    title: foundProduct != null ? 'Edit Barang' : 'Tambah Barang',
    content: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        margin: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * (3 / 5),
        width: MediaQuery.of(context).size.width * (3 / 10),
        child: Form(
          key: controller.formkey,
          autovalidateMode: AutovalidateMode.always,
          onChanged: () => Form.of(primaryFocus!.context!).save(),
          child: ListView(
            children: <Widget>[
              // const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: buildTextFormField(
                      controller: controller.codeTextC,
                      context: context,
                      labelText: 'Kode Barang',
                      onChanged: (value) =>
                          controller.onTextChange(value, 'code'),
                      validator: (value) => controller.fieldValidator(
                          value!, 'code', 'Kode tidak boleh kosong'),
                      onFieldSubmitted: (_) =>
                          controller.handleSave(foundProduct),
                    ),
                  ),
                  if (controller.isAdmin)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: IconButton(
                        onPressed: () =>
                            controller.destroyHandle(foundProduct!),
                        icon: const Icon(
                          Symbols.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              // const SizedBox(height: 20),
              buildTextFormField(
                controller: controller.productNameTextC,
                context: context,
                labelText: 'Nama Barang',
                onChanged: (value) =>
                    controller.onTextChange(value, 'productName'),
                validator: (value) => controller.fieldValidator(
                    value!, 'productName', 'Nama barang tidak boleh kosong'),
                onFieldSubmitted: (_) => controller.handleSave(foundProduct),
              ),
              // const SizedBox(height: 20),
              // Autocomplete<Sales>(
              //   initialValue: controller.salesTextC.value,
              //   optionsBuilder: (TextEditingValue salesTextC) {
              //     if (salesTextC.text.isEmpty) {
              //       return const Iterable<Sales>.empty();
              //     } else {
              //       return controller.sales.where((Sales sales) {
              //         final String customerName =
              //             sales.name?.toLowerCase() ?? '';
              //         final String input = salesTextC.text.toLowerCase();
              //         return customerName.contains(input);
              //       });
              //     }
              //   },
              // displayStringForOption: (Sales customer) => customer.name ?? '',
              // fieldViewBuilder: (BuildContext context,
              //     TextEditingController salesTextC,
              //     FocusNode focusNode,
              //     VoidCallback onFieldSubmitted) {
              //   return TextFormField(
              //     controller: salesTextC,
              //     focusNode: focusNode,
              //     onChanged: (value) {
              //       debugPrint(controller.sales.length.toString());
              //       final newCustomer = controller.sales.firstWhere(
              //         (customer) =>
              //             customer.name?.toLowerCase() == value.toLowerCase(),
              //         orElse: () =>
              //             Sales(name: value, createdAt: Timestamp.now()),
              //       );

              //       controller.selectedSales.value = newCustomer;
              //     },
              //     onFieldSubmitted: (String value) {
              //       onFieldSubmitted();
              //     },
              //     decoration: const InputDecoration(
              //       labelText: "Sales",
              //       labelStyle: TextStyle(color: Colors.grey),
              //       border: OutlineInputBorder(),
              //     ),
              //   );
              // },
              //   optionsViewBuilder: (BuildContext context,
              //       AutocompleteOnSelected<Sales> onSelected,
              //       Iterable<Sales> options) {
              //     final int optionsLength = options.length;
              //     const double itemHeight = 56.0;
              //     final double maxHeight = itemHeight * optionsLength;

              //     return Align(
              //       alignment: Alignment.topLeft,
              //       child: Material(
              //         elevation: 4.0,
              //         child: SizedBox(
              //           width: MediaQuery.of(context).size.width * (1 / 4),
              //           height: maxHeight > 150 ? 150 : maxHeight,
              //           child: ListView.builder(
              //             padding: const EdgeInsets.all(8.0),
              //             itemCount: optionsLength,
              //             itemBuilder: (BuildContext context, int index) {
              //               final Sales option = options.elementAt(index);
              //               return ListTile(
              //                 title: Text(option.name ?? ''),
              //                 onTap: () {
              //                   onSelected(option);
              //                 },
              //               );
              //             },
              //           ),
              //         ),
              //       ),
              //     );
              //   },
              //   onSelected: (Sales customer) {
              //     controller.selectedSales.value = customer;
              //   },
              // ),
              // const SizedBox(height: 20),
              buildTextFormField(
                controller: controller.costPriceTextC,
                context: context,
                labelText: 'Harga Sales',
                prefixText: 'Rp. ',
                onChanged: (value) =>
                    controller.onCurrencyChanged(value, 'cost'),
                validator: (value) => controller.fieldValidator(
                    value!, 'cost', 'Harga sales tidak boleh kosong'),
                onFieldSubmitted: (_) => controller.handleSave(foundProduct),
                isCurrency: true,
              ),
              // const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: buildTextFormField(
                      controller: controller.sellPriceTextC1,
                      context: context,
                      labelText: 'Harga Jual 1',
                      prefixText: 'Rp. ',
                      onChanged: (value) =>
                          controller.onCurrencyChanged(value, 'sell1'),
                      validator: (value) => controller.fieldValidator(
                          value!, 'sell1', 'Harga jual 1 tidak boleh kosong'),
                      onFieldSubmitted: (_) =>
                          controller.handleSave(foundProduct),
                      isCurrency: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextFormField(
                      controller: controller.sellPriceTextC2,
                      context: context,
                      labelText: 'Harga Jual 2',
                      prefixText: 'Rp. ',
                      onChanged: (value) =>
                          controller.onCurrencyChanged(value, 'sell2'),
                      onFieldSubmitted: (_) =>
                          controller.handleSave(foundProduct),
                      isCurrency: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextFormField(
                      controller: controller.sellPriceTextC3,
                      context: context,
                      labelText: 'Harga Jual 3',
                      prefixText: 'Rp. ',
                      onChanged: (value) =>
                          controller.onCurrencyChanged(value, 'sell3'),
                      onFieldSubmitted: (_) =>
                          controller.handleSave(foundProduct),
                      isCurrency: true,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: buildTextFormField(
                      controller: controller.unitTextC,
                      context: context,
                      labelText: 'Satuan',
                      onChanged: (value) =>
                          controller.onTextChange(value, 'unit'),
                      validator: (value) => controller.fieldValidator(
                          value!, 'unit', 'Satuan tidak boleh kosong'),
                      onFieldSubmitted: (_) =>
                          controller.handleSave(foundProduct),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextFormField(
                      controller: controller.stockTextC,
                      context: context,
                      labelText: 'Stok',
                      onChanged: (value) =>
                          controller.onTextChange(value, 'stock'),
                      onFieldSubmitted: (_) =>
                          controller.handleSave(foundProduct),
                      isNumeric: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextFormField(
                      controller: controller.minStockTextC,
                      context: context,
                      labelText: 'Minimal Stok',
                      onChanged: (value) =>
                          controller.onTextChange(value, 'min_stock'),
                      onFieldSubmitted: (_) =>
                          controller.handleSave(foundProduct),
                      isNumeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // buildTextFormField(
              //   controller: controller.soldTextC,
              //   context: context,
              //   labelText: 'Terjual',
              //   onChanged: (value) => controller.onTextChange(value, 'sold'),
              //   onFieldSubmitted: (_) => controller.handleSave(foundProduct),
              //   isNumeric: true,
              // ),
            ],
          ),
        ),
      ),
    ),
    backgroundColor: Colors.white,
    confirm: Container(
      margin: const EdgeInsets.all(10),
      width: 160,
      child: ElevatedButton(
        onPressed: () async => await controller.handleSave(foundProduct),
        child: const Text('Simpan'),
      ),
    ),
    cancel: Container(
      margin: const EdgeInsets.all(10),
      width: 160,
      child: OutlinedButton(
        style: ButtonStyle(
          side: WidgetStateProperty.all(
              BorderSide(color: Colors.black.withOpacity(0.5))),
        ),
        onPressed: () => Get.back(),
        child: const Text('Batal'),
      ),
    ),
  );
}

Widget buildTextFormField({
  required TextEditingController controller,
  required String labelText,
  required BuildContext context,
  required Function(String) onChanged,
  String? Function(String?)? validator,
  required Function(String) onFieldSubmitted,
  String prefixText = '',
  bool isCurrency = false,
  bool isNumeric = false,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: const BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    height: 50,
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle:
            TextStyle(color: Theme.of(context).colorScheme.primary),
        focusedErrorBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        errorBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        prefixText: prefixText,
        prefixStyle: prefixText.isNotEmpty ? const TextStyle() : null,
      ),
      keyboardType: isNumeric || isCurrency
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumeric || isCurrency
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
          : [],
      onChanged: onChanged,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    ),
  );
}
