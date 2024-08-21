// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'product_model.dart';

class CartItem {
  final Product product;
  RxDouble quantity;
  RxDouble individualDiscount;
  RxDouble bundleDiscount;
  RxDouble quantityReturn;

  CartItem({
    required this.product,
    required double quantity,
    double individualDiscount = 0.0,
    double bundleDiscount = 0.0,
    double quantityReturn = 0.0,
  })  : quantity = quantity.obs,
        individualDiscount = individualDiscount.obs,
        bundleDiscount = bundleDiscount.obs,
        quantityReturn = quantityReturn.obs;

  CartItem.fromJson(Map<String, dynamic> json)
      : product = Product.fromJson(json['product']),
        quantity = ((json['quantity'] is int
                ? json['quantity'].toDouble()
                : json['quantity']) as double)
            .obs,
        individualDiscount = ((json['individual_discount'] is int
                ? json['individual_discount'].toDouble()
                : json['individual_discount']) as double)
            .obs,
        bundleDiscount = ((json['bundle_discount'] is int
                ? json['bundle_discount'].toDouble()
                : json['bundle_discount']) as double)
            .obs,
        quantityReturn = ((json['Quantity_return'] is int
                ? json['Quantity_return'].toDouble()
                : json['Quantity_return']) as double)
            .obs;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['product'] = product.toJson();
    data['quantity'] = quantity.value;
    data['individual_discount'] = individualDiscount.value;
    data['bundle_discount'] = bundleDiscount.value;
    data['Quantity_return'] = quantityReturn.value;
    return data;
  }

  double getPrice(int priceType) {
    switch (priceType) {
      case 1:
        return product.sellPrice1;
      case 2:
        return (product.sellPrice2 != null && product.sellPrice2 != 0)
            ? product.sellPrice2!
            : product.sellPrice1;
      case 3:
        return (product.sellPrice3 != null && product.sellPrice3 != 0)
            ? product.sellPrice3!
            : product.sellPrice1;
      default:
        return product.sellPrice1;
    }
  }

  double getSubtotal(int priceType) {
    double price = getPrice(priceType);
    return price * quantity.value;
  }

  double getSubTotalCost() {
    return product.costPrice.value * quantity.value;
  }

  double getTotalCost() {
    return getSubTotalCost();
  }

  double getTotal(int priceType) {
    return getSubtotal(priceType) - individualDiscount.value;
  }

  double getTotalPurchase(int priceType) {
    return getTotal(priceType) + getTotalReturn(priceType);
  }

  double getSubTotalPurchase(int priceType) {
    return getSubtotal(priceType) + getTotalReturn(priceType);
  }

  double getTotalReturn(int priceType) {
    double price = getPrice(priceType);
    return price * quantityReturn.value;
  }

  double get totalQuantity {
    return quantity.value + quantityReturn.value;
  }

  String get qtyDisplay {
    return quantity.value % 1 == 0
        ? quantity.value.toInt().toString()
        : quantity.value.toString().replaceAll('.', ',');
  }

  String get qtyPurchaseDisplay {
    return quantity.value % 1 == 0
        ? totalQuantity.toInt().toString()
        : totalQuantity.toString().replaceAll('.', ',');
  }

  String get qtyReturnDisplay {
    return quantityReturn.value % 1 == 0
        ? quantityReturn.value.toInt().toString()
        : quantityReturn.value.toString().replaceAll('.', ',');
  }

  //   int get totalDiscount {
  //   return purchaseList.fold(
  //       0, (prev, item) => prev + item.getSubtotal(priceType));
  // }

  // int getTotalDiscount() {
  // int price = getPrice(priceType);
  // int totalPrice = price * quantity.value;
  // int totalDiscount = individualDiscount.value * quantity.value;
  // return totalDiscount;
  // return individualDiscount.value;
  // }

  // int getTotalAfterDiscount(int priceType) {
  //   int total = getTotal(priceType);
  //   int totalDiscount = getTotalDiscount();
  //   return total - totalDiscount;
  // }

  @override
  String toString() {
    return 'CartItem(product: $product, quantity: ${quantity.value}, individualDiscount: ${individualDiscount.value}, bundleDiscount: ${bundleDiscount.value})';
  }
}
