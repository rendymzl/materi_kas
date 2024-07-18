import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';
import 'customer_model.dart';

class Invoice {
  String? id;
  String? invoiceId;
  Timestamp? createdAt;
  Customer? customer;
  CartList? cartList;
  int? bill;
  int? pay;
  int? returnPrice;
  int? returnFee;
  int? change;
  bool? isPaid;
  String? uuid;

  Invoice({
    this.id,
    this.invoiceId,
    this.createdAt,
    this.customer,
    this.cartList,
    this.bill,
    this.pay,
    this.returnPrice,
    this.returnFee,
    this.change,
    this.isPaid,
    this.uuid,
  });

  Invoice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceId = json['invoice_id'];
    createdAt = json['created_at'];
    customer = Customer.fromJson(json['customer']);
    cartList = CartList.fromJson(json['cart_list']);
    bill = json['bill'];
    pay = json['pay'];
    returnPrice = json['return'];
    returnFee = json['return_fee'];
    change = json['change'];
    isPaid = json['is_paid'];
    uuid = json['owner_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['invoice_id'] = invoiceId;
    data['created_at'] = createdAt;
    data['customer'] = customer?.toJson();
    data['cart_list'] = cartList?.toJson();
    data['bill'] = bill;
    data['pay'] = pay;
    data['return'] = returnPrice;
    data['return_fee'] = returnFee;
    data['change'] = change;
    data['is_paid'] = isPaid;
    data['owner_id'] = uuid;
    return data;
  }
}

class CartList {
  List<Cart>? purchaseCart;
  List<Cart>? returnCart;
  List<Cart>? afterReturnCart;

  CartList({this.purchaseCart, this.returnCart, this.afterReturnCart});

  CartList.fromJson(Map<String, dynamic> json) {
    if (json['purchase_cart'] != null) {
      purchaseCart = <Cart>[];
      json['purchase_cart'].forEach((cartJson) {
        purchaseCart?.add(Cart.fromJson(cartJson));
      });
    }
    if (json['return_cart'] != null) {
      returnCart = <Cart>[];
      json['return_cart'].forEach((cartJson) {
        returnCart?.add(Cart.fromJson(cartJson));
      });
    }
    if (json['aftet_return_cart'] != null) {
      afterReturnCart = <Cart>[];
      json['aftet_return_cart'].forEach((cartJson) {
        afterReturnCart?.add(Cart.fromJson(cartJson));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (purchaseCart != null) {
      data['purchase_cart'] =
          purchaseCart?.map((cart) => cart.toJson()).toList();
    }
    if (returnCart != null) {
      data['return_cart'] = returnCart?.map((cart) => cart.toJson()).toList();
    }
    if (returnCart != null) {
      data['aftet_return_cart'] =
          afterReturnCart?.map((cart) => cart.toJson()).toList();
    }
    return data;
  }
}
