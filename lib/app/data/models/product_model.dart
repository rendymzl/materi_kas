import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  String? productId;
  Timestamp? createdAt;
  bool? featured;
  String? productName;
  String? unit;
  int? sellPrice;
  int? costPrice;
  int? sold;
  int? stock;
  String? uuid;

  Product({
    this.id,
    this.productId,
    this.createdAt,
    this.featured,
    this.productName,
    this.unit,
    this.sellPrice,
    this.costPrice,
    this.sold,
    this.stock,
    this.uuid,
  });

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        productId = json['product_id'],
        createdAt = json['created_at'],
        featured = json['featured'],
        productName = json['product_name'],
        unit = json['unit'],
        sellPrice = json['sell_price'],
        costPrice = json['cost_price'],
        sold = json['sold'],
        stock = json['stock'],
        uuid = json['owner_id'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'created_at': createdAt,
        'featured': featured,
        'product_name': productName,
        'unit': unit,
        'sell_price': sellPrice,
        'cost_price': costPrice,
        'sold': sold,
        'stock': stock,
        'owner_id': uuid,
      };
}
