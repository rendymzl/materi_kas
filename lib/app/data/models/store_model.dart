import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:powersync/sqlite3.dart' as sqlite;

import '../../../powersync.dart';

class Stores {
  String? id;
  DateTime? createdAt;
  Rx<String> name;
  Rx<String> address;
  Rx<String> phone;
  Rx<String> telp;
  Rx<String?> promo;
  String ownerId;

  Stores({
    this.id,
    this.createdAt,
    required String name,
    required String address,
    String phone = '',
    String telp = '',
    String? promo = '',
    required this.ownerId,
  })  : name = Rx<String>(name),
        address = Rx<String>(address),
        phone = Rx<String>(phone),
        telp = Rx<String>(telp),
        promo = Rx<String>(promo ?? '');

  Stores.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at']).toLocal()
            : null,
        name = Rx<String>(json['name']),
        address = Rx<String>(json['address']),
        phone = Rx<String>(json['phone']),
        telp = Rx<String>(json['telp']),
        promo = Rx<String>(json['promo'] ?? ''),
        ownerId = json['owner_id'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name.value;
    data['address'] = address.value;
    data['phone'] = phone.value;
    data['telp'] = telp.value;
    data['promo'] = promo.value;
    data['owner_id'] = ownerId;
    return data;
  }

  Stores.fromRow(sqlite.Row row)
      : id = row['id'],
        createdAt = row['created_at'] != null
            ? DateTime.parse(row['created_at']).toLocal()
            : null,
        name = Rx<String>(row['name']),
        address = Rx<String>(row['address']),
        phone = Rx<String>(row['phone']),
        telp = Rx<String>(row['telp']),
        promo = Rx<String>(row['promo'] ?? ''),
        ownerId = row['owner_id'];

  // CRUD operations

  // Insert (Create)
  static Future<void> insert(Stores store) async {
    try {
      await Supabase.instance.client.from('stores').insert(store.toJson());
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Update
  Future<void> update() async {
    try {
      await Supabase.instance.client
          .from('stores')
          .update(toJson())
          .eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Delete
  Future<void> delete() async {
    try {
      await Supabase.instance.client.from('stores').delete().eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Fetch all stores by ownerId
  static Future<Stores?> get(String id) async {
    try {
      var response =
          await Supabase.instance.client.from('stores').select().eq('id', id);

      if (response.isNotEmpty) {
        Stores stores;
        stores = Stores.fromJson(response.first);
        return stores;
      } else {
        return null;
      }
    } on AuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  static Future<Stores?> getPs(String id) async {
    try {
      var response = await db.get('SELECT * FROM stores WHERE id = ?', [id]);

      if (response.isNotEmpty) {
        Stores stores;
        stores = Stores.fromRow(response);
        return stores;
      } else {
        return null;
      }
    } on AuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  static Future<Stores?> getByOwner(String ownerId) async {
    try {
      var response = await Supabase.instance.client
          .from('stores')
          .select()
          .eq('owner_id', ownerId);

      if (response.isNotEmpty) {
        Stores stores;
        stores = Stores.fromJson(response.first);
        return stores;
      } else {
        return null;
      }
    } on AuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  // Real-time subscription to changes in the stores table
  static Stream<List<Stores>> subscribeToStores(String ownerId) {
    return Supabase.instance.client
        .from('stores')
        .stream(primaryKey: ['id'])
        .eq('owner_id', ownerId)
        .map((data) => data.map((json) => Stores.fromJson(json)).toList());
  }

  // static Stream<List<Stores>> subscribeToStoresPS(String ownerId) {
  //   return db
  //       .watch('SELECT * FROM stores where owner_id = $ownerId ORDER BY id asc')
  //       .map((data) => data.map((json) => Stores.fromJson(json)).toList());
  // }
}
