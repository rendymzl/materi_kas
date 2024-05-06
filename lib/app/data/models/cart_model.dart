import 'product_model.dart';

class Cart {
  Product? product;
  int? quantity;
  int? individualDiscount;
  int? bundleDiscount;

  Cart(
      {this.product,
      this.quantity,
      this.individualDiscount,
      this.bundleDiscount});

  Cart.fromJson(Map<String, dynamic> json) {
    product =
        json['product'] != null ? Product?.fromJson(json['product']) : null;
    quantity = json['quantity'];
    individualDiscount = json['individual_discount'];
    bundleDiscount = json['bundle_discount'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (product != null) {
      data['product'] = product?.toJson();
    }
    data['quantity'] = quantity;
    data['individual_discount'] = individualDiscount;
    data['bundle_discount'] = bundleDiscount;
    return data;
  }
}
