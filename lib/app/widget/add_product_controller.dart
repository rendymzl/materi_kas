import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';
import '../data/models/product_model.dart';
import '../data/models/sales_model.dart';
import '../data/providers/product_services.dart';
import '../data/providers/sales_customer_services.dart';
import 'side_menu_controller.dart';

class AddProductController extends GetxController {
  late SideMenuController sideMenuC = Get.find();
  late ProductService productService = Get.find();
  late SalesCustomerServices salesCustomerServices = Get.find();

  late final products = productService.products;
  late final foundProducts = productService.foundProducts;
  late final totalProduct = productService.productsLenght;
  late final lastCode = productService.lastProductCode;

  late final sales = salesCustomerServices.customers;
  late final isAdmin = sideMenuC.isAdmin.value;
  Rx<Sales?> selectedSales = Rx<Sales?>(null);

  @override
  void onInit() async {
    super.onInit();
    textControllers = {
      'code': codeTextC,
      'productName': productNameTextC,
      'unit': unitTextC,
      'sales': salesTextC,
      'cost': costPriceTextC,
      'sell1': sellPriceTextC1,
      'sell2': sellPriceTextC2,
      'sell3': sellPriceTextC3,
      'stock': stockTextC,
      'min_stock': stockTextC,
      'sold': soldTextC,
    };
  }

  final RxMap<String, bool> clickedField = {
    'code': false,
    'productName': false,
    'sales': false,
    'cost': false,
    'sell1': false,
    'sell2': false,
    'sell3': false,
    'stock': false,
    'min_stock': false,
    'sold': false,
  }.obs;

  final TextEditingController codeTextC = TextEditingController();
  final TextEditingController productNameTextC = TextEditingController();
  final TextEditingController unitTextC = TextEditingController();
  final TextEditingController salesTextC = TextEditingController();
  final TextEditingController costPriceTextC = TextEditingController();
  final TextEditingController sellPriceTextC1 = TextEditingController();
  final TextEditingController sellPriceTextC2 = TextEditingController();
  final TextEditingController sellPriceTextC3 = TextEditingController();
  final TextEditingController stockTextC = TextEditingController();
  final TextEditingController minStockTextC = TextEditingController();
  final TextEditingController soldTextC = TextEditingController();

  late final Map<String, TextEditingController> textControllers;
  final formkey = GlobalKey<FormState>();

  void onTextChange(String value, String field) {
    clickedField[field] = true;
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
      String newValue = currency.format(int.parse(value.replaceAll('.', '')));

      final textController = textControllers[field];

      if (textController != null && newValue != textController.text) {
        textController.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }
  }

  //! binding data
  void bindingEditData(Product? foundProduct) {
    int numberId =
        (lastCode.value != '') ? int.parse(lastCode.value.substring(2)) : 0;
    // numberId = generateNumberId(numberId);
    Product product = foundProduct ??
        Product(
          id: '',
          productId: 'BR${generateNumberId(numberId + 1)}',
          storeId: sideMenuC.store.value!.id!,
          productName: '',
          unit: '',
          costPrice: 0,
          sellPrice1: 0,
          sellPrice2: 0,
          sellPrice3: 0,
          stock: 0,
          sold: 0,
        );

    selectedSales.value = product.sales;
    codeTextC.text = product.productId;
    productNameTextC.text = product.productName;
    unitTextC.text = product.unit;
    salesTextC.text = product.sales?.name ?? '';
    costPriceTextC.text = product.costPrice.value == 0
        ? ''
        : currency.format(product.costPrice.value);
    sellPriceTextC1.text =
        product.sellPrice1 == 0 ? '' : currency.format(product.sellPrice1);
    sellPriceTextC2.text = product.sellPrice2 == 0
        ? ''
        : currency.format(product.sellPrice2 ?? 0.0);
    sellPriceTextC3.text = product.sellPrice2 == 0
        ? ''
        : currency.format(product.sellPrice3 ?? 0.0);
    stockTextC.text =
        product.stock.value == 0 ? '' : decimal.format(product.stock.value);
    minStockTextC.text = product.stockMin.value == 0
        ? ''
        : decimal.format(product.stockMin.value);
    soldTextC.text = product.sold == 0 ? '' : product.sold?.toString() ?? '';
  }

  String generateNumberId(int number) {
    return number.toString().padLeft(4, '0');
  }

  // String getNumberAfterChar() {
  //   RegExp regExp = RegExp(r'(\D+)(\d+)');
  //   Match? match = regExp.firstMatch(lastCode.value.toUpperCase());

  //   if (match != null) {
  //     String charPart = match.group(1)!;
  //     String numberPart = match.group(2)!;
  //     int number = int.parse(numberPart);

  //     number++;

  //     return '$charPart$number';
  //   } else {
  //     return '';
  //   }
  // }

  //! create
  Future addProduct(Product product) async {
    bool isProductExist =
        products.any((item) => item.productId == product.productId);
    if (isProductExist) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'ID barang sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } else {
      await Product.insert(product);
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Barang berhasil ditambahkan',
        confirm: TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
      Get.back();
    }
  }

  //! update
  Future updateProduct(
    Product newProduct,
    Product currentProduct,
  ) async {
    newProduct.id = currentProduct.id;
    await newProduct.update();
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Product berhasil diupdate',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
    Get.back();
  }

  //! delete
  destroyHandle(Product product) async {
    try {
      Get.defaultDialog(
        title: 'Hapus?',
        middleText: 'Hapus barang ini?',
        confirm: TextButton(
          onPressed: () async {
            product.delete();
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
    } catch (e) {
      Get.defaultDialog(
        title: 'Error',
        middleText: e.toString(),
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }

  //! handle save
  Future handleSave(Product? currentProduct) async {
    clickedField.assignAll({
      'code': true,
      'productName': true,
      'unit': true,
      'sales': true,
      'cost': true,
      'sell1': true,
      'sell2': true,
      'sell3': true,
      'stock': true,
      'min_stock': true,
      'sold': true,
    });

    if (formkey.currentState!.validate()) {
      final newProduct = Product(
        productId: codeTextC.text.toUpperCase(),
        createdAt: DateTime.now(),
        storeId: sideMenuC.store.value!.id!,
        featured: false,
        productName: productNameTextC.text,
        unit: unitTextC.text,
        sales: selectedSales.value,
        costPrice: costPriceTextC.text == ''
            ? 0
            : double.parse(costPriceTextC.text.replaceAll('.', '')),
        sellPrice1: sellPriceTextC1.text == ''
            ? 0
            : double.parse(sellPriceTextC1.text.replaceAll('.', '')),
        sellPrice2: sellPriceTextC2.text == ''
            ? 0
            : double.parse(sellPriceTextC2.text.replaceAll('.', '')),
        sellPrice3: sellPriceTextC3.text == ''
            ? 0
            : double.parse(sellPriceTextC3.text.replaceAll('.', '')),
        stock: stockTextC.text == ''
            ? 0
            : double.parse(stockTextC.text.replaceAll('.', '')),
        stockMin: minStockTextC.text == ''
            ? 0
            : double.parse(minStockTextC.text.replaceAll('.', '')),
        sold: soldTextC.text == '' ? 0 : int.parse(soldTextC.text),
      );

      currentProduct == null
          ? addProduct(newProduct)
          : updateProduct(newProduct, currentProduct);
    }
  }
}
