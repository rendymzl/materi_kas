import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materi_kas/app/data/models/product_model.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../widget/side_menu_widget.dart';
import '../controllers/product_controller.dart';

class ProductView extends GetView<ProductController> {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F8FF),
        title: const Text('Daftar Barang'),
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
                flex: 4,
                child: SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 13,
                        child: ProductListCard(
                            controller: controller,
                            formatter: formatter), //! 1 ProductListCard
                      ),
                      // const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() => Text(
                                  'Total barang: ${controller.totalProduct.value.toString()}',
                                  style: context.textTheme.bodySmall,
                                )),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    controller.bindingEditData(Product(
                                        productId: '',
                                        productName: '',
                                        sellPrice: 0,
                                        costPrice: 0,
                                        sold: 0,
                                        uuid: ''));
                                    addEditDialog(context, controller, null,
                                        'Tambah Barang');
                                  },
                                  child: const Text('Tambah Barang'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    controller.pickCSV(context);
                                  },
                                  child: const Text('Upload CSV'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

//! 1 ProductListCard ==================================================================
class ProductListCard extends StatelessWidget {
  const ProductListCard({
    super.key,
    required this.controller,
    required this.formatter,
  });

  final ProductController controller;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Cari Barang",
                labelStyle: TextStyle(color: Colors.grey),
                suffixIcon: Icon(Symbols.search),
              ),
              onChanged: (value) => controller.filterProducts(value),
            ),
            const TableHeader(), //* TableHeader
            Divider(color: Colors.grey[500]),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey[300]),
                  itemCount: controller.foundProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final foundProduct = controller.foundProducts[index];
                    return TableContent(
                        foundProduct: foundProduct,
                        formatter: formatter,
                        controller: controller); //* TableContent
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//* TableHeader from ProductListCard ==================================================================
class TableHeader extends StatelessWidget {
  const TableHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        child: Text(
          'Kode',
          style: context.textTheme.headlineSmall,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 11,
            child: SizedBox(
              child: Text(
                'Nama Barang',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Harga Jual',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Harga Modal',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Selisih',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              child: Text(
                'Terjual',
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      trailing: Text(
        'Hapus',
        style: context.textTheme.headlineSmall,
      ),
    );
  }
}

//* TableContent from ProductListCard ==================================================================
class TableContent extends StatelessWidget {
  const TableContent({
    super.key,
    required this.foundProduct,
    required this.formatter,
    required this.controller,
  });

  final Product foundProduct;
  final NumberFormat formatter;
  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        child: Text(
          foundProduct.productId!,
          style: context.textTheme.bodySmall,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 11,
            child: Container(
              padding: const EdgeInsets.only(right: 30),
              child: Text(
                '${foundProduct.productName}',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Rp. ${formatter.format(foundProduct.sellPrice)}',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Rp. ${formatter.format(foundProduct.costPrice)}',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Rp. ${formatter.format(foundProduct.sellPrice! - foundProduct.costPrice!)}',
                  style: context.textTheme.titleLarge!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              child: Text(
                '${foundProduct.sold}',
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IconButton(
          onPressed: () => controller.destroyHandle(foundProduct),
          icon: const Icon(
            Symbols.delete,
            color: Colors.red,
          ),
        ),
      ),
      onTap: () {
        controller.bindingEditData(foundProduct);
        addEditDialog(context, controller, foundProduct, 'Edit Barang');
      },
    );
  }
}

//* addEditDialog ==================================================================
void addEditDialog(BuildContext context, ProductController controller,
    Product? foundProduct, String title) {
  controller.clickedField['code'] = false;
  controller.clickedField['productName'] = false;
  controller.clickedField['sell'] = false;
  controller.clickedField['cost'] = false;
  OutlineInputBorder outlineRed =
      const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
  Get.defaultDialog(
    title: title,
    content: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        margin: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * (1 / 2),
        width: MediaQuery.of(context).size.width * (3 / 10),
        child: Form(
          key: controller.formkey,
          autovalidateMode: AutovalidateMode.always,
          onChanged: () => Form.of(primaryFocus!.context!).save(),
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: controller.codeController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Kode',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                ),
                onChanged: (value) => controller.onTextChange(value, 'code'),
                validator: (value) => controller.codeValidator(value!),
                onFieldSubmitted: (_) => controller.handleSave(foundProduct),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.productNameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Nama Barang',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                ),
                onChanged: (value) =>
                    controller.onTextChange(value, 'productName'),
                validator: (value) => controller.productNameValidator(value!),
                onFieldSubmitted: (_) => controller.handleSave(foundProduct),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.sellPriceController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Harga Jual',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                  prefixText: 'Rp. ',
                  prefixStyle: context.textTheme.bodyLarge,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                onChanged: (value) =>
                    controller.onCurrencyChanged(value, 'sell'),
                validator: (value) => controller.sellValidator(value!),
                onFieldSubmitted: (_) => controller.handleSave(foundProduct),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.costPriceController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Harga Modal',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                  prefixText: 'Rp. ',
                  prefixStyle: context.textTheme.bodyLarge,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                onChanged: (value) =>
                    controller.onCurrencyChanged(value, 'cost'),
                validator: (value) => controller.costValidator(value!),
                onFieldSubmitted: (_) => controller.handleSave(foundProduct),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.soldController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Terjual',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                onChanged: (value) => controller.onTextChange(value, 'sold'),
              ),
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
          side: MaterialStateProperty.all(
              BorderSide(color: Colors.black.withOpacity(0.5))),
        ),
        onPressed: () => Get.back(),
        child: const Text('Batal'),
      ),
    ),
  );
}
