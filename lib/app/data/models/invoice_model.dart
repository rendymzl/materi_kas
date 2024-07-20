import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';
// import 'cart_model.dart';
import 'customer_model.dart';

class PaymentTransaction {
  String? method; // Metode pembayaran, misalnya 'Credit Card', 'Bank Transfer'
  double amountPaid;
  Timestamp? date;

  PaymentTransaction({
    this.method,
    this.amountPaid = 0.0,
    this.date,
  });

  PaymentTransaction.fromJson(Map<String, dynamic> json)
      : method = json['method'],
        amountPaid = json['amount_paid'],
        date = json['created_at'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['method'] = method;
    data['amount_paid'] = amountPaid;
    data['date'] = date;
    return data;
  }
}

class Invoice {
  String? id;
  String? invoiceId;
  Timestamp? createdAt;
  Customer? customer;
  List<CartItem> purchaseList;
  List<CartItem>? returnList;
  List<CartItem>? afterReturnList;
  int priceType;
  double discount;
  double tax;
  double returnFee;
  List<PaymentTransaction> payments;
  double debtAmount;
  bool isDebtPaid;
  // String? uuid;

  Invoice({
    this.id,
    this.invoiceId,
    this.createdAt,
    this.customer,
    required this.purchaseList,
    this.returnList,
    this.afterReturnList,
    required this.priceType,
    this.discount = 0.0,
    this.tax = 0.0,
    this.returnFee = 0.0,
    required this.payments,
    this.debtAmount = 0.0,
    this.isDebtPaid = false,
  });

  Invoice.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        customer = Customer.fromJson(json['customer']),
        createdAt = json['created_at'],
        purchaseList = (json['purchase_list'] as List)
            .map((i) => CartItem.fromJson(i))
            .toList(),
        returnList = json['return_list'] != null
            ? (json['return_list'] as List)
                .map((i) => CartItem.fromJson(i))
                .toList()
            : null,
        afterReturnList = json['after_return_list'] != null
            ? (json['after_return_list'] as List)
                .map((i) => CartItem.fromJson(i))
                .toList()
            : null,
        priceType = json['price_type'],
        discount = json['discount'],
        tax = json['tax'],
        returnFee = json['return_fee'] ?? 0.0,
        payments = (json['payments'] as List)
            .map((i) => PaymentTransaction.fromJson(i))
            .toList(),
        debtAmount = json['debt_amount'],
        isDebtPaid = json['is_debt_paid'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['customer'] = customer?.toJson();
    data['created_at'] = createdAt;
    data['purchase_list'] = purchaseList.map((item) => item.toJson()).toList();
    data['return_list'] = returnList?.map((item) => item.toJson()).toList();
    data['after_return_list'] =
        afterReturnList?.map((item) => item.toJson()).toList();
    data['price_type'] = priceType;
    data['discount'] = discount;
    data['tax'] = tax;
    data['return_fee'] = returnFee;
    data['payments'] = payments.map((item) => item.toJson()).toList();
    data['debt_amount'] = debtAmount;
    data['is_debt_paid'] = isDebtPaid;
    return data;
  }

  double get subtotal {
    return purchaseList.fold(
        0, (prev, item) => prev + item.getTotal(priceType));
  }

  double get totalIndividualDiscount {
    return purchaseList.fold(
        0,
        (prev, item) =>
            prev + (item.individualDiscount.value) * (item.quantity.value));
  }

  double get totalDiscount {
    return totalIndividualDiscount;
  }

  double get totalTax {
    return subtotal * (tax / 100);
  }

  double get total {
    return subtotal - totalDiscount + totalTax + returnFee;
  }

  double get totalPaid {
    return payments.fold(0, (prev, payment) => prev + payment.amountPaid);
  }

  double get remainingDebt {
    return debtAmount - totalPaid;
  }

  void addPayment(double amount, {String? method, Timestamp? date}) {
    payments.add(PaymentTransaction(
      method: method,
      amountPaid: amount,
      date: date,
    ));
    isDebtPaid = remainingDebt <= 0;
  }
}


// class CartList {
//   List<Cart>? purchaseCart;
//   List<Cart>? returnCart;
//   List<Cart>? afterReturnCart;

//   CartList({this.purchaseCart, this.returnCart, this.afterReturnCart});

//   CartList.fromJson(Map<String, dynamic> json) {
//     if (json['purchase_cart'] != null) {
//       purchaseCart = <Cart>[];
//       json['purchase_cart'].forEach((cartJson) {
//         purchaseCart?.add(Cart.fromJson(cartJson));
//       });
//     }
//     if (json['return_cart'] != null) {
//       returnCart = <Cart>[];
//       json['return_cart'].forEach((cartJson) {
//         returnCart?.add(Cart.fromJson(cartJson));
//       });
//     }
//     if (json['aftet_return_cart'] != null) {
//       afterReturnCart = <Cart>[];
//       json['aftet_return_cart'].forEach((cartJson) {
//         afterReturnCart?.add(Cart.fromJson(cartJson));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     if (purchaseCart != null) {
//       data['purchase_cart'] =
//           purchaseCart?.map((cart) => cart.toJson()).toList();
//     }
//     if (returnCart != null) {
//       data['return_cart'] = returnCart?.map((cart) => cart.toJson()).toList();
//     }
//     if (returnCart != null) {
//       data['aftet_return_cart'] =
//           afterReturnCart?.map((cart) => cart.toJson()).toList();
//     }
//     return data;
//   }
// }
