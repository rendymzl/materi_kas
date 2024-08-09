// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cart_item_model.dart';

class Cart {
  var items = <CartItem>[].obs;

  // List<CartItem> items;

  Cart({required this.items});

  Cart.fromJson(Map<String, dynamic> json) {
    items.value =
        (json['items'] as List).map((i) => CartItem.fromJson(i)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['items'] = items.map((item) => item.toJson()).toList();
    return data;
  }

  double getSubtotal(int priceType) {
    double subTotal =
        items.fold(0, (sum, item) => sum + item.getSubtotal(priceType));

    return subTotal;
  }

  double getSubTotalCost() {
    double costPrice =
        items.fold(0, (sum, item) => sum + item.getSubTotalCost());

    return costPrice;
  }

  double getTotalCost() {
    double costPrice = items.fold(0, (sum, item) => sum + item.getTotalCost());

    return costPrice;
  }

  double getTotalReturn(int priceType) {
    double totalReturn =
        items.fold(0, (sum, item) => sum + item.getTotalReturn(priceType));

    return totalReturn;
  }

  double getTotalQuantityReturn() {
    double totalQuantityReturn =
        items.fold(0, (sum, item) => sum + item.quantityReturn.value);

    return totalQuantityReturn;
  }

  double get totalIndividualDiscount {
    return items.fold(0, (sum, item) => sum + item.individualDiscount.value);
  }

  double getTotal(int priceType) {
    return getSubtotal(priceType) - totalIndividualDiscount;
  }

  void addItem(CartItem newItem) {
    final existingItem =
        items.firstWhereOrNull((item) => item.product.id == newItem.product.id);
    if (existingItem != null) {
      existingItem.quantity.value += newItem.quantity.value;
    } else {
      items.add(newItem);
    }
  }

  void updateQuantity(String productId, double quantity) {
    final existingItem =
        items.firstWhere((item) => item.product.id == productId);
    existingItem.quantity.value = quantity;
  }

  void updateQuantityReturn(String productId, double quantityReturn) {
    final existingItem =
        items.firstWhere((item) => item.product.id == productId);
    existingItem.quantityReturn.value = quantityReturn;
  }

  void updateDiscount(String productId, double discount) {
    final existingItem =
        items.firstWhere((item) => item.product.id == productId);
    existingItem.individualDiscount.value = discount;
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }
}
