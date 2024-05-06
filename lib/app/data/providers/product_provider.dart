import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../main.dart';
import '../models/product_model.dart';

class ProductProvider extends GetConnect {
  //! Read
  static Future<List<Product>> fetchData(String uuid) async {
    GetStorage cacheUuid = GetStorage(uuid);
    var cacheProduct = await cacheUuid.read('cacheProducts');
    bool isCacheExist = await cacheProduct == null ? false : true;

    if (!isCacheExist) {
      debugPrint('hit supabase');

      List<Map<String, dynamic>> response =
          await supabase.from('products').select().eq('owner_id', uuid);

      await cacheUuid.write('cacheProducts', jsonEncode(response));

      return response.map((product) => Product.fromJson(product)).toList();
    } else {
      debugPrint('hit cache');

      List<Product> response = [];
      dynamic decodedCache = await json.decode(cacheProduct);

      if (decodedCache is List<dynamic>) {
        response = decodedCache.map((product) {
          return Product.fromJson(product);
        }).toList();
      }

      return response;
    }
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
    List<Product> response = await fetchData(product.uuid);
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
    List<Product> response = await fetchData(uuid);
    return response;
  }

  //! delete
  static Future<List<Product>> destroy(Product product) async {
    GetStorage cacheUuid = GetStorage(product.uuid);
    await supabase.from('products').delete().eq('id', product.id!);

    await cacheUuid.remove('cacheProducts');
    List<Product> response = await fetchData(product.uuid);
    return response;
  }
}
