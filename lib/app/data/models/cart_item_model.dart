import 'product_model.dart';

class CartItem {
  final Product product;
  int? quantity;
  double? individualDiscount;
  double? bundleDiscount;

  CartItem({
    required this.product,
    required this.quantity,
    this.individualDiscount = 0,
    this.bundleDiscount = 0,
  });

  CartItem.fromJson(Map<String, dynamic> json)
      : product = Product.fromJson(json['product']),
        quantity = json['quantity'],
        individualDiscount = json['individual_discount'],
        bundleDiscount = json['bundle_discount'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['product'] = product.toJson();
    data['quantity'] = quantity;
    data['individual_discount'] = individualDiscount;
    data['bundle_discount'] = bundleDiscount;
    return data;
  }

  double getPrice(int priceType) {
    switch (priceType) {
      case 1:
        return product.sellPrice1 ?? 0.0;
      case 2:
        return product.sellPrice2 ?? 0.0;
      case 3:
        return product.sellPrice3 ?? 0.0;
      default:
        return 0.0;
    }
  }

  double getTotal(int priceType) {
    double price = getPrice(priceType);
    int quantityValue = quantity ?? 0;
    return price * quantityValue;
  }

  double getTotalDiscount(int priceType) {
    // double price = getPrice(priceType);
    int quantityValue = quantity ?? 0;
    // double totalPrice = price * quantityValue;

    double totalDiscount = (individualDiscount ?? 0) * quantityValue;

    return totalDiscount;
  }

  double getTotalAfterDiscount(int priceType) {
    double total = getTotal(priceType);
    double totalDiscount = getTotalDiscount(priceType);
    return total - totalDiscount;
  }

  @override
  String toString() {
    return 'CartItem(product: $product, quantity: $quantity, individualDiscount: $individualDiscount, bundleDiscount: $bundleDiscount)';
  }
}
