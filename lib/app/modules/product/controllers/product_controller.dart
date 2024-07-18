import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:async' show Future;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

// import '../../../../main.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/auth_services.dart';
// import '../../../data/providers/product_provider.dart';
import '../../../data/providers/product_services.dart';

class ProductController extends GetxController {
  final ProductService productService = Get.find();
  final AuthService authService = Get.find();

  late final products = productService.products;
  late final foundProducts = productService.foundProducts;
  late final totalProduct = productService.productsLenght;
  late final lastCode = productService.lastProductCode;

  // final provider = ProductProvider();
  final csvList = <Product>[].obs;
  // late final String uuid;
  // late final List<Product> productList = <Product>[].obs;
  // late final List<Product> allProductList = <Product>[].obs;
  // final totalProduct = 0.obs;
  // final lastCode = ''.obs;
  final isLoading = false.obs;
  final totalCsvData = 0.obs;
  final currentCsvData = 0.obs;
  final emptyCsv = 0.obs;
  // final foundProducts = <Product>[].obs;

  @override
  void onInit() async {
    super.onInit();
    filterProducts('');
    // totalProduct.value = productService.products.length;

    // List<Product> allProductreversed = List.from(productService.products);

    // lastCode.value = productService.products.isEmpty
    //     ? 'Tidak ada barang'
    //     : productService
    //         .products[productService.products.length - 1].productId!;

    // allProductreversed.clear();
    // uuid = supabase.auth.currentUser!.id;

    // List<Product> newData = await ProductProvider.fetchData(uuid, '');
    // refreshFetch(newData);
  }

  //! Fetch
  // void refreshFetch(List<Product> newData) async {
  // productList.clear();
  // allProductList.assignAll(
  // await ProductProvider.getAllProduct(totalProduct.value, uuid));
  // newData.sort((a, b) => b.sold!.compareTo(a.sold!));
  // productList.assignAll(newData);
  // foundProducts.value = productList;

  // totalProduct.value = productService.products.length;

  //   List<Product> allProductreversed = List.from(productService.products);

  //   lastCode.value = allProductreversed.isEmpty
  //       ? 'Tidak ada barang'
  //       : allProductreversed[0].productId!;

  //   allProductreversed.clear();
  // }

