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

  static Future<int> getTotalRowCount(int totalRowCount) async {
    // int totalCount = 0;
    // int currentPage = 1;

    try {
      // while (true) {
      final response =
          await supabase.from('products').select().count(CountOption.exact);
      // .range(currentPage, pageSize);

      // if (response.isEmpty) {
      //   break;
      // }

      // final int count = response.first['count'] as int;
      // totalCount += count;
      // currentPage++;
      return response.count;
      // }

      // totalRowCount = totalCount;
    } catch (error) {
      debugPrint('Error: $error');
      return 0;
    }
  }

  //! Read
  static Future<List<Product>> fetchData(
      String uuid, String productName) async {
    late List<Map<String, dynamic>> response;

    if (productName == '') {
      response = await supabase.from('products').select().eq('owner_id', uuid);
      // .range(1, 1000);
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
  static Future<List<Product>> create(Product product) async {
    GetStorage cacheUuid = GetStorage(product.uuid);
    await supabase.from('products').insert([
      {
        'product_id': product.productId,
        'featured': product.featured,
        'product_name': product.productName,
        'sell_price': product.sellPrice,
        'cost_price': product.costPrice,
        'sold': product.sold,
        'owner_id': product.uuid
      }
    ]);

    await cacheUuid.remove('cacheProducts');
    List<Product> response = await fetchData(product.uuid, '');
    return response;
  }

  //! update
  static Future<List<Product>> update(
      Map<String, Object?> newData, String id, String uuid) async {
    GetStorage cacheUuid = GetStorage(uuid);
    await supabase
        .from('products')
        .update(newData)
        .eq('owner_id', uuid)
        .eq('id', id)
        .select();

    await cacheUuid.remove('cacheProducts');
    List<Product> response = await fetchData(uuid, '');
    return response;
  }

  //! delete
  static Future<List<Product>> destroy(Product product) async {
    GetStorage cacheUuid = GetStorage(product.uuid);
    await supabase.from('products').delete().eq('id', product.id!);

    await cacheUuid.remove('cacheProducts');
    List<Product> response = await fetchData(product.uuid, '');
    return response;
  }
}
