import 'cart_item_model.dart';

class Cart {
  List<CartItem> items;

  Cart({required this.items});

  Cart.fromJson(Map<String, dynamic> json)
      : items =
            (json['items'] as List).map((i) => CartItem.fromJson(i)).toList();

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['items'] = items.map((item) => item.toJson()).toList();
    return data;
  }

  double getSubtotal(int priceType) {
    return items.fold(0, (sum, item) => sum + item.getTotal(priceType));
  }

  double getTotalIndividualDiscount(int priceType) {
    return items.fold(0, (sum, item) => sum + item.getTotalDiscount(priceType));
  }

  double getTotal(int priceType) {
    return getSubtotal(priceType) - getTotalIndividualDiscount(priceType);
  }

  void addItem(CartItem newItem) {
    // Cek apakah item sudah ada di keranjang
    final existingItem = items.firstWhere(
      (item) => item.product.id == newItem.product.id,
      orElse: () => CartItem(
        product: newItem.product,
        quantity: 0,
        individualDiscount: 0,
        bundleDiscount: 0,
      ),
    );

    if (existingItem.quantity == 0) {
      // Jika item belum ada, tambahkan item baru
      items.add(newItem);
    } else {
      // Jika item sudah ada, tambahkan jumlahnya
      existingItem.quantity =
          (existingItem.quantity ?? 0) + (newItem.quantity ?? 0);
      existingItem.individualDiscount = newItem.individualDiscount ?? 0;
      existingItem.bundleDiscount = newItem.bundleDiscount ?? 0;
    }
  }

  void removeItem(String productId) {
    // Hapus item berdasarkan ID produk
    items.removeWhere((item) => item.product.id == productId);
  }

  @override
  String toString() {
    return 'Cart(items: $items, subtotal: ${getSubtotal(1)}, total: ${getTotal(1)})';
  }
}