  // Timer? debounce;
  void filterProducts(String productName) {
    productService.searchProducts(productName);
    // if (products.isNotEmpty) {
    //   productService.searchProducts(productName);
    // }
    // if (debounce?.isActive ?? false) debounce!.cancel();
    // debounce = Timer(const Duration(milliseconds: 200), () async {
    // List<Product> newData =
    // await ProductProvider.fetchData(uuid, productName);
    // refreshFetch(newData);
    // });

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

  // @override
  // void dispose() {
  // debounce?.cancel();
  // super.dispose();
  // }

  //! pickCSV
  // final isSafe = true.obs;
  Future<void> pickCSV(BuildContext context) async {
    // isSafe.value = true;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          List<List<dynamic>> csvData = await readCSV(filePath);
          // totalCsvData.value = csvData.length;
          // List<Product> productList = [];
          Map<String, Map<String, dynamic>> productsMap = {};
          if (!context.mounted) return;
          ProgressDialog dialog = ProgressDialog(context: context);

          dialog.show(
            msg: 'Menambahkan Barang dari Excel...',
            max: csvData.length,
          );
          for (var i = 1; i < csvData.length; i++) {
            var data = csvData[i];

            if (data[1] != '') {
              var existingProduct = checkexistingProduct(data[0] as String);

              if (existingProduct.isEmpty) {
                int sellPrice = 0;
                int costPrice = 0;

                if (data.length > 2 &&
                    data[2].toString().contains("Rp") &&
                    !data[2].toString().contains("-")) {
                  sellPrice =
                      int.parse(data[2].replaceAll(RegExp(r'[Rp,]'), ''));
                }

                if (data.length > 3 &&
                    data[3].toString().contains("Rp") &&
                    !data[3].toString().contains("-")) {
                  costPrice =
                      int.parse(data[3].replaceAll(RegExp(r'[Rp,]'), ''));
                }
                String newProductId = await productService.getId();

                final product = Product(
                  id: newProductId,
                  productId: data[0],
                  createdAt: Timestamp.now(),
                  featured: false,
                  productName: data[1],
                  sellPrice: costPrice,
                  costPrice: sellPrice,
                  sold: 0,
                  uuid: authService.uid.value,
                );
                // productList.add(product);
                productsMap[newProductId] = product.toJson();
                // productsMap[newProductId] = product.toJson();
              }
            } else {
              emptyCsv.value = i + 1;
            }
            dialog.update(value: i + 1);
          }
          // List<Map<String, Object?>> newProductList = productList
          //     .map((newProduct) => {
          //           'product_id': newProduct.productId,
          //           'featured': newProduct.featured,
          //           'product_name': newProduct.productName,
          //           'sell_price': newProduct.sellPrice,
          //           'cost_price': newProduct.costPrice,
          //           'sold': newProduct.sold,
          //           'owner_id': newProduct.uuid
          //         })
          //     .toList();

          await productService.addProducts(productsMap);
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
  // Future updateProduct(Product newProduct, Product currentProduct) async {
  // var existingProduct = checkexistingProduct(newProduct.productId!);
  // if (existingProduct.isNotEmpty &&
  //     newProduct.productId != currentProduct.productId) {
  //   await Get.defaultDialog(
  //     title: 'Gagal',
  //     middleText: 'Kode yang dimasukkan sudah ada',
  //     confirm: TextButton(
  //       onPressed: () => Get.back(),
  //       child: const Text('OK'),
  //     ),
  //   );
  //   return;
  // } else {
  //   try {
  //     await productService.updateProduct(newProduct, currentProduct);
  //     Get.defaultDialog(
  //       title: 'Berhasil',
  //       middleText: 'Product berhasil diubah',
  //       confirm: TextButton(
  //         onPressed: () {
  //           Get.back();
  //           Get.back();
  //         },
  //         child: const Text('OK'),
  //       ),
  //     );
  // List<Product> newData =
  //     await ProductProvider.update(data, curentid, uuid);
  // refreshFetch(newData);
  //     } on PostgrestException catch (e) {
  //       Get.defaultDialog(
  //         title: 'Error',
  //         middleText: e.message,
  //         confirm: TextButton(
  //           onPressed: () => Get.back(),
  //           child: const Text('OK'),
  //         ),
  //       );
  //     }
  //   }
  // }

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
    existingProduct =
        products.where((product) => product.productId == newProductId).toList();
    return existingProduct;
  }

  String getNumberAfterChar() {
    RegExp regExp = RegExp(r'([A-Z])(\d+)');
    Match? match = regExp.firstMatch(lastCode.value.toUpperCase());

    if (match != null) {
      String charPart = match.group(1)!;
      String numberPart = match.group(2)!;
      int number = int.parse(numberPart);

      // Increment the number part
      number++;

      // Combine the character part and the incremented number part
      return '$charPart$number';
    } else {
      return ''; // Return input unchanged if no match found
    }
  }

  //! create
  Future addProduct(List<Map<String, Object?>> newProductList) async {
    try {
      // List<Product> newData =
      //     await ProductProvider.create(newProductList, uuid);
      // refreshFetch(newData);
      Get.back();
    } on PostgrestException catch (e) {
      // isSafe.value = false;
      String errorMessage = e.message;
      if (errorMessage.toLowerCase().contains('duplicate')) {
        errorMessage = 'Kode produk sudah ada sebelumnya.';
      }
      Get.defaultDialog(
        title: 'Error',
        middleText: errorMessage,
        confirm: TextButton(
          onPressed: () {
            // isSafe.value = false;
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
        onPressed: () {
          Get.back();
          Get.back();
        },
        child: const Text('OK'),
      ),
    );
  }

  //! delete
  destroyHandle(Product product) async {
    try {
      Get.defaultDialog(
        title: 'Hapus?',
        middleText: 'Hapus barang ini?',
        confirm: TextButton(
          onPressed: () async {
            productService.deleteProduct(product.id!);
            // List<Product> newData = await ProductProvider.destroy(product);
            // refreshFetch(newData);
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
        title: 'Hapus?',
        middleText: 'Hapus semua barang?',
        confirm: TextButton(
          onPressed: () async {
            await productService.deleteAllProduct();
            // List<Product> newData = await ProductProvider.destroyAll(uuid);
            // refreshFetch(newData);
            Get.back();
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
  final codeTextC = TextEditingController();
  final productNameTextC = TextEditingController();
  final unitTextC = TextEditingController();
  final sellPriceTextC = TextEditingController();
  final costPriceTextC = TextEditingController();
  final soldTextC = TextEditingController();
  final numberFormat = NumberFormat("#,##0", "id_ID");
  // final stockController = TextEditingController();
  void bindingEditData(Product foundProduct) {
    codeTextC.text = foundProduct.productId!;
    productNameTextC.text = foundProduct.productName!;
    unitTextC.text = foundProduct.unit!;
    sellPriceTextC.text =
        numberFormat.format(foundProduct.sellPrice!).toString();
    costPriceTextC.text =
        numberFormat.format(foundProduct.costPrice!).toString();
    soldTextC.text =
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

  String? productUnitValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['unit'] == true) {
      return 'Satuan barang tidak boleh kosong';
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
          (field == 'sell' ? sellPriceTextC.text : costPriceTextC.text)) {
        final textController =
            field == 'sell' ? sellPriceTextC : costPriceTextC;
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

  Future handleSave(Product? currentProduct) async {
    // isSafe.value = true;
    clickedField['code'] = true;
    clickedField['productName'] = true;
    clickedField['unit'] = true;
    clickedField['sell'] = true;
    clickedField['cost'] = true;
    // List<Product> productList = [];

    if (formkey.currentState!.validate()) {
      Map<String, Map<String, dynamic>> productsMap = {};
      final newProduct = Product(
        id: await productService.getId(),
        productId: codeTextC.text.toUpperCase(),
        featured: false,
        productName: productNameTextC.text,
        unit: unitTextC.text,
        sellPrice: int.parse(sellPriceTextC.text.replaceAll('.', '')),
        costPrice: int.parse(costPriceTextC.text.replaceAll('.', '')),
        sold: soldTextC.text == '' ? 0 : int.parse(soldTextC.text),
        uuid: authService.uid.value,
      );

      List existingProduct = checkexistingProduct(newProduct.productId!);

      if (currentProduct != null) {
        if (existingProduct.isNotEmpty &&
            newProduct.productId != currentProduct.productId) {
          Get.defaultDialog(
            title: 'Gagal',
            middleText: 'Kode yang dimasukkan sudah ada',
            confirm: TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          );
        } else {
          newProduct.id = currentProduct.id!.toUpperCase();
          await productService.updateProduct(newProduct, currentProduct);
          updateSuccessDialog();
        }

        // await updateProduct(newProduct, currentProduct);
      } else {
        if (existingProduct.isNotEmpty) {
          Get.defaultDialog(
            title: 'Gagal menambahkan barang',
            middleText: 'Kode barang sudah ada.',
            confirm: TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          );
        } else {
          productsMap[newProduct.id!] = newProduct.toJson();
          // Get.defaultDialog(
          //   title: 'Menyimpan Invoice...',
          //   content: const CircularProgressIndicator(),
          //   barrierDismissible: false,
          // );
          await productService.addProducts(productsMap);
          addSuccessDialog();
        }
      }
    }
  }

  featuredHandle(bool value, Product product) {
    // int index =
    //     products.indexWhere((selectItem) => selectItem.id == product.id);

    product.featured = value;
    // products.replaceRange(index, index + 1, [product]);
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
