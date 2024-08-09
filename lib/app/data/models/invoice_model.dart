import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'account_model.dart';
import 'cart_model.dart';
import 'customer_model.dart';
// import 'store_model.dart';

class OtherCost {
  String name;
  double amount;

  OtherCost({
    required this.name,
    required this.amount,
  });

  OtherCost.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        amount = json['amount'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['amount'] = amount;
    return data;
  }
}

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

class Invoice {
  String? id;
  String? invoiceId;
  Rx<Account> account;
  Rx<Timestamp?> createdAt;
  Rx<Customer?> customer;
  Rx<Cart> purchaseList;
  Rx<Cart?> returnList;
  Rx<Cart?> afterReturnList;
  RxInt priceType;
  RxDouble discount;
  RxDouble tax;
  RxDouble returnFee;
  RxList<PaymentTransaction> payments;
  // RxDouble change;
  RxDouble debtAmount;
  RxBool isDebtPaid;
  RxList<OtherCost> otherCosts;

  Invoice({
    this.id,
    this.invoiceId,
    required Account account,
    Timestamp? createdAt,
    Customer? customer,
    required Cart purchaseList,
    Cart? returnList,
    Cart? afterReturnList,
    required int priceType,
    double discount = 0,
    double tax = 0,
    double returnFee = 0,
    List<PaymentTransaction>? payments,
    // double change = 0,
    double debtAmount = 0,
    bool isDebtPaid = false,
    List<OtherCost>? otherCosts,
  })  : account = Rx<Account>(account),
        createdAt = Rx<Timestamp?>(createdAt),
        customer = Rx<Customer?>(customer),
        purchaseList = Rx<Cart>(purchaseList),
        returnList = Rx<Cart?>(returnList),
        afterReturnList = Rx<Cart?>(afterReturnList),
        priceType = RxInt(priceType),
        discount = RxDouble(discount),
        tax = RxDouble(tax),
        returnFee = RxDouble(returnFee),
        payments = RxList<PaymentTransaction>(payments ?? []),
        // change = RxDouble(change),
        debtAmount = RxDouble(debtAmount),
        isDebtPaid = RxBool(isDebtPaid),
        otherCosts = RxList<OtherCost>(otherCosts ?? []);

  Invoice.fromJson(Map<String, dynamic> json)
      : account = Rx<Account>(Account.fromJson(json['account'])),
        id = json['id'],
        invoiceId = json['invoice_id'],
        createdAt = Rx<Timestamp?>(json['created_at']),
        customer = Rx<Customer?>(Customer.fromJson(json['customer'])),
        purchaseList = Rx<Cart>(Cart.fromJson(json['purchase_list'])),
        returnList = Rx<Cart?>(json['return_list'] != null
            ? Cart.fromJson(json['return_list'])
            : null),
        afterReturnList = Rx<Cart?>(json['after_return_list'] != null
            ? Cart.fromJson(json['after_return_list'])
            : null),
        priceType = RxInt(json['price_type']),
        discount = RxDouble(json['discount'].toDouble()),
        tax = RxDouble(json['tax'].toDouble()),
        returnFee = RxDouble(json['return_fee'].toDouble() ?? 0),
        payments = RxList<PaymentTransaction>((json['payments'] as List)
            .map((i) => PaymentTransaction.fromJson(i))
            .toList()),
        // change = RxDouble(json['change']),
        debtAmount = RxDouble(json['debt_amount'].toDouble()),
        isDebtPaid = RxBool(json['is_debt_paid']),
        otherCosts = RxList<OtherCost>((json['other_costs'] as List)
            .map((i) => OtherCost.fromJson(i))
            .toList());

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['invoice_id'] = invoiceId;
    data['account'] = account.value.toJson();
    data['created_at'] = createdAt.value;
    data['customer'] = customer.value?.toJson();
    data['purchase_list'] = purchaseList.value.toJson();
    data['return_list'] = returnList.value?.toJson();
    data['after_return_list'] = afterReturnList.value?.toJson();
    data['price_type'] = priceType.value;
    data['discount'] = discount.value;
    data['tax'] = tax.value;
    data['return_fee'] = returnFee.value;
    data['payments'] = payments.map((item) => item.toJson()).toList();
    // data['change'] = change.value;
    data['debt_amount'] = debtAmount.value;
    data['is_debt_paid'] = isDebtPaid.value;
    data['other_costs'] = otherCosts.map((item) => item.toJson()).toList();
    return data;
  }

  double get subtotal {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + (item.getSubtotal(priceType.value)));
  }

  double get subtotalCost {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + item.getSubTotalCost());
  }

  double get totalCost {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + item.getTotalCost());
  }

  double get subtotalReturn {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + item.getTotalReturn(priceType.value));
  }

  double get totalIndividualDiscount {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + (item.individualDiscount.value));
  }

  double get totalReturn {
    return subtotalReturn - returnFee.value;
  }

  double get remainingReturn {
    return totalReturn - remainingDebt;
  }

  double get totalDiscount {
    return totalIndividualDiscount;
  }

  double get totalTax {
    return subtotal * (tax.value ~/ 100);
  }

  double get totalOtherCosts {
    return otherCosts.fold(0, (prev, cost) => prev + cost.amount);
  }

  double get total {
    return subtotal - totalDiscount + totalTax + totalOtherCosts;
  }

  double get totalFinal {
    return total - totalReturn;
  }

  double get totalPaid {
    return payments.fold(0, (prev, payment) => prev + payment.amountPaid);
  }

  double get remainingDebt {
    return debtAmount.value - totalPaid;
  }

  double get change {
    double firstPayment = payments.isNotEmpty ? payments[0].amountPaid : 0;

    return totalFinal - firstPayment;
  }

  void addPayment(double amount, {String? method, Timestamp? date}) {
    // double amountPaid = totalPaid + amount <= total ? amount : total - totalPaid;

    payments.add(
        PaymentTransaction(method: method, amountPaid: amount, date: date));
    isDebtPaid.value = remainingDebt <= 0;
  }

  void removePayment(PaymentTransaction paymentTransaction) {
    payments.remove(paymentTransaction);
    isDebtPaid.value = remainingDebt <= 0;
  }

  void updateIsDebtPaid() {
    debtAmount.value = total;
    isDebtPaid.value = remainingDebt <= 0;
  }

  void updateReturn() {
    totalReturn;
  }

  void addOtherCost(String name, double amount) {
    otherCosts.add(OtherCost(name: name, amount: amount));
  }

  void removeOtherCost(String name) {
    otherCosts.removeWhere((cost) => cost.name == name);
    isDebtPaid.value = remainingDebt <= 0;
    updateIsDebtPaid();
    updateReturn();
  }

  Map<String, double> totalPaymentsByMethod() {
    Map<String, double> totals = {};
    for (var payment in payments) {
      if (payment.method != null) {
        if (!totals.containsKey(payment.method)) {
          totals[payment.method!] = 0;
        }
        double result = totals[payment.method!]! + payment.amountPaid;
        totals[payment.method!] = result <= subtotal ? result : subtotal;
      }
    }
    return totals;
  }

  double getTotalByMethod(String method) {
    return totalPaymentsByMethod()[method] ?? 0;
  }

  double get totalProfit {
    return subtotal - subtotalCost - totalDiscount - totalTax - totalOtherCosts;
  }
}
