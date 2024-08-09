import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'cart_model.dart';
import 'sales_model.dart';

class PaymentTransaction {
  String? method;
  double amountPaid;
  Timestamp? date;

  PaymentTransaction({
    this.method,
    this.amountPaid = 0,
    this.date,
  });

  PaymentTransaction.fromJson(Map<String, dynamic> json)
      : method = json['method'],
        amountPaid = json['amount_paid'].toDouble(),
        date = json['date'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['method'] = method;
    data['amount_paid'] = amountPaid;
    data['date'] = date;
    return data;
  }
}

class SalesInvoice {
  String? id;
  String? invoiceId;
  Rx<Timestamp?> createdAt;
  Rx<Sales?> sales;
  Rx<Cart> purchaseList;
  // RxInt priceType;
  RxDouble discount;
  RxDouble tax;
  RxList<PaymentTransaction> payments;
  RxDouble debtAmount;
  RxBool isDebtPaid;

  SalesInvoice({
    this.id,
    this.invoiceId,
    Timestamp? createdAt,
    Sales? sales,
    required Cart purchaseList,
    Cart? returnList,
    Cart? afterReturnList,
    required int priceType,
    double discount = 0,
    double tax = 0,
    double returnFee = 0,
    List<PaymentTransaction>? payments,
    double debtAmount = 0,
    bool isDebtPaid = false,
  })  : createdAt = Rx<Timestamp?>(createdAt),
        sales = Rx<Sales?>(sales),
        purchaseList = Rx<Cart>(purchaseList),
        // priceType = RxInt(priceType),
        discount = RxDouble(discount),
        tax = RxDouble(tax),
        payments = RxList<PaymentTransaction>(payments ?? []),
        debtAmount = RxDouble(debtAmount),
        isDebtPaid = RxBool(isDebtPaid);

  SalesInvoice.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        invoiceId = json['invoice_id'],
        createdAt = Rx<Timestamp?>(json['created_at']),
        sales = Rx<Sales?>(Sales.fromJson(json['sales'])),
        purchaseList = Rx<Cart>(Cart.fromJson(json['purchase_list'])),
        // priceType = RxInt(json['price_type']),
        discount = RxDouble(json['discount'].toDouble()),
        tax = RxDouble(json['tax'].toDouble()),
        payments = RxList<PaymentTransaction>((json['payments'] as List)
            .map((i) => PaymentTransaction.fromJson(i))
            .toList()),
        debtAmount = RxDouble(json['debt_amount'].toDouble()),
        isDebtPaid = RxBool(json['is_debt_paid']);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['invoice_id'] = invoiceId;
    data['created_at'] = createdAt.value;
    data['sales'] = sales.value?.toJson();
    data['purchase_list'] = purchaseList.value.toJson();
    // data['price_type'] = priceType.value;
    data['discount'] = discount.value;
    data['tax'] = tax.value;
    data['payments'] = payments.map((item) => item.toJson()).toList();
    data['debt_amount'] = debtAmount.value;
    data['is_debt_paid'] = isDebtPaid.value;
    return data;
  }

  double get subtotalCost {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + item.getTotalCost());
  }

  // int get subtotalReturn {
  //   return purchaseList.value.items
  //       .fold(0, (prev, item) => prev + item.getTotalReturn(priceType.value));
  // }

  double get totalIndividualDiscount {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + (item.individualDiscount.value));
  }

  double get totalDiscount {
    return totalIndividualDiscount;
  }

  double get totalTax {
    return subtotalCost * (tax.value ~/ 100);
  }

  double get totalCost {
    return subtotalCost - totalDiscount + totalTax;
  }

  double get totalPaid {
    return payments.fold(0, (prev, payment) => prev + payment.amountPaid);
  }

  double get remainingDebt {
    return debtAmount.value - totalPaid;
  }

  void addPayment(double amount, {String? method, Timestamp? date}) {
    // int amountPaid =
    //     totalPaid + amount <= totalCost ? amount : totalCost - totalPaid;

    payments.add(
        PaymentTransaction(method: method, amountPaid: amount, date: date));
    isDebtPaid.value = remainingDebt <= 0;
  }

  void removePayment(PaymentTransaction paymentTransaction) {
    payments.remove(paymentTransaction);
    isDebtPaid.value = remainingDebt <= 0;
  }

  void updateIsDebtPaid() {
    debtAmount.value = totalCost;
    isDebtPaid.value = remainingDebt <= 0;
  }

  Map<String, double> totalPaymentsByMethod() {
    Map<String, double> totals = {};
    for (var payment in payments) {
      if (payment.method != null) {
        if (!totals.containsKey(payment.method)) {
          totals[payment.method!] = 0;
        }
        totals[payment.method!] = totals[payment.method!]! + payment.amountPaid;
      }
    }
    return totals;
  }

  double getTotalByMethod(String method) {
    return totalPaymentsByMethod()[method] ?? 0;
  }
}
