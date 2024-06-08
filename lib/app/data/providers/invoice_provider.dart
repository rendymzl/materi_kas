import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:materi_kas/app/data/providers/product_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../main.dart';
import '../models/invoice_model.dart';

class InvoiceProvider extends GetConnect {
  //! Read
  static Future<List<Invoice>> fetchData(
      String uuid, PickerDateRange? date) async {
    late List<Map<String, dynamic>> response;

    if (date != null) {
      final formattedStartDate = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(date.startDate!.subtract(const Duration(hours: 7)));
      final formattedEndDate = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(date.endDate!.subtract(const Duration(hours: 7)));
      debugPrint(formattedStartDate);
      debugPrint(formattedEndDate);
      response = await supabase
          .from('invoices')
          .select()
          .eq('owner_id', uuid)
          .gte('created_at', formattedStartDate)
          .lte('created_at', formattedEndDate)
          .order('created_at');
    } else {
      response = await supabase
          .from('invoices')
          .select()
          .eq('owner_id', uuid)
          .order('created_at');
    }

    return response.map((invoice) => Invoice.fromJson(invoice)).toList();
  }

//! FindById
  static Future<List<Invoice>> fetchDataById(
      String uuid, String invoiceId) async {
    late List<Map<String, dynamic>> response;

    if (invoiceId == '') {
      response = await supabase
          .from('invoices')
          .select()
          .eq('owner_id', uuid)
          .order('created_at');
    } else {
      response = await supabase
          .from('invoices')
          .select()
          .eq('owner_id', uuid)
          .ilike('invoice_id', '%$invoiceId%')
          .order('created_at');
    }

    return response.map((invoice) => Invoice.fromJson(invoice)).toList();
  }

  //! create
  static Future<List<Invoice>> create(Invoice invoice) async {
    String customerJson = jsonEncode(invoice.customer);
    List<Map<String, dynamic>> productsCartJson =
        invoice.productsCart!.cartList!.map((cart) {
      String? createdAtString = cart.product!.createdAt?.toIso8601String();
      return cart.toJson()..['product']['created_at'] = createdAtString;
    }).toList();

    await supabase.from('invoices').insert([
      {
        'invoice_id': invoice.invoiceId,
        'created_at': invoice.createdAt!.toIso8601String(),
        'customer': customerJson,
        'products_cart': productsCartJson,
        'bill': invoice.bill,
        'pay': invoice.pay,
        'change': invoice.change,
        'is_paid': invoice.isPaid,
        'owner_id': invoice.uuid,
      }
    ]).then(
      (value) async {
        for (var cart in invoice.productsCart!.cartList!) {
          Map<String, dynamic> data = {
            'sold': cart.product!.sold! + cart.quantity!
          };
          await ProductProvider.update(
              data, cart.product!.id!, cart.product!.uuid);
        }
      },
    );

    // await cacheUuid.remove('cacheInvoice');
    List<Invoice> response = await fetchData(invoice.uuid!, null);
    return response;
  }

  //! update
  static Future<List<Invoice>> update(
      Map<String, Object?> newData, String id, String uuid) async {
    await supabase
        .from('invoices')
        .update(newData)
        .eq('owner_id', uuid)
        .eq('id', id)
        .select();

    List<Invoice> response = await fetchData(uuid, null);
    return response;
  }

  //! delete
  static Future<List<Invoice>> destroy(Invoice invoice) async {
    // GetStorage cacheUuid = GetStorage(invoice.uuid!);
    await supabase.from('invoices').delete().eq('id', invoice.id!);

    // await cacheUuid.remove('cacheInvoice');
    List<Invoice> response = await fetchData(invoice.uuid!, null);
    return response;
  }
  // static Stream<List<Invoice>> watchInvoice(String uuid) {
  //   return db
  //       .watch('SELECT * FROM invoices ORDER BY created_at DESC')
  //       .map((results) {
  //     return results.map((row) => Invoice.fromRow(row, uuid)).toList();
  //   });
  // }

  // static Future<void> create(Invoice invoice) async {
  //   String customerJson = jsonEncode(invoice.customer);
  //   String productsCartJson = jsonEncode(
  //     invoice.productsCart!.cartList!.map((cart) {
  //       String? createdAtString = cart.product!.createdAt?.toIso8601String();
  //       return cart.toJson()..['product']['created_at'] = createdAtString;
  //     }).toList(),
  //   );
  //   await db.execute(
  //       '''INSERT INTO invoices (id, created_at, invoice_id, customer, products_cart, bill, pay, change, is_paid, owner_id)
  //       VALUES (uuid(), datetime(), ?, ?, ?, ?, ?, ?, ?, ?)''',
  //       [
  //         invoice.invoiceId,
  //         customerJson,
  //         productsCartJson,
  //         invoice.bill,
  //         invoice.pay,
  //         invoice.change,
  //         invoice.isPaid,
  //         invoice.uuid,
  //       ]);
  // }

  // static Future<void> update(Invoice invoice) async {
  //   await db.execute('''
  //       UPDATE invoices
  //       SET
  //         created_at = datetime(),
  //         customer = ?,
  //         productsCart = ?,
  //         bill = ?,
  //         pay = ?,
  //         change = ?,
  //         isPaid = ?,
  //         uuid = ?
  //       WHERE invoice_id = ?
  //     ''', [
  //     invoice.invoiceId,
  //     invoice.customer,
  //     invoice.productsCart,
  //     invoice.bill,
  //     invoice.pay,
  //     invoice.change,
  //     invoice.isPaid,
  //     invoice.uuid,
  //   ]);
  // }

  // static Future<void> destroy(Invoice invoice) async {
  //   await db.execute('DELETE FROM invoices WHERE id = ?', [invoice.id]);
  // }
}
