import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../main.dart';
import '../models/customer_model.dart';

class CustomerProvider extends GetConnect {
  //! Read
  static Future<List<Customer>> fetchData(String uuid) async {
    GetStorage cacheUuid = GetStorage(uuid);
    var cacheCustomers = await cacheUuid.read('cacheCustomers');
    bool isCacheExist = await cacheCustomers == null ? false : true;

    if (!isCacheExist) {
      debugPrint('hit cust supabase');

      List<Map<String, dynamic>> response =
          await supabase.from('customers').select().eq('owner_id', uuid);

      await cacheUuid.write('cacheCustomers', jsonEncode(response));

      return response.map((customer) => Customer.fromJson(customer)).toList();
    } else {
      debugPrint('hit cache');

      List<Customer> response = [];
      dynamic decodedCache = await json.decode(cacheCustomers);

      if (decodedCache is List<dynamic>) {
        response = decodedCache.map((customer) {
          return Customer.fromJson(customer);
        }).toList();
      }

      return response;
    }
  }

  //! create
  static Future<List<Customer>> create(Customer customer) async {
    GetStorage cacheUuid = GetStorage(customer.uuid);
    await supabase.from('customers').insert([
      {
        'customer_id': customer.customerId,
        'name': customer.name,
        'phone': customer.phone,
        'address': customer.address,
        'owner_id': customer.uuid,
      }
    ]);

    await cacheUuid.remove('cacheCustomers');
    List<Customer> response = await fetchData(customer.uuid);
    return response;
  }

  //! update
  static Future<List<Customer>> update(
      Map<String, Object?> newData, String id, String uuid) async {
    GetStorage cacheUuid = GetStorage(uuid);
    await supabase
        .from('customers')
        .update(newData)
        .eq('owner_id', uuid)
        .eq('id', id)
        .select();

    await cacheUuid.remove('cacheCustomers');
    List<Customer> response = await fetchData(uuid);
    return response;
  }

  //! delete
  static Future<List<Customer>> destroy(Customer customer) async {
    GetStorage cacheUuid = GetStorage(customer.uuid);
    await supabase.from('customers').delete().eq('id', customer.id!);

    await cacheUuid.remove('cacheCustomers');
    List<Customer> response = await fetchData(customer.uuid);
    return response;
  }
}
