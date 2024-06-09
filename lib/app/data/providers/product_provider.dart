// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../models/product_model.dart';

class ProductProvider extends GetConnect {
  //! TotalRow
  // int totalRowCount = 0;
  // final int pageSize = 1000;

  static Future<int> getTotalRowCount(String uuid) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('owner_id', uuid)
          .count(CountOption.exact);
      return response.count;
    } catch (error) {
      debugPrint('Error: $error');
      return 0;
    }
  }

  static Future<List<Product>> getAllProduct(int totalRows, String uuid) async {
    int pageSize = 1000;
    int start = 0;
    bool hasMoreData = true;

    List<Map<String, dynamic>> allProduct = [];
    while (hasMoreData) {
      final response = await supabase
          .from('products')
          .select()
          .eq('owner_id', uuid)
          .order('product_id', ascending: false)
          .range(start, start + pageSize - 1);

      allProduct.addAll(response);
      if (response.length < pageSize) {
        hasMoreData = false;
      } else {
        start += pageSize;
      }
    }

    int extractNumber(String item) {
      final regex = RegExp(r'\d+');
      final match = regex.firstMatch(item);
      return int.parse(match!.group(0)!);
    }

    allProduct.sort((a, b) => extractNumber(b['product_id'])
        .compareTo(extractNumber(a['product_id'])));

    return allProduct.map((product) => Product.fromJson(product)).toList();
  }

  //! Read
  static Future<List<Product>> fetchData(
      String uuid, String productName) async {
    late List<Map<String, dynamic>> response;

    if (productName == '') {
      // return getAllProduct(await getTotalRowCount(uuid), uuid);
      response = await supabase
          .from('products')
          .select()
          .eq('owner_id', uuid)
          .limit(200)
          .order('sold', ascending: false);
    } else {
      response = await supabase
          .from('products')
          .select()
          .eq('owner_id', uuid)
          .ilike('product_name', '%$productName%');
    }
    return response.map((product) => Product.fromJson(product)).toList();
  }

  //! create
  static Future<List<Product>> create(
      List<Map<String, Object?>> newProduct, String uuid) async {
    // GetStorage cacheUuid = GetStorage(product.uuid);
    await supabase.from('products').insert(newProduct);

    // await cacheUuid.remove('cacheProducts');
    List<Product> response = await fetchData(uuid, '');
    return response;
  }

  //! update
  static Future<List<Product>> update(
      Map<String, Object?> newData, String id, String uuid) async {
    // GetStorage cacheUuid = GetStorage(uuid);
    await supabase
        .from('products')
        .update(newData)
        .eq('owner_id', uuid)
        .eq('id', id)
        .select();

    // await cacheUuid.remove('cacheProducts');
    List<Product> response = await fetchData(uuid, '');
    return response;
  }

  //! delete
  static Future<List<Product>> destroy(Product product) async {
    await supabase.from('products').delete().eq('id', product.id!);

    List<Product> response = await fetchData(product.uuid, '');
    return response;
  }

  static Future<List<Product>> destroyAll(String uuid) async {
    await supabase.from('products').delete().eq('owner_id', uuid);

    List<Product> response = await fetchData(uuid, '');
    return response;
  }
}
