// import 'package:powersync/sqlite3.dart' as sqlite;

class Product {
  String? id;
  String? productId;
  DateTime? createdAt;
  bool? featured;
  String? productName;
  int? sellPrice;
  int? costPrice;
  int? sold;
  int? stock;
  late String uuid;

  Product(
      {this.id,
      this.productId,
      this.createdAt,
      this.featured,
      this.productName,
      this.sellPrice,
      this.costPrice,
      this.sold,
      // this.stock,
      required this.uuid});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    createdAt = DateTime.parse(json['created_at']);
    featured = json['featured'];
    productName = json['product_name'];
    sellPrice = json['sell_price'];
    costPrice = json['cost_price'];
    sold = json['sold'];
    // stock = json['stock'];
    uuid = json['owner_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['created_at'] = createdAt!.toIso8601String();
    data['featured'] = featured;
    data['product_name'] = productName;
    data['sell_price'] = sellPrice;
    data['cost_price'] = costPrice;
    data['sold'] = sold;
    // data['stock'] = stock;
    data['owner_id'] = uuid;
    return data;
  }
}
