class Chart {
  DateTime date;
  String dateString;
  int totalSellPrice;
  int totalCostPrice;
  int totalProfit;
  int totalPaid;
  int totalInvoice;

  Chart(
      {required this.date,
      required this.dateString,
      required this.totalSellPrice,
      required this.totalCostPrice,
      required this.totalProfit,
      required this.totalPaid,
      required this.totalInvoice});
}
