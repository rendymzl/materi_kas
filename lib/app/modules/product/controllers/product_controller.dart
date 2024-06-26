import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:async' show Future, Timer;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import '../../../../main.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/product_provider.dart';

class ProductController extends GetxController {
  final provider = ProductProvider();
  final csvList = <Product>[].obs;
  late final String uuid;
  late final List<Product> productList = <Product>[].obs;
  late final List<Product> allProductList = <Product>[].obs;
  final totalProduct = 0.obs;
  final lastCode = ''.obs;
  final isLoading = false.obs;
  final totalCsvData = 1.obs;
  final currentlCsvData = 0.obs;
  final emptyCsv = 0.obs;
  final foundProducts = <Product>[].obs;

  @override
  void onInit() async {
    super.onInit();
    uuid = supabase.auth.currentUser!.id;

    List<Product> newData = await ProductProvider.fetchData(uuid, '');
    refreshFetch(newData);
  }

  //! Fetch
  void refreshFetch(List<Product> newData) async {
    productList.clear();
    allProductList.assignAll(
        await ProductProvider.getAllProduct(totalProduct.value, uuid));
    // newData.sort((a, b) => b.sold!.compareTo(a.sold!));
    productList.assignAll(newData);
    foundProducts.value = productList;

    totalProduct.value = await ProductProvider.getTotalRowCount(uuid);

    List<Product> allProductreversed = List.from(allProductList);

    lastCode.value = allProductreversed.isEmpty
        ? 'Tidak ada barang'
        : allProductreversed[0].productId!;

    allProductreversed.clear();
  }

