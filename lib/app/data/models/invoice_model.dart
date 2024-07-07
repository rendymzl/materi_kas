// import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';
import 'customer_model.dart';

class Invoice {
  String? id;
  String? invoiceId;
  Timestamp? createdAt;
  Customer? customer;
  ProductsCart? productsCart;
  int? bill;
  int? pay;
  int? change;
  bool? isPaid;
  String? uuid;

  Invoice({
    this.id,
    this.invoiceId,
    this.createdAt,
    this.customer,
    this.productsCart,
    this.bill,
    this.pay,
    this.change,
    this.isPaid,
    this.uuid,
  });

  Invoice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceId = json['invoice_id'];
    createdAt = json['created_at'];
    customer = Customer.fromJson(json['customer']);
    productsCart = ProductsCart.fromJson(json['products_cart']);
    bill = json['bill'];
    pay = json['pay'];
    change = json['change'];
    isPaid = json['isPaid'];
    uuid = json['owner_id'];
  }
  // : id = json['id'],
  //   invoiceId = json['invoice_id'],
  //   createdAt = json['created_at'],
  //   customer = json['customer'],
  //   productsCart = json['products_cart'],
  //   bill = json['bill'],
  //   pay = json['pay'],
  //   change = json['change'],
  //   isPaid = json['is_paid'],
  //   uuid = json['owner_id'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'created_at': createdAt,
        'customer': customer?.toJson(),
        'products_cart': productsCart?.toJson(),
        'bill': bill,
        'pay': pay,
        'change': change,
        'is_paid': isPaid,
        'owner_id': uuid,
      };
}

class ProductsCart {
  List<Cart>? cartList;

  ProductsCart({this.cartList});

  ProductsCart.fromJson(Map<String, dynamic> json) {
    if (json['cart_list'] != null) {
      cartList = <Cart>[];
      json['cart_list'].forEach((cartJson) {
        cartList?.add(Cart.fromJson(cartJson));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (cartList != null) {
      data['cart_list'] = cartList?.map((cart) => cart.toJson()).toList();
    }
    return data;
  }
}


// import 'dart:convert';

// import 'cart_model.dart';
// import 'customer_model.dart';

// class Invoice {
//   String? id;
//   String? invoiceId;
//   DateTime? createdAt;
//   Customer? customer;
//   ProductsCart? productsCart;
//   int? bill;
//   int? pay;
//   int? change;
//   bool? isPaid;
//   String? uuid;

//   Invoice(
//       {this.id,
//       this.invoiceId,
//       this.createdAt,
//       this.customer,
//       this.productsCart,
//       this.bill,
//       this.pay,
//       this.change,
//       this.isPaid,
//       this.uuid});

//   Invoice.fromJson(Map<String, dynamic> jsonData) {
//     Map<String, dynamic> customerjson = {};

//     // dynamic decodedCustomer = json.decode(jsonb['customer']);
//     if (jsonData['customer'] is Map<String, dynamic>) {
//       customerjson = jsonData['customer'];
//     } else {
//       customerjson = json.decode(jsonData['customer']);
//     }

//     List<Cart> cartList = [];

//     if (jsonData['products_cart'] is List<dynamic>) {
//       List<dynamic> decodedProductsCart = jsonData['products_cart'];
//       cartList = decodedProductsCart.map((cart) {
//         return Cart.fromJson(cart);
//       }).toList();
//     } else {
//       Map<String, dynamic> decodedProductsCart = jsonData['products_cart'];
//       List<dynamic> listDynamic = decodedProductsCart['cart_list'];
//       cartList = listDynamic.map((cart) {
//         return Cart.fromJson(cart);
//       }).toList();
//     }

//     id = jsonData['id'];
//     invoiceId = jsonData['invoice_id'];
//     createdAt = DateTime.parse(jsonData['created_at']);
//     customer = Customer.fromJson(customerjson);
//     productsCart = ProductsCart(cartList: cartList);
//     bill = jsonData['bill'];
//     pay = jsonData['pay'];
//     change = jsonData['change'];
//     isPaid = jsonData['is_paid'];
//     uuid = jsonData['owner_id'];
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['id'] = id;
//     data['invoice_id'] = invoiceId;
//     data['created_at'] = createdAt;
//     if (customer != null) {
//       data['customer'] = customer?.toJson();
//     }
//     if (productsCart != null) {
//       data['products_cart'] = productsCart?.toJson();
//     }
//     data['bill'] = bill;
//     data['pay'] = pay;
//     data['change'] = change;
//     data['is_paid'] = isPaid;
//     data['owner_id'] = uuid;
//     return data;
//   }
// }

// class ProductsCart {
//   List<Cart>? cartList;

//   ProductsCart({this.cartList});

//   ProductsCart.fromJson(Map<String, dynamic> json) {
//     if (json['cart_list'] != null) {
//       cartList = <Cart>[];
//       json['cart_list'].forEach((v) {
//         cartList?.add(Cart.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     if (cartList != null) {
//       data['cart_list'] = cartList?.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
