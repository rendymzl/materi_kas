import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/product_model.dart';
import 'auth_services.dart';

class ProductService extends GetxController {
  final AuthService authService = Get.find();
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  var products = <Product>[].obs;
  var productsLenght = 0.obs;
  var lastProductCode = ''.obs;
  var foundProducts = <Product>[].obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchProducts();
  // }

  Future<void> fetchProducts() async {
    try {
      DocumentSnapshot docSnapshot =
          await _productsCollection.doc(authService.uid.value).get();
      if (docSnapshot.exists) {
        var productData = docSnapshot.data() as Map<String, dynamic>;
        products.value = productData.values
            .map((productJson) => Product.fromJson(productJson))
            .toList();
        products.sort((a, b) => a.productName.compareTo(b.productName));
        searchProducts('');
      } else {
        // Handle case where the document does not exist
        products.value = [];
        foundProducts.value = [];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String> getId() async {
    return _productsCollection.doc().id;
  }

  Future<void> addProducts(
      Map<String, Map<String, dynamic>> productsMap) async {
    // List<List<Product>> productChunks = _chunkProducts(productsList, 500);
    try {
      DocumentReference docRef = _productsCollection.doc(authService.uid.value);
      await docRef.set(productsMap, SetOptions(merge: true));
      // products.addAll(productsList);
      // foundProducts.addAll(productsList);
      await fetchProducts();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // List<List<Product>> _chunkProducts(List<Product> products, int chunkSize) {
  //   List<List<Product>> chunks = [];
  //   for (var i = 0; i < products.length; i += chunkSize) {
  //     chunks.add(products.sublist(i,
  //         i + chunkSize > products.length ? products.length : i + chunkSize));
  //   }
  //   return chunks;
  // }

  Future<void> updateProduct(Product newProduct, Product currentProduct) async {
    try {
      await _productsCollection
          .doc(authService.uid.value)
          .update({currentProduct.id: newProduct.toJson()});
      await fetchProducts();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection
          .doc(authService.uid.value)
          .update({productId: FieldValue.delete()});
      fetchProducts();
      // searchProducts('');
      // products.removeWhere((product) => product.id == productId);
      // foundProducts.removeWhere((product) => product.id == productId);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteAllProduct() async {
    try {
      await _productsCollection.doc(authService.uid.value).delete();
      await fetchProducts();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void searchProducts(String productName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (productName.isEmpty) {
        List<Product> productsList = [];
        foundProducts.clear();
        foundProducts.addAll(products);

        productsLenght.value = products.length;

        productsList.addAll(products);
        productsList.sort((a, b) => a.productId.compareTo(b.productId));
        // List<Product> subList = productsList.take(50).toList();

        lastProductCode.value = products.isEmpty
            ? 'Tidak ada barang'
            : productsList[products.length - 1].productId;
      } else {
        foundProducts.value = products.where((product) {
          return product.productName
              .toLowerCase()
              .contains(productName.toLowerCase());
        }).toList();
      }
    });
  }
}