  Timer? debounce;
  void filterProducts(String productName) async {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 200), () async {
      List<Product> newData =
          await ProductProvider.fetchData(uuid, productName);
      refreshFetch(newData);
    });

    // productName.isEmpty
    //     ? result = productList
    //     : result = productList
    //         .where((product) => product.productName
    //             .toString()
    //             .toLowerCase()
    //             .contains(productName))
    //         .toList();

    // foundProducts.value = newData;
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  //! pickCSV
  final isSafe = true.obs;
  Future<void> pickCSV(BuildContext context) async {
    isSafe.value = true;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          List<List<dynamic>> csvData = await readCSV(filePath);
          totalCsvData.value = csvData.length + 1;
          List<Product> productList = [];
          if (!context.mounted) return;
          ProgressDialog dialog = ProgressDialog(context: context);

          dialog.show(
            msg: 'Menambahkan Barang dari Excel...',
            max: totalCsvData.value,
          );
          for (var i = 1; i < csvData.length; i++) {
            var data = csvData[i];

            if (data[1] != '') {
              var existingProduct = <Product>[];
              existingProduct = checkexistingProduct(data[0] as String);

              int sellPrice = 0;
              int costPrice = 0;

              if (data.length > 2 &&
                  data[2].toString().contains("Rp") &&
                  !data[2].toString().contains("-")) {
                sellPrice = int.parse(data[2].replaceAll(RegExp(r'[Rp,]'), ''));
              }

              if (data.length > 3 &&
                  data[3].toString().contains("Rp") &&
                  !data[3].toString().contains("-")) {
                costPrice = int.parse(data[3].replaceAll(RegExp(r'[Rp,]'), ''));
              }
              final newProduct = Product(
                productId: data[0],
                featured: false,
                productName: data[1],
                sellPrice: sellPrice,
                costPrice: costPrice,
                sold: 0,
                uuid: uuid,
              );

              if (existingProduct.isEmpty) {
                //   updateProduct(newProduct, existingProduct[0].id!,
                //       existingProduct[0].productId!);
                // } else {
                productList.add(newProduct);
                // await addProduct(newProduct);
              }
              if (!isSafe.value) {
                break;
              }
            } else {
              emptyCsv.value = i + 1;
            }
            dialog.update(value: i + 1);
          }
          List<Map<String, Object?>> newProductList = productList
              .map((newProduct) => {
                    'product_id': newProduct.productId,
                    'featured': newProduct.featured,
                    'product_name': newProduct.productName,
                    'sell_price': newProduct.sellPrice,
                    'cost_price': newProduct.costPrice,
                    'sold': newProduct.sold,
                    'owner_id': newProduct.uuid
                  })
              .toList();
          await addProduct(newProductList);
        }
      }
    } catch (e) {
      debugPrint('Error while picking CSV file: $e');
    }
  }

  // void dialogLoading() {
  //   Get.defaultDialog(
  //     title: 'Menambahkan Barang',
  //     barrierDismissible: false,
  //     content: Column(
  //       children: [
  //         (currentlCsvData.value != totalCsvData.value)
  //             ? Text(
  //                 'Menambahkan barang ke-${currentlCsvData.value} dari ${totalCsvData.value} baris Excel')
  //             : Text(
  //                 'Berhasil menambahkan ${totalCsvData.value - emptyCsv.value} barang dari ${totalCsvData.value} baris Excel'),
  //         if (emptyCsv.value > 0)
  //           Text('Baris kosong: ${emptyCsv.value} barang'),
  //         if (currentlCsvData.value != totalCsvData.value)
  //           const CircularProgressIndicator(),
  //       ],
  //     ),
  //     confirm: (currentlCsvData.value != totalCsvData.value)
  //         ? TextButton(onPressed: () => Get.back(), child: const Text('Oke'))
  //         : null,
  //   );
  // }

  //! update
  Future updateProduct(
      Product newProduct, String curentid, String curentProductId) async {
    if (newProduct.productId != curentProductId) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'Kode yang dimasukkan sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } else {
      try {
        Map<String, Object?> data = {
          'product_id': newProduct.productId,
          'featured': newProduct.featured,
          'product_name': newProduct.productName,
          'sell_price': newProduct.sellPrice,
          'cost_price': newProduct.costPrice,
          'sold': newProduct.sold,
          'owner_id': newProduct.uuid
        };
        List<Product> newData =
            await ProductProvider.update(data, curentid, uuid);
        refreshFetch(newData);
      } on PostgrestException catch (e) {
        Get.defaultDialog(
          title: 'Error',
          middleText: e.message,
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    }
  }

  void updateSuccessDialog() async {
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Product berhasil diupdate',
      confirm: TextButton(
        onPressed: () {
          Get.back();
          Get.back();
        },
        child: const Text('OK'),
      ),
    );
  }

  List<Product> checkexistingProduct(String newProductId) {
    var existingProduct = <Product>[];
    existingProduct = allProductList
        .where((product) => product.productId == newProductId)
        .toList();
    return existingProduct;
  }

  //! create
  Future addProduct(List<Map<String, Object?>> newProductList) async {
    try {
      List<Product> newData =
          await ProductProvider.create(newProductList, uuid);
      refreshFetch(newData);
      Get.back();
    } on PostgrestException catch (e) {
      isSafe.value = false;
      String errorMessage = e.message;
      if (errorMessage.toLowerCase().contains('duplicate')) {
        errorMessage = 'Kode produk sudah ada sebelumnya.';
      }
      Get.defaultDialog(
        title: 'Error',
        middleText: errorMessage,
        confirm: TextButton(
          onPressed: () {
            isSafe.value = false;
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    }
    // }
  }

  void addSuccessDialog() async {
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Product berhasil ditambahkan',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
  }

  //! delete
  destroyHandle(Product product) async {
    try {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Hapus barang ini?',
        confirm: TextButton(
          onPressed: () async {
            List<Product> newData = await ProductProvider.destroy(product);
            refreshFetch(newData);
            Get.back();
          },
          child: const Text('OK'),
        ),
        cancel: TextButton(
          onPressed: () => Get.back(),
          child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
        ),
      );
    } on PostgrestException catch (e) {
      Get.defaultDialog(
        title: 'Error',
        middleText: e.message,
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }

  destroyAllHandle() async {
    try {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Hapus semua barang?',
        confirm: TextButton(
          onPressed: () async {
            List<Product> newData = await ProductProvider.destroyAll(uuid);
            refreshFetch(newData);
            Get.back();
          },
          child: const Text('OK'),
        ),
        cancel: TextButton(
          onPressed: () => Get.back(),
          child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
        ),
      );
    } on PostgrestException catch (e) {
      Get.defaultDialog(
        title: 'Error',
        middleText: e.message,
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }

  //! edit form
  final codeController = TextEditingController();
  final productNameController = TextEditingController();
  final sellPriceController = TextEditingController();
  final costPriceController = TextEditingController();
  final soldController = TextEditingController();
  final numberFormat = NumberFormat("#,##0", "id_ID");
  // final stockController = TextEditingController();
  void bindingEditData(Product foundProduct) {
    codeController.text = foundProduct.productId!;
    productNameController.text = foundProduct.productName!;
    sellPriceController.text =
        numberFormat.format(foundProduct.sellPrice!).toString();
    costPriceController.text =
        numberFormat.format(foundProduct.costPrice!).toString();
    soldController.text =
        foundProduct.sold! == 0 ? '' : foundProduct.sold!.toString();
    // stockController.text = foundProduct.sellPrice!.toString();
  }

  final formkey = GlobalKey<FormState>();

  final clickedField = {
    'code': false,
    'productName': false,
    'sell': false,
    'cost': false,
  }.obs;

  String? codeValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['code'] == true) {
      return 'Kode tidak boleh kosong';
    }
    return null;
  }

  String? productNameValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['productName'] == true) {
      return 'Nama barang tidak boleh kosong';
    }
    return null;
  }

  String? sellValidator(String value) {
    value = value.trim();
    if ((value.isEmpty || value == '0') && clickedField['sell'] == true) {
      return 'Harga Jual tidak boleh kosong';
    }
    return null;
  }

  String? costValidator(String value) {
    value = value.trim();
    if ((value.isEmpty || value == '0') && clickedField['cost'] == true) {
      return 'Harga Modal tidak boleh kosong';
    }
    return null;
  }

  void onCurrencyChanged(String value, String field) {
    clickedField[field] = true;
    if (value.isNotEmpty) {
      String newValue =
          numberFormat.format(int.parse(value.replaceAll('.', '')));
      if (newValue !=
          (field == 'sell'
              ? sellPriceController.text
              : costPriceController.text)) {
        final textController =
            field == 'sell' ? sellPriceController : costPriceController;
        textController.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }
  }

  void onTextChange(String value, String field) {
    clickedField[field] = true;
  }

  Future handleSave(Product? curentProduct) async {
    isSafe.value = true;
    clickedField['code'] = true;
    clickedField['productName'] = true;
    clickedField['sell'] = true;
    clickedField['cost'] = true;
    List<Product> productList = [];
    if (formkey.currentState!.validate()) {
      final newProduct = Product(
        productId: codeController.text,
        featured: false,
        productName: productNameController.text,
        sellPrice: int.parse(sellPriceController.text.replaceAll('.', '')),
        costPrice: int.parse(costPriceController.text.replaceAll('.', '')),
        sold: soldController.text == '' ? 0 : int.parse(soldController.text),
        uuid: uuid,
      );
      if (curentProduct != null) {
        await updateProduct(
            newProduct, curentProduct.id!, curentProduct.productId!);
        if (isSafe.value) {
          updateSuccessDialog();
        }
      } else {
        productList.add(newProduct);
      }
    }
    List<Map<String, Object?>> newProductList = productList
        .map((newProduct) => {
              'product_id': newProduct.productId,
              'featured': newProduct.featured,
              'product_name': newProduct.productName,
              'sell_price': newProduct.sellPrice,
              'cost_price': newProduct.costPrice,
              'sold': newProduct.sold,
              'owner_id': newProduct.uuid
            })
        .toList();

    await addProduct(newProductList);
    if (isSafe.value) {
      addSuccessDialog();
    }
  }

  featuredHandle(bool value, Product product) {
    int index =
        productList.indexWhere((selectItem) => selectItem.id == product.id);

    product.featured = value;
    productList.replaceRange(index, index + 1, [product]);
    foundProducts.sort((a, b) {
      if (a.featured == b.featured) {
        return b.sold!.compareTo(a.sold!);
      } else {
        return b.featured! ? 1 : -1;
      }
    });
  }

  Future<List<List<dynamic>>> readCSV(String filePath) async {
    String csvData = await File(filePath).readAsString();
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);
    return csvTable;
  }

  void loadingDialog() async {
    await Get.defaultDialog(
      title: 'Menambahkan Barang',
      middleText: 'Sedang menambahkan barang',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
  }
}
