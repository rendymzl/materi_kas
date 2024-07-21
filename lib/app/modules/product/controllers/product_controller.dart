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
  final NumberFormat numberFormat = NumberFormat("#,##0", "id_ID");
  final TextEditingController codeTextC = TextEditingController();
  final TextEditingController productNameTextC = TextEditingController();
  final TextEditingController unitTextC = TextEditingController();
  final TextEditingController costPriceTextC = TextEditingController();
  final TextEditingController sellPriceTextC1 = TextEditingController();
  final TextEditingController sellPriceTextC2 = TextEditingController();
  final TextEditingController sellPriceTextC3 = TextEditingController();
  final TextEditingController stockTextC = TextEditingController();
  final TextEditingController soldTextC = TextEditingController();

  late final Map<String, TextEditingController> textControllers;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxMap<String, bool> clickedField = {
    'code': false,
    'productName': false,
    'cost': false,
    'sell1': false,
    'sell2': false,
    'sell3': false,
    'stock': false,
    'sold': false,
  }.obs;

  final formkey = GlobalKey<FormState>();

  @override
  void onInit() async {
    super.onInit();
    filterProducts('');
    textControllers = {
      'code': codeTextC,
      'productName': productNameTextC,
      'unit': unitTextC,
      'cost': costPriceTextC,
      'sell1': sellPriceTextC1,
      'sell2': sellPriceTextC2,
      'sell3': sellPriceTextC3,
      'stock': stockTextC,
      'sold': soldTextC,
    };
  }

  void filterProducts(String productName) {
    productService.searchProducts(productName);
  }

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
            String code = data[0] as String;
            String productName = data[1] as String;
            String unit = data[2] as String;
            String costPriceString = data[3] as String;
            String sellPrice1String = data[4] as String;
            String sellPrice2String = data[5] as String;
            String sellPrice3String = data[6] as String;
            int stock = data[7] as int;

            if (productName != '') {
              var existingProduct = checkexistingProduct(code);

              if (existingProduct.isEmpty) {
                int costPrice = 0;
                int sellPrice1 = 0;
                int sellPrice2 = 0;
                int sellPrice3 = 0;

                if (data.length > 3 &&
                    costPriceString.contains("Rp") &&
                    !costPriceString.contains("-")) {
                  costPrice = int.parse(
                      costPriceString.replaceAll(RegExp(r'[Rp,]'), ''));
                }

                if (data.length > 4 &&
                    sellPrice1String.contains("Rp") &&
                    !sellPrice1String.contains("-")) {
                  sellPrice1 = int.parse(
                      sellPrice1String.replaceAll(RegExp(r'[Rp,]'), ''));
                }

                if (data.length > 5 &&
                    sellPrice2String.contains("Rp") &&
                    !sellPrice2String.contains("-")) {
                  sellPrice2 = int.parse(
                      sellPrice2String.replaceAll(RegExp(r'[Rp,]'), ''));
                }

                if (data.length > 6 &&
                    sellPrice3String.contains("Rp") &&
                    !sellPrice3String.contains("-")) {
                  sellPrice3 = int.parse(
                      sellPrice3String.replaceAll(RegExp(r'[Rp,]'), ''));
                }

                String newProductId = await productService.getId();

                final product = Product(
                  id: newProductId,
                  productId: data[0],
                  createdAt: Timestamp.now(),
                  featured: false,
                  productName: productName,
                  unit: unit,
                  costPrice: costPrice,
                  sellPrice1: sellPrice1,
                  sellPrice2: sellPrice2,
                  sellPrice3: sellPrice3,
                  stock: stock,
                  sold: 0,
                );
                productsMap[newProductId] = product.toJson();
              }
            } else {
              emptyCsv.value = i + 1;
            }
            dialog.update(value: i + 1);
          }

          await productService.addProducts(productsMap);
        }
      }
    } catch (e) {
      debugPrint('Error while picking CSV file: $e');
    }
  }

  //! update
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
    RegExp regExp = RegExp(r'(\D+)(\d+)');
    Match? match = regExp.firstMatch(lastCode.value.toUpperCase());

    if (match != null) {
      String charPart = match.group(1)!;
      String numberPart = match.group(2)!;
      int number = int.parse(numberPart);

      number++;

      return '$charPart$number';
    } else {
      return '';
    }
  }

  //! create
  Future addProduct(List<Map<String, Object?>> newProductList) async {
    try {
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
            productService.deleteProduct(product.id);
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
  void bindingEditData(Product foundProduct) {
    codeTextC.text = foundProduct.productId;
    productNameTextC.text = foundProduct.productName;
    unitTextC.text = foundProduct.unit;
    costPriceTextC.text = numberFormat.format(foundProduct.costPrice);
    sellPriceTextC1.text = numberFormat.format(foundProduct.sellPrice1);
    sellPriceTextC2.text = numberFormat.format(foundProduct.sellPrice2 ?? 0.0);
    sellPriceTextC3.text = numberFormat.format(foundProduct.sellPrice3 ?? 0.0);
    stockTextC.text =
        foundProduct.stock == 0 ? '' : foundProduct.stock?.toString() ?? '';
    soldTextC.text =
        foundProduct.sold == 0 ? '' : foundProduct.sold?.toString() ?? '';
  }

  String? fieldValidator(String value, String fieldKey, String errorMessage) {
    value = value.trim();
    if ((value.isEmpty || value == '0') && clickedField[fieldKey] == true) {
      return errorMessage;
    }
    return null;
  }

  void onCurrencyChanged(String value, String field) {
    clickedField[field] = true;

    if (value.isNotEmpty) {
      String newValue =
          numberFormat.format(int.parse(value.replaceAll('.', '')));

      final textController = textControllers[field];

      if (textController != null && newValue != textController.text) {
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
    clickedField.assignAll({
      'code': true,
      'productName': true,
      'unit': true,
      'cost': true,
      'sell1': true,
      'sell2': true,
      'sell3': true,
      'stock': true,
      'sold': true,
    });

    if (formkey.currentState!.validate()) {
      Map<String, Map<String, dynamic>> productsMap = {};
      final newProduct = Product(
        id: await productService.getId(),
        productId: codeTextC.text.toUpperCase(),
        createdAt: Timestamp.now(),
        featured: false,
        productName: productNameTextC.text,
        unit: unitTextC.text,
        costPrice: costPriceTextC.text == ''
            ? 0
            : int.parse(costPriceTextC.text.replaceAll('.', '')),
        sellPrice1: sellPriceTextC1.text == ''
            ? 0
            : int.parse(sellPriceTextC1.text.replaceAll('.', '')),
        sellPrice2: sellPriceTextC2.text == ''
            ? 0
            : int.parse(sellPriceTextC2.text.replaceAll('.', '')),
        sellPrice3: sellPriceTextC3.text == ''
            ? 0
            : int.parse(sellPriceTextC3.text.replaceAll('.', '')),
        stock: stockTextC.text == '' ? 0 : int.parse(stockTextC.text),
        sold: soldTextC.text == '' ? 0 : int.parse(soldTextC.text),
      );

      List existingProduct = checkexistingProduct(newProduct.productId);

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
          newProduct.id = currentProduct.id.toUpperCase();
          Get.defaultDialog(
            title: 'Menyimpan Perubahan Barang...',
            content: const CircularProgressIndicator(),
            barrierDismissible: false,
          );
          await productService.updateProduct(newProduct, currentProduct);
          Get.back();
          updateSuccessDialog();
        }
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
          productsMap[newProduct.id] = newProduct.toJson();
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
