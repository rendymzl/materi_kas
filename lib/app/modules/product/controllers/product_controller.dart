import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:async' show Future, Timer;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // final provider = ProductProvider();
  final csvList = <Product>[].obs;
  // late final String uuid;
  // late final List<Product> productList = <Product>[].obs;
  final totalProduct = 0.obs;

  // final foundProducts = <Product>[].obs;

  @override
  void onInit() async {
    super.onInit();
    filterProducts('');
    totalProduct.value = products.length;
    // uuid = supabase.auth.currentUser!.id;
    // totalProduct.value =
    //     await ProductProvider.getTotalRowCount(totalProduct.value);
    // List<Product> newData = await ProductProvider.fetchData(uuid, '');
    // refreshFetch(newData);
  }

  //! Fetch
  // void refreshFetch(List<Product> newData) async {
  //   productList.clear();
  //   productList.assignAll(newData);
  //   foundProducts.value = productList;
  // }

  Timer? debounce;
  void filterProducts(String productName) {
    if (products.isNotEmpty) {
      productService.searchProducts(productName);
    }
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

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  //! pickCSV
  Future<void> pickCSV(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          List<List<dynamic>> csvData = await readCSV(filePath);
          // List<Product> productsList = [];
          Map<String, Map<String, dynamic>> productsMap = {};
          for (var i = 1; i < csvData.length; i++) {
            var data = csvData[i];

            // Lewati baris yang mengandung "-" di salah satu sel
            if (data.any((element) => element.toString().contains('-'))) {
              continue;
            }

            var existingProduct = products
                .where((product) => product.productId == data[0])
                .toList();

            if (existingProduct.isEmpty) {
              String newProductId = await productService.getId();

              int sellPrice = 0;
              int costPrice = 0;

              if (data.length > 2 && data[2].toString().contains("Rp")) {
                sellPrice = int.parse(data[2].replaceAll(RegExp(r'[Rp,]'), ''));
              }

              if (data.length > 3 && data[3].toString().contains("Rp")) {
                costPrice = int.parse(data[3].replaceAll(RegExp(r'[Rp,]'), ''));
              }

              final product = Product(
                id: newProductId,
                productId: data[0],
                createdAt: Timestamp.now(),
                featured: false,
                productName: data[1],
                sellPrice: sellPrice,
                costPrice: costPrice,
                sold: 0,
                uuid: authService.uid.value,
              );
              // productsList.add(product);
              productsMap[newProductId] = product.toJson();
            }
          }

          try {
            await productService.addProducts(productsMap);
            await Get.defaultDialog(
              title: 'Berhasil',
              middleText: 'Product berhasil ditambahkan',
              confirm: TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            );
          } catch (e) {
            debugPrint('Error while adding product: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error while picking CSV file: $e');
    }
  }

  //! update
  // int updateStatus = 1;
  Future updateProduct(Product newProduct, Product currentProduct) async {
    bool isProductIdExists =
        products.any((item) => item.productId == newProduct.productId);
    if (isProductIdExists &&
        (newProduct.productId != currentProduct.productId)) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'Kode yang dimasukkan sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
      return;
    } else {
      try {
        // Map<String, Object?> data = {
        //   'product_id': newProduct.productId,
        //   'featured': newProduct.featured,
        //   'product_name': newProduct.productName,
        //   'sell_price': newProduct.sellPrice,
        //   'cost_price': newProduct.costPrice,
        //   'sold': newProduct.sold,
        //   'owner_id': newProduct.uuid
        // };

        await productService.updateProduct(newProduct, currentProduct);
        Get.defaultDialog(
          title: 'Berhasil',
          middleText: 'Product berhasil diubah',
          confirm: TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('OK'),
          ),
        );
        // List<Product> newData =
        //     await ProductProvider.update(data, curentid, uuid);
        // refreshFetch(newData);
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

  //! create
  Future addSingleProduct(Product product) async {
    bool isProductIdExists =
        products.any((item) => item.productId == product.productId);
    if (isProductIdExists) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'Kode yang dimasukkan sudah ada',
        confirm: TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    } else {
      // final productList = <Product>[];
      // productList.add(product);
      Map<String, Map<String, dynamic>> productsMap = {};
      String newProductId = await productService.getId();
      product.id = newProductId;
      productsMap[newProductId] = product.toJson();
      try {
        // List<Product> newData = await ProductProvider.create(product);
        // refreshFetch(newData);
        productService.addProducts(productsMap);
        Get.back();
      } on PostgrestException catch (e) {
        String errorMessage = e.message;
        if (errorMessage.toLowerCase().contains('duplicate')) {
          errorMessage = 'Kode produk sudah ada sebelumnya.';
        }
        Get.defaultDialog(
          title: 'Error',
          middleText: errorMessage,
          confirm: TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('OK'),
          ),
        );
      }
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Product berhasil ditambahkan',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }

  //! delete
  destroyHandle(Product product) async {
    try {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Hapus barang ini?',
        confirm: TextButton(
          onPressed: () async {
            await productService.deleteProduct(product.id!);
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
    // addStatus = 1;
    clickedField['code'] = true;
    clickedField['productName'] = true;
    clickedField['sell'] = true;
    clickedField['cost'] = true;
    if (formkey.currentState!.validate()) {
      final product = Product();
      product.productId = codeController.text;

      if (curentProduct == null) {
        product.createdAt = Timestamp.now();
      }
      if (curentProduct == null) {
        product.featured = false;
      }
      product.productName = productNameController.text;
      product.sellPrice =
          int.parse(sellPriceController.text.replaceAll('.', ''));
      product.costPrice =
          int.parse(costPriceController.text.replaceAll('.', ''));
      product.sold =
          soldController.text == '' ? 0 : int.parse(soldController.text);
      product.uuid = authService.uid.value;
      if (curentProduct != null) {
        await updateProduct(product, curentProduct);
        // await updateProduct(
        //     product, curentProduct.id!, curentProduct.productId!);
        // if (updateStatus == 1) {
        //   await Get.defaultDialog(
        //     title: 'Berhasil',
        //     middleText: 'Product berhasil diupdate',
        //     confirm: TextButton(
        //       onPressed: () {
        //         Get.back();
        //         Get.back();
        //       },
        //       child: const Text('OK'),
        //     ),
        //   );
        // }
      } else {
        await addSingleProduct(product);
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
}
