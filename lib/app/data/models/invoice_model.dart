import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'account_model.dart';
import 'cart_model.dart';
import 'customer_model.dart';
import 'payment_model.dart';

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

class Invoice {
  String? id;
  String? storeId;
  String? invoiceId;
  Rx<Account> account;
  Rx<DateTime?> createdAt;
  Rx<Customer?> customer;
  Rx<Cart> purchaseList;
  Rx<Cart?> returnList;
  Rx<Cart?> afterReturnList;
  RxInt priceType;
  RxDouble discount;
  RxDouble tax;
  RxDouble returnFee;
  RxList<PaymentTransaction> payments;
  RxDouble debtAmount;
  RxBool isDebtPaid;
  RxList<OtherCost> otherCosts;

  Invoice({
    this.id,
    this.storeId,
    this.invoiceId,
    required Account account,
    DateTime? createdAt,
    Customer? customer,
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
    List<OtherCost>? otherCosts,
  })  : account = Rx<Account>(account),
        createdAt = Rx<DateTime?>(createdAt),
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
        storeId = json['store_id'],
        invoiceId = json['invoice_id'],
        createdAt = Rx<DateTime?>(DateTime.parse(json['created_at']).toLocal()),
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
    if (id != null) data['id'] = id;
    data['store_id'] = storeId;
    data['invoice_id'] = invoiceId;
    data['account'] = account.value.toJson();
    data['created_at'] = createdAt.value?.toIso8601String();
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

  double get subtotalAdditionalReturn {
    double value = 0;
    if (returnList.value != null) {
      value = returnList.value!.items
          .fold(0, (prev, item) => prev + item.getTotalReturn(priceType.value));
    }
    return value;
  }

  double get totalIndividualDiscount {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + (item.individualDiscount.value));
  }

  double get subTotalPurchase {
    return subtotal + subtotalReturn;
  }

  double get totalPurchase {
    return subTotalPurchase - totalDiscount + totalOtherCosts;
  }

  double get totalReturn {
    return subtotalReturn + subtotalAdditionalReturn - returnFee.value;
  }

  bool get isReturn {
    return subtotalReturn + subtotalAdditionalReturn > 0;
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
    return totalPurchase - totalReturn;
  }

  double get totalPaid {
    return payments.fold(0, (prev, payment) => prev + payment.amountPaid);
  }

  double get remainingDebt {
    return totalFinal - totalPaid;
  }

  double get change {
    // double firstPayment = payments.isNotEmpty ? payments[0].amountPaid : 0;

    return totalFinal - totalPaid;
  }

  void addPayment(double amount, {String? method, DateTime? date}) {
    // double amountPaid = totalPaid + amount <= total ? amount : total - totalPaid;

    payments.add(PaymentTransaction(
        method: method,
        amountPaid: amount,
        remain: total - (totalPaid + amount),
        finalAmountPaid: (totalPaid + amount) > total
            ? amount + (total - (totalPaid + amount))
            : (totalPaid + amount),
        date: date));
    debtAmount.value = totalFinal - totalPaid;
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

  // CRUD operations

  // Insert (Create)
  static Future<void> insert(Invoice invoice) async {
    try {
      await Supabase.instance.client.from('invoices').insert(invoice.toJson());
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Update
  Future<void> update() async {
    try {
      // debugPrint(toJson().toString());
      await Supabase.instance.client
          .from('invoices')
          .update(toJson())
          .eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Delete
  Future<void> delete() async {
    try {
      await Supabase.instance.client.from('invoices').delete().eq('id', id!);
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  // Fetch all invoices by storeId
  static Future<List<Invoice>> getAllByStoreId(String storeId) async {
    try {
      final response = await Supabase.instance.client
          .from('invoices')
          .select()
          .eq('store_id', storeId);

      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } on AuthException catch (e) {
      debugPrint(e.message);
      return [];
    }
  }

  // Real-time subscription to changes in the invoices table
  static Future<Stream<List<Invoice>>> subscribe(String storeId) async {
    return Supabase.instance.client
        .from('invoices')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .map((data) => data.map((json) => Invoice.fromJson(json)).toList());
  }
}
