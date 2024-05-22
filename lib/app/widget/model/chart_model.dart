class ChartModel {
  final DateTime date;
  final String dateString;
  final int totalSellPrice;
  final int totalCostPrice;
  final int totalProfit;
  final int totalInvoice;

  ChartModel(this.date, this.dateString, this.totalSellPrice,
      this.totalCostPrice, this.totalProfit, this.totalInvoice);
}
