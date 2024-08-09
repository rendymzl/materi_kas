import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'sales_model.dart';

class Product {
  String id;
  String productId;
  Timestamp? createdAt;
  bool? featured;
  String productName;
  String unit;
  Sales? sales;
  RxDouble costPrice;
  double sellPrice1;
  double? sellPrice2;
  double? sellPrice3;
  RxDouble stock;
  RxDouble stockMin;
  int? sold;

  Product({
    required this.id,
    required this.productId,
    this.createdAt,
    this.featured,
    required this.productName,
    required this.unit,
    this.sales,
    required double costPrice,
    required this.sellPrice1,
    this.sellPrice2,
    this.sellPrice3,
    required double stock,
    double stockMin = 0,
    this.sold,
  })  : costPrice = costPrice.obs,
        stock = stock.obs,
        stockMin = stockMin.obs;

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        productId = json['product_id'],
        createdAt = json['created_at'],
        featured = json['featured'],
        productName = json['product_name'],
        unit = json['unit'],
        sales = json['sales'] != null ? Sales.fromJson(json['sales']) : null,
        costPrice = ((json['cost_price'] is int
                ? json['cost_price'].toDouble()
                : json['cost_price']) as double)
            .obs,
        sellPrice1 = json['sell_price1'].toDouble(),
        sellPrice2 = json['sell_price2'].toDouble(),
        sellPrice3 = json['sell_price3'].toDouble(),
        stock = ((json['stock'] is int
                ? json['stock'].toDouble()
                : json['stock']) as double)
            .obs,
        stockMin = json['stock_min'] != null
            ? RxDouble((json['stock_min'] is int
                ? json['stock_min'].toDouble()
                : json['stock_min']) as double)
            : RxDouble(10),
        sold = json['sold'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'created_at': createdAt,
        'featured': featured,
        'product_name': productName,
        'unit': unit,
        'sales': sales?.toJson(),
        'cost_price': costPrice.value,
        'sell_price1': sellPrice1,
        'sell_price2': sellPrice2,
        'sell_price3': sellPrice3,
        'stock': stock.value,
        'stock_min': stockMin.value,
        'sold': sold,
      };

  double getPrice(int priceType) {
    switch (priceType) {
      case 1:
        return sellPrice1;
      case 2:
        return (sellPrice2 != null && sellPrice2 != 0)
            ? sellPrice2!
            : sellPrice1;
      case 3:
        return (sellPrice3 != null && sellPrice3 != 0)
            ? sellPrice3!
            : sellPrice1;
      default:
        return sellPrice1;
    }
  }

  void updateStock(double stockValue, double? prevQty) {
    double qty = prevQty ?? 0;
    stock.value = stock.value - (stockValue - qty);
    // debugPrint(stockValue.toString());
    // debugPrint(qty.toString());
  }

  String get stockDisplay {
    return stock.value % 1 == 0
        ? stock.value.toInt().toString()
        : stock.value.toString().replaceAll('.', ',');
  }

  String get minStockDisplay {
    return stockMin.value % 1 == 0
        ? stockMin.value.toInt().toString()
        : stockMin.value.toString().replaceAll('.', ',');
  }
}
