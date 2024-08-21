import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../../modules/init/controllers/init_controller.dart';
import '../../widget/side_menu_controller.dart';
import '../models/product_model.dart';

class ProductService extends GetxController {
  late SideMenuController sideMenuC = Get.find();

  var products = <Product>[].obs;
  var productsLenght = 0.obs;
  var lastProductCode = ''.obs;
  var foundProducts = <Product>[].obs;
  var lowStockProducts = <Product>[].obs;

  @override
  void onInit() async {
    await subscribe();
    super.onInit();
  }

  Future<void> subscribe() async {
    final productStream = await Product.subscribe(sideMenuC.store.value!.id!);
    productStream.listen((updatedProducts) {
      products.assignAll(updatedProducts);

      search('');
    });
  }

  void search(String searchValue) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(searchValue);
      if (searchValue.isEmpty) {
        List<Product> productsList = [];
        foundProducts.clear();
        foundProducts.addAll(products);
        lowStockProducts.clear();
        lowStockProducts.addAll(products);
        lowStockProducts.sort((a, b) => (a.stock.value - a.stockMin.value)
            .compareTo(b.stock.value - b.stockMin.value));

        productsLenght.value = products.length;

        productsList.addAll(products);
        productsList.sort((a, b) => a.productId.compareTo(b.productId));
        if (products.isNotEmpty) {
          lastProductCode.value = productsList[products.length - 1].productId;
        }
      } else {
        foundProducts.value = products.where((product) {
          return product.productName
              .toLowerCase()
              .contains(searchValue.toLowerCase());
        }).toList();

        lowStockProducts.value = products.where((product) {
          return product.productName
              .toLowerCase()
              .contains(searchValue.toLowerCase());
        }).toList();
      }
    });
  }
}
