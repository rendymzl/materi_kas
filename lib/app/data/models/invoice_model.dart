import 'dart:convert';

import 'cart_model.dart';
import 'customer_model.dart';
import 'package:powersync/sqlite3.dart' as sqlite;

class Invoice {
  String? id;
  String? invoiceId;
  DateTime? createdAt;
  Customer? customer;
  ProductsCart? productsCart;
  int? bill;
  int? pay;
  int? change;
  bool? isPaid;
  String? uuid;

  Invoice(
      {this.id,
      this.invoiceId,
      this.createdAt,
      this.customer,
      this.productsCart,
      this.bill,
      this.pay,
      this.change,
      this.isPaid,
      this.uuid});

  Invoice.fromJson(Map<String, dynamic> jsonb) {
    Map<String, dynamic> customerjson = {};

    dynamic decodedCustomer = json.decode(jsonb['customer']);
    if (decodedCustomer is Map<String, dynamic>) {
      customerjson = decodedCustomer;
    }

    List<Cart> cartList = [];

    List<dynamic> decodedProductsCart = jsonb['products_cart'];
    cartList = decodedProductsCart.map((cart) {
      return Cart.fromJson(cart);
    }).toList();

    id = jsonb['id'];
    invoiceId = jsonb['invoice_id'];
    createdAt = DateTime.parse(jsonb['created_at']);
    customer = Customer.fromJson(customerjson);
    productsCart = ProductsCart(cartList: cartList);
    bill = jsonb['bill'];
    pay = jsonb['pay'];
    change = jsonb['change'];
    isPaid = jsonb['is_paid'];
    uuid = jsonb['owner_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['invoice_id'] = invoiceId;
    data['created_at'] = createdAt;
    if (customer != null) {
      data['customer'] = customer?.toJson();
    }
    if (productsCart != null) {
      data['products_cart'] = productsCart?.toJson();
    }
    data['bill'] = bill;
    data['pay'] = pay;
    data['change'] = change;
    data['is_paid'] = isPaid;
    data['owner_id'] = uuid;
    return data;
  }

  factory Invoice.fromRow(sqlite.Row row, String uuid) {
    Map<String, dynamic> customer = {};

    dynamic decodedCustomer = json.decode(row['customer']);
    if (decodedCustomer is Map<String, dynamic>) {
      customer = decodedCustomer;
    }

    List<Cart> cartList = [];

    dynamic decodedProductsCart = json.decode(row['products_cart']);
    if (decodedProductsCart is List<dynamic>) {
      cartList = decodedProductsCart.map((cart) {
        return Cart.fromJson(cart);
      }).toList();
    }

    return Invoice(
        id: row['id'],
        invoiceId: row['invoice_id'],
        createdAt: DateTime.parse(row['created_at']),
        customer: Customer.fromJson(customer),
        productsCart: ProductsCart(cartList: cartList),
        bill: row['bill'],
        pay: row['pay'],
        change: row['change'],
        isPaid: row['is_paid'] == 1 ? true : false,
        uuid: row['owner_id']);
  }
}

class ProductsCart {
  List<Cart>? cartList;

  ProductsCart({this.cartList});

  ProductsCart.fromJson(Map<String, dynamic> json) {
    if (json['cart_list'] != null) {
      cartList = <Cart>[];
      json['cart_list'].forEach((v) {
        cartList?.add(Cart.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (cartList != null) {
      data['cart_list'] = cartList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
