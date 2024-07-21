import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'product_model.dart';

class CartItem {
  final Product product;
  RxInt quantity;
  RxInt individualDiscount;
  RxInt bundleDiscount;

  CartItem({
    required this.product,
    required int quantity,
    int individualDiscount = 0,
    int bundleDiscount = 0,
  })  : quantity = quantity.obs,
        individualDiscount = individualDiscount.obs,
        bundleDiscount = bundleDiscount.obs;

  CartItem.fromJson(Map<String, dynamic> json)
      : product = Product.fromJson(json['product']),
        quantity = (json['quantity'] as int).obs,
        individualDiscount = (json['individual_discount'] as int).obs,
        bundleDiscount = (json['bundle_discount'] as int).obs;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['product'] = product.toJson();
    data['quantity'] = quantity.value;
    data['individual_discount'] = individualDiscount.value;
    data['bundle_discount'] = bundleDiscount.value;
    return data;
  }

  int getPrice(int priceType) {
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

  int getSubtotal(int priceType) {
    int price = getPrice(priceType);
    return price * quantity.value;
  }

  int getTotal(int priceType) {
    // int price = getPrice(priceType);
    return getSubtotal(priceType) - individualDiscount.value;
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
