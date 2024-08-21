// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';

// import '../providers/sales_invoice_services.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'sales_invoice_model.dart';

class Sales {
  String? id;
  String? salesId;
  DateTime? createdAt;
  String? name;
  String? phone;
  String? address;
  String? storeId;
  // late String uuid;

  Sales({
    this.id,
    this.salesId,
    this.createdAt,
    this.name,
    this.phone,
    this.address,
    this.storeId,
    // required this.uuid,
  });

  Sales.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    salesId = json['sales_id'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at']).toLocal()
        : null;
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
    storeId = json['store_id'];
    // uuid = json['owner_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['sales_id'] = salesId;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name;
    data['phone'] = phone;
    data['address'] = address;
    data['store_id'] = storeId;
    // data['owner_id'] = uuid;
    return data;
  }

  // late SalesInvoiceService salesInvoiceSecvice = Get.find();
  // late final salesInvoices = salesInvoiceSecvice.invoices;

  List<SalesInvoice> getInvoiceListBySalesId(List<SalesInvoice> salesInvoices) {
    return salesInvoices
        .where((invoice) =>
            invoice.sales.value?.id?.toLowerCase() == id!.toLowerCase())
        .toList();
  }

  double getTotalDebt(List<SalesInvoice> salesInvoices) {
    double totalDebt = getInvoiceListBySalesId(salesInvoices)
        .fold(0, (prev, invoice) => prev + invoice.remainingDebt);

    return totalDebt;
  }

  // CRUD operations

  // Insert (Create)
  static Future<void> insert(Sales sales) async {
    try {
      await Supabase.instance.client.from('sales').insert(sales.toJson());
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
          .from('sales')
          .update(toJson())
          .eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Delete
  Future<void> delete() async {
    try {
      await Supabase.instance.client.from('sales').delete().eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Fetch all sales by storeId
  static Future<List<Sales>> getAll(String storeId) async {
    try {
      final response = await Supabase.instance.client
          .from('sales')
          .select()
          .eq('store_id', storeId);
      return (response as List).map((json) => Sales.fromJson(json)).toList();
    } on AuthException catch (e) {
      debugPrint(e.message);
      return [];
    }
  }

  // Real-time subscription to changes in the sales table
  static Future<Stream<List<Sales>>> subscribe(String storeId) async {
    return Supabase.instance.client
        .from('sales')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .map((data) => data.map((json) => Sales.fromJson(json)).toList());
  }
}
