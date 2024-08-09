import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../data/models/product_model.dart';
import '../data/models/sales_model.dart';
import '../data/providers/product_services.dart';
import '../data/providers/sales_customer_services.dart';
import '../data/providers/stores_services.dart';

class AddProductController extends GetxController {
  late StoreServices storeService = Get.find();
  final ProductService productService = Get.find();
  final SalesCustomerServices salesCustomerServices = Get.find();

  late final products = productService.products;
  late final foundProducts = productService.foundProducts;
  late final totalProduct = productService.productsLenght;
  late final lastCode = productService.lastProductCode;

  late final sales = salesCustomerServices.customers;
  late final isAdmin = storeService.isOwner;
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

  final NumberFormat numberFormat = NumberFormat("#,##0", "id_ID");
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

  //! delete
  destroyHandle(Product product) async {
    try {
      Get.defaultDialog(
        title: 'Hapus?',
        middleText: 'Hapus barang ini?',
        confirm: TextButton(
          onPressed: () async {
            await productService.deleteProduct(product.id);
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

  //! addSales
  Future<void> addSalses() async {
    final existingSales = sales.firstWhere(
      (customer) =>
          customer.name?.toLowerCase() ==
          selectedSales.value?.name?.toLowerCase(),
      orElse: () => Sales(name: '', createdAt: Timestamp.now()),
    );

    if ((existingSales.name == '') && (selectedSales.value?.name != '')) {
      Map<String, Map<String, dynamic>> customersMap = {};
      String newCustomerId = await salesCustomerServices.getId();
      selectedSales.value?.id = newCustomerId;
      customersMap[newCustomerId] = selectedSales.toJson();
      await addSales(selectedSales.value!, customersMap);
    }
  }

  Future<void> addSales(Sales salesCustomer,
      Map<String, Map<String, dynamic>> customerData) async {
    bool isCustomerExists = sales.any((item) => item.id == salesCustomer.id);
    debugPrint(salesCustomer.id);
    if (isCustomerExists) {
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
        await salesCustomerServices.addCustomers(customerData);
        // List<Customer> newData = await CustomerProvider.create(customer);
        await Get.defaultDialog(
          title: 'Berhasil',
          middleText: 'Sales berhasil ditambahkan',
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
        // refreshFetch(newData);
        Get.back();
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
  }

  List<Product> checkexistingProduct(String newProductId) {
    var existingProduct = <Product>[];
    existingProduct =
        products.where((product) => product.productId == newProductId).toList();
    return existingProduct;
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

  void bindingEditData(Product? foundProduct) {
    Product product = foundProduct ??
        Product(
          id: '',
          productId: getNumberAfterChar(),
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
    costPriceTextC.text = numberFormat.format(product.costPrice.value);
    sellPriceTextC1.text = numberFormat.format(product.sellPrice1);
    sellPriceTextC2.text = numberFormat.format(product.sellPrice2 ?? 0.0);
    sellPriceTextC3.text = numberFormat.format(product.sellPrice3 ?? 0.0);
    stockTextC.text = decimal.format(product.stock.value);
    minStockTextC.text = decimal.format(product.stockMin.value);
    soldTextC.text = product.sold == 0 ? '' : product.sold?.toString() ?? '';
  }

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
      Map<String, Map<String, dynamic>> productsMap = {};

      final newProduct = Product(
        id: await productService.getId(),
        productId: codeTextC.text.toUpperCase(),
        createdAt: Timestamp.now(),
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
          newProduct.id = currentProduct.id;
          Get.defaultDialog(
            title: 'Menyimpan Perubahan Barang...',
            content: const CircularProgressIndicator(),
            barrierDismissible: false,
          );

          await productService.updateProduct(newProduct, currentProduct);
          if (newProduct.sales != null) {
            await addSalses();
          }
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
          if (newProduct.sales != null) {
            await addSalses();
          }
          addSuccessDialog();
        }
      }
    }
  }
}
