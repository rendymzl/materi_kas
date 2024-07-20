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
    return items.fold(0, (sum, item) => sum + item.getTotal(priceType));
  }

  double getTotalIndividualDiscount() {
    return items.fold(0, (sum, item) => sum + item.individualDiscount.value);
  }

  double getTotal(int priceType) {
    return getSubtotal(priceType) - getTotalIndividualDiscount();
  }

  void addItem(CartItem newItem) {
    final existingItem =
        items.firstWhereOrNull((item) => item.product.id == newItem.product.id);
    if (existingItem != null) {
      existingItem.quantity.value += newItem.quantity.value;
      existingItem.individualDiscount.value = newItem.individualDiscount.value;
      existingItem.bundleDiscount.value = newItem.bundleDiscount.value;
    } else {
      items.add(newItem);
    }
  }

  void updateQuantity(String productId, int quantity) {
    final existingItem =
        items.firstWhere((item) => item.product.id == productId);
    existingItem.quantity.value = quantity;
  }

  void updateDiscount(String productId, int discount) {
    final existingItem =
        items.firstWhere((item) => item.product.id == productId);
    existingItem.individualDiscount.value = discount.toDouble();
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }
}
