import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materi_kas/app/data/models/product_model.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../main.dart';
import '../../../widget/add_product.dart';
import '../../../widget/side_menu_widget.dart';
import '../controllers/product_controller.dart';
import 'buy_product_dialog.dart';

class ProductView extends GetView<ProductController> {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F8FF),
        title: const SideMenuWidget(title: 'Barang'),
      ),
      body: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                            Obx(
                              () => Text(
                                'Total barang: ${controller.totalProduct.value.toString()}',
                                style: context.textTheme.bodySmall,
                              ),
                            ),
                            Obx(
                              () => Text(
                                'Kode terakhir: ${controller.lastCode.value.toString()}',
                                style: context.textTheme.bodySmall,
                              ),
                            ),
                            Row(
                              children: [
                                if (controller.isAdmin.value)
                                  ElevatedButton(
                                    onPressed: () =>
                                        controller.destroyAllHandle(),
                                    child: const Text('HAPUS SEMUA'),
                                  ),
                                if (controller.isAdmin.value)
                                  const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    buyProductDialog(context, null);
                                  },
                                  child: const Text('Beli Barang'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // controller.bindingEditData(null);
                                    addEditDialogProduct(context, null);
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    height: 50,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: "Cari Barang",
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Symbols.search),
                      ),
                      onChanged: (value) => controller.filterProducts(value),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  width: 200,
                  child: Obx(
                    () => InkWell(
                      onTap: () => controller.toggleLowStock(),
                      child: SizedBox(
                        child: Row(
                          children: [
                            Checkbox(
                              value: controller.isLowStock.value,
                              onChanged: (value) => controller.toggleLowStock(),
                            ),
                            Text(
                              'Urutkan stok sedikit',
                              style: controller.isLowStock.value
                                  ? context.textTheme.bodySmall!.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary)
                                  : context.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TableHeader(controller: controller),
            Divider(color: Colors.grey[500]),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey[300]),
                  itemCount: !controller.isLowStock.value
                      ? controller.lowStockProduct.length
                      : controller.foundProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final foundProduct = controller.isLowStock.value
                        ? controller.lowStockProduct[index]
                        : controller.foundProducts[index];
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
    required this.controller,
  });

  final ProductController controller;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 100,
        child: Text(
          'Kode',
          style: context.textTheme.headlineSmall,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 9,
            child: SizedBox(
              child: Text(
                'Nama Barang',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Text(
                'Harga Modal',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Text(
                'Harga Jual 1',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Text(
                'Harga Jual 2',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Text(
                'Harga Jual 3',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          // Expanded(
          //   flex: 4,
          //   child: Container(
          // color: Colors.amber,
          //     child: Text(
          //       'Selisih',
          //       style: context.textTheme.headlineSmall,
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Stok',
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Min. Stok',
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      // trailing: controller.isAdmin.value
      //     ? Text(
      //         'Hapus',
      //         style: context.textTheme.headlineSmall,
      //       )
      //     : null,
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
    return Obx(
      () => Container(
        color: foundProduct.stock.value < foundProduct.stockMin.value
            ? Colors.red[200]
            : null,
        child: ListTile(
          leading: SizedBox(
            width: 100,
            child: Text(
              foundProduct.productId,
              style: context.textTheme.bodySmall,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                flex: 9,
                child: SizedBox(
                  child: Text(
                    foundProduct.productName,
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: SizedBox(
                  child: Text(
                    'Rp. ${formatter.format(foundProduct.costPrice.value)}',
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Rp. ${formatter.format(foundProduct.sellPrice1)}',
                    style: context.textTheme.titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[500],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Rp. ${formatter.format(foundProduct.sellPrice2)}',
                    style: context.textTheme.titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Rp. ${formatter.format(foundProduct.sellPrice3)}',
                    style: context.textTheme.titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              // Expanded(
              //   flex: 4,
              //   child: SizedBox(
              //     child: Container(
              //       padding: const EdgeInsets.all(8),
              //       decoration: BoxDecoration(
              //         color: Theme.of(context).colorScheme.primary,
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       child: Text(
              //         'Rp. ${formatter.format(foundProduct.sellPrice1 - foundProduct.costPrice)}',
              //         style: context.textTheme.titleLarge!
              //             .copyWith(color: Colors.white),
              //       ),
              //     ),
              //   ),
              // ),
              Expanded(
                flex: 4,
                child: SizedBox(
                  child: Text(
                    '${decimal.format(foundProduct.stock.value)} ',
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: SizedBox(
                  child: Text(
                    '${decimal.format(foundProduct.stockMin.value)} ${foundProduct.unit}',
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // trailing: controller.isAdmin.value
          //     ? Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 4),
          //         child: IconButton(
          //           onPressed: () => controller.destroyHandle(foundProduct),
          //           icon: const Icon(
          //             Symbols.delete,
          //             color: Colors.red,
          //           ),
          //         ),
          //       )
          //     : null,
          onTap: () {
            // controller.bindingEditData(foundProduct);
            addEditDialogProduct(context, foundProduct);
          },
        ),
      ),
    );
  }
}

//! Loading Dialog
class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    super.key,
    required this.controller,
  });

  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    final currentCsv = controller.currentCsvData.value;
    final totalCsv = controller.totalCsvData.value;
    final emptyCsv = controller.emptyCsv.value;
    return Obx(
      () => AlertDialog(
        title: const Text('Menambahkan Barang'),
        content: Column(
          children: [
            (currentCsv != totalCsv)
                ? Text(
                    'Menambahkan barang ke-$currentCsv dari $totalCsv baris Excel')
                : Text(
                    'Berhasil menambahkan ${totalCsv - emptyCsv} barang dari $totalCsv baris Excel'),
            if (emptyCsv > 0) Text('Baris kosong: $emptyCsv barang'),
            if (currentCsv != totalCsv) const CircularProgressIndicator(),
          ],
        ),
        actions: <Widget>[
          if (currentCsv != totalCsv)
            TextButton(
              onPressed: () => controller.isLoading.value = false,
              child: const Text('Oke'),
            ),
        ],
      ),
    );
  }
}
