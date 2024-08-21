// import 'package:powersync/sqlite3_common.dart' as sqlite;

// import '../../../powersync.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Customer {
  String? id;
  String? customerId;
  DateTime? createdAt;
  String? name;
  String? phone;
  String? address;
  String? storeId;

  Customer({
    this.id,
    this.customerId,
    this.createdAt,
    this.name,
    this.phone,
    this.address,
    this.storeId,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at']).toLocal()
        : null;
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
    storeId = json['store_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['customer_id'] = customerId;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name;
    data['phone'] = phone;
    data['address'] = address;
    data['store_id'] = storeId;
    return data;
  }

  // CRUD operations

  // Insert (Create)
  static Future<void> insert(Customer customer) async {
    await Supabase.instance.client.from('customers').insert(customer.toJson());
    // if (response.error != null) {
    //   throw Exception('Failed to insert customer: ${response.error!.message}');
    // }
    // customer.id = response.data[0]['id'];
  }

  // Update
  Future<void> update() async {
    try {
      await Supabase.instance.client
          .from('customers')
          .update(toJson())
          .eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Delete
  Future<void> delete() async {
    try {
      await Supabase.instance.client.from('customers').delete().eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Fetch all customers by storeId
  static Future<List<Customer>> getAll(String storeId) async {
    try {
      final response = await Supabase.instance.client
          .from('customers')
          .select()
          .eq('store_id', storeId);
      return (response as List).map((json) => Customer.fromJson(json)).toList();
    } on AuthException catch (e) {
      debugPrint(e.message);
      return [];
    }
  }

  // Real-time subscription to changes in the customers table
  static Future<Stream<List<Customer>>> subscribe(String storeId) async {
    return Supabase.instance.client
        .from('customers')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .map((data) => data.map((json) => Customer.fromJson(json)).toList());
  }
}


  // Customer.fromRow(sqlite.Row row) {
  //   id = row['id'] as String?;
  //   customerId = row['customer_id'] as String?;
  //   createdAt = DateTime.parse(row['created_at'] as String).toLocal();
  //   name = row['name'] as String?;
  //   phone = row['phone'] as String?;
  //   address = row['address'] as String?;
  //   ownerId = row['owner_id'] as String?;
  // }

  // static Future<void> createTable() async {
  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS customers (
  //       id TEXT PRIMARY KEY,
  //       customer_id TEXT,
  //       created_at TEXT,
  //       name TEXT,
  //       phone TEXT,
  //       address TEXT,
  //       owner_id TEXT
  //     )
  //   ''');
  // }

  // Future<void> insert() async {
  //   await db.execute('''
  //     INSERT INTO customers (id, customer_id, created_at, name, phone, address, owner_id)
  //     VALUES (?, ?, ?, ?, ?, ?, ?)
  //   ''', [
  //     id,
  //     customerId,
  //     createdAt?.toIso8601String(),
  //     name,
  //     phone,
  //     address,
  //     ownerId
  //   ]);
  // }

  // Future<void> update() async {
  //   await db.execute('''
  //     UPDATE customers
  //     SET customer_id = ?, created_at = ?, name = ?, phone = ?, address = ?, owner_id = ?
  //     WHERE id = ?
  //   ''', [
  //     customerId,
  //     createdAt?.toIso8601String(),
  //     name,
  //     phone,
  //     address,
  //     ownerId,
  //     id
  //   ]);
  // }

  // Future<void> delete() async {
  //   await db.execute('DELETE FROM customers WHERE id = ?', [id]);
  // }

  // /// Watch all lists.
  // static Stream<List<Customer>> watchLists() {
  //   // This query is automatically re-run when data in "lists" or "todos" is modified.
  //   return db
  //       .watch('SELECT * FROM lists ORDER BY created_at, id')
  //       .map((results) {
  //     return results.map(Customer.fromRow).toList(growable: false);
  //   });
  // }

  // static Future<List<Customer>> getAll() async {
  //   final List<Customer> customers = [];
  //   final result = await db.query('SELECT * FROM customers');
  //   for (final row in result) {
  //     customers.add(Customer.fromRow(row));
  //   }
  //   return customers;
  // }

  // static Future<Customer?> getById(String id) async {
  //   final result = await db.query('SELECT * FROM customers WHERE id = ?', [id]);
  //   if (result.isNotEmpty) {
  //     return Customer.fromRow(result.first);
  //   }
  //   return null;
  // }

