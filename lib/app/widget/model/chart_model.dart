class ChartModel {
  DateTime date;
  String dateString;
  int totalSellPrice;
  int totalCostPrice;
  int totalProfit;
  int totalInvoice;

  ChartModel(
      {required this.date,
      required this.dateString,
      required this.totalSellPrice,
      required this.totalCostPrice,
      required this.totalProfit,
      required this.totalInvoice});
}
