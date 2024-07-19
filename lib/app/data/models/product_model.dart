import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  String? productId;
  Timestamp? createdAt;
  bool? featured;
  String? productName;
  String? unit;
  double? costPrice;
  double? sellPrice1;
  double? sellPrice2;
  double? sellPrice3;
  int? stock;
  int? sold;

  Product({
    this.id,
    this.productId,
    this.createdAt,
    this.featured,
    this.productName,
    this.unit,
    this.costPrice,
    this.sellPrice1,
    this.sellPrice2,
    this.sellPrice3,
    this.stock,
    this.sold,
  });

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        productId = json['product_id'],
        createdAt = json['created_at'],
        featured = json['featured'],
        productName = json['product_name'],
        unit = json['unit'],
        costPrice = json['cost_price'],
        sellPrice1 = json['sell_price1'],
        sellPrice2 = json['sell_price2'],
        sellPrice3 = json['sell_price3'],
        stock = json['stock'],
        sold = json['sold'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'created_at': createdAt,
        'featured': featured,
        'product_name': productName,
        'unit': unit,
        'cost_price': costPrice,
        'sell_price1': sellPrice1,
        'sell_price2': sellPrice2,
        'sell_price3': sellPrice3,
        'stock': stock,
        'sold': sold,
      };

  double getPrice(int priceType) {
    switch (priceType) {
      case 1:
        return sellPrice1 ?? 0;
      case 2:
        return sellPrice2 ?? 0;
      case 3:
        return sellPrice3 ?? 0;
      default:
        return sellPrice1 ?? 0;
    }
  }
}
