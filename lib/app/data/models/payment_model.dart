class PaymentTransaction {
  String? method;
  double amountPaid;
  double remain;
  double finalAmountPaid;
  DateTime? date;

  PaymentTransaction({
    this.method,
    this.amountPaid = 0,
    this.remain = 0,
    this.finalAmountPaid = 0,
    this.date,
  });

  PaymentTransaction.fromJson(Map<String, dynamic> json)
      : method = json['method'],
        amountPaid = json['amount_paid'].toDouble(),
        remain = json['remain'].toDouble(),
        finalAmountPaid = json['final_amount_paid'].toDouble(),
        date = DateTime.parse(json['date']).toLocal();

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['method'] = method;
    data['amount_paid'] = amountPaid;
    data['remain'] = remain;
    data['final_amount_paid'] = finalAmountPaid;
    data['date'] = date != null ? date!.toIso8601String() : DateTime.now();
    return data;
  }
}
