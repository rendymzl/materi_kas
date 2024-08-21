import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OperatingCost {
  String? id;
  String? storeId;
  DateTime? createdAt;
  String? name;
  int? amount;
  String? note;

  OperatingCost({
    this.id,
    this.storeId,
    this.createdAt,
    this.name,
    this.amount,
    this.note,
  });

  OperatingCost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at']).toLocal()
        : null;
    name = json['name'];
    amount = json['amount'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['store_id'] = storeId;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name;
    data['amount'] = amount;
    data['note'] = note;
    return data;
  }

  // CRUD operations

  // Insert (Create)
  static Future<void> insert(OperatingCost operatingCost) async {
    try {
      await Supabase.instance.client
          .from('operating_costs')
          .insert(operatingCost.toJson());
      debugPrint('ok');
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
    // if (response.error != null) {
    //   throw Exception('Failed to insert sales: ${response.error!.message}');
    // }
    // sales.id = response.data[0]['id'];
  }

  // Update
  Future<void> update() async {
    try {
      await Supabase.instance.client
          .from('operating_costs')
          .update(toJson())
          .eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Delete
  Future<void> delete() async {
    try {
      await Supabase.instance.client
          .from('operating_costs')
          .delete()
          .eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Fetch all sales by storeId
  static Future<List<OperatingCost>> getAll(String storeId) async {
    try {
      final response = await Supabase.instance.client
          .from('operating_costs')
          .select()
          .eq('store_id', storeId);
      return (response as List)
          .map((json) => OperatingCost.fromJson(json))
          .toList();
    } on AuthException catch (e) {
      debugPrint(e.message);
      return [];
    }
  }

  // Real-time subscription to changes in the sales table
  static Future<Stream<List<OperatingCost>>> subscribe(String storeId) async {
    return Supabase.instance.client
        .from('operating_costs')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .map((data) =>
            data.map((json) => OperatingCost.fromJson(json)).toList());
  }
}
