import 'dart:convert';

import 'cart_model.dart';
import 'customer_model.dart';
// import 'package:powersync/sqlite3.dart' as sqlite;

class Invoice {
  String? id;
  String? invoiceId;
  DateTime? createdAt;
  Customer? customer;
  ProductsCart? productsCart;
  ProductsReturnCart? productsReturnCart;
  int? bill;
  int? pay;
  int? returnFee;
  int? change;
  bool? isPaid;
  String? uuid;

  Invoice(
      {this.id,
      this.invoiceId,
      this.createdAt,
      this.customer,
      this.productsCart,
      this.productsReturnCart,
      this.bill,
      this.pay,
      this.returnFee,
      this.change,
      this.isPaid,
      this.uuid});

  Invoice.fromJson(Map<String, dynamic> jsonb) {
    Map<String, dynamic> customerjson = {};

    // dynamic decodedCustomer = json.decode(jsonb['customer']);
    if (jsonb['customer'] is Map<String, dynamic>) {
      customerjson = jsonb['customer'];
    } else {
      customerjson = json.decode(jsonb['customer']);
    }

    List<Cart> cartList = [];

    if (jsonb['products_cart'] is List<dynamic>) {
      List<dynamic> decodedProductsCart = jsonb['products_cart'];
      cartList = decodedProductsCart.map((cart) {
        return Cart.fromJson(cart);
      }).toList();
    } else {
      Map<String, dynamic> decodedProductsCart = jsonb['products_cart'];
      List<dynamic> listDynamic = decodedProductsCart['cart_list'];
      cartList = listDynamic.map((cart) {
        return Cart.fromJson(cart);
      }).toList();
    }

    List<Cart> returnCartList = [];
    if (jsonb['products_return_cart'] != null) {
      if (jsonb['products_return_cart'] is List<dynamic>) {
        List<dynamic> decodedProductsCart = jsonb['products_return_cart'];
        returnCartList = decodedProductsCart.map((cart) {
          return Cart.fromJson(cart);
        }).toList();
      } else {
        Map<String, dynamic> decodedProductsCart =
            jsonb['products_return_cart'];
        List<dynamic> listDynamic = decodedProductsCart['cart_list'];
        returnCartList = listDynamic.map((cart) {
          return Cart.fromJson(cart);
        }).toList();
      }
    }

    id = jsonb['id'];
    invoiceId = jsonb['invoice_id'];
    createdAt = DateTime.parse(jsonb['created_at']);
    customer = Customer.fromJson(customerjson);
    productsCart = ProductsCart(cartList: cartList);
    productsReturnCart = ProductsReturnCart(cartList: returnCartList);
    bill = jsonb['bill'];
    pay = jsonb['pay'];
    returnFee = jsonb['return_fee'];
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
    if (productsReturnCart != null) {
      data['products_return_cart'] = productsCart?.toJson();
    }
    data['bill'] = bill;
    data['pay'] = pay;
    data['return_fee'] = returnFee;
    data['change'] = change;
    data['is_paid'] = isPaid;
    data['owner_id'] = uuid;
    return data;
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

class ProductsReturnCart {
  List<Cart>? cartList;

  ProductsReturnCart({this.cartList});

  ProductsReturnCart.fromJson(Map<String, dynamic> json) {
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
