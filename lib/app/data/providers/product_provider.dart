// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../models/product_model.dart';

class ProductProvider extends GetConnect {
  //! TotalRow
  // int totalRowCount = 0;
  // final int pageSize = 1000;

  static Future<int> getTotalRowCount() async {
    try {
      final response =
          await supabase.from('products').select().count(CountOption.exact);
      return response.count;
    } catch (error) {
      debugPrint('Error: $error');
      return 0;
    }
  }

  static Future<String> getLastIdProduct() async {
    try {
      final response = await supabase
          .from('products')
          .select('product_id')
          .order('product_id', ascending: false)
          .range(0, 1);
      return response[0]['product_id'];
    } catch (error) {
      debugPrint('Error: $error');
      return '';
    }
  }

  //! Read
  static Future<List<Product>> fetchData(
      String uuid, String productName) async {
    late List<Map<String, dynamic>> response;

    if (productName == '') {
      response = await supabase.from('products').select().eq('owner_id', uuid);
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
