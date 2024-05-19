import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/invoice_model.dart';
import '../../../widget/model/chart_model.dart';
import '../../invoice/controllers/invoice_controller.dart';

class StatisticController extends GetxController {
  InvoiceController invoiceController = Get.put(InvoiceController());
  late final invoiceList = invoiceController.invoiceList;
  late List<Invoice> filteredInvoices = <Invoice>[].obs;
  late List<ChartModel> weekChart = <ChartModel>[].obs;
  final maxY = 0.obs;
  final isLoading = true.obs;
  DateTime today = DateTime.now();

  final totalInvoice = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    fetchData('week');
  }

  void fetchData(String rangeDate) {
    if (rangeDate == 'week') {
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          groupWeekInvoice();
          isLoading.value = false;
        },
      );
    }
  }

  void groupWeekInvoice() {
    DateTime monday = today.subtract(Duration(days: today.weekday - 1));
    DateTime thisWeek = monday.subtract(const Duration(days: 0));

    filteredInvoices = invoiceList
        .where((invoice) => invoice.createdAt!.isAfter(thisWeek))
        .toList();

    const startingDay = DateTime.monday;
    final currentDay = DateTime.now().weekday;

    final offset = currentDay - startingDay;
    final adjustedStartingDay = DateTime.now().subtract(Duration(days: offset));
    debugPrint(monday.toString());
    debugPrint(adjustedStartingDay.toString());
    getData(adjustedStartingDay);
  }

  void getData(DateTime adjustedStartingDay) {
    final formatter = DateFormat('dd/MM');
    for (var i = 0; i < 7; i++) {
      final currentDate = adjustedStartingDay.add(Duration(days: i));

      final invoices = filteredInvoices
          .where((invoice) =>
              invoice.createdAt!.year == currentDate.year &&
              invoice.createdAt!.month == currentDate.month &&
              invoice.createdAt!.day == currentDate.day)
          .toList();

      final dateString = formatter.format(currentDate);
      int totalSellPrice = 0;
      int totalCostPrice = 0;
      int totalProfit = 0;
      int totalInvoice = 0;

      if (invoices.isNotEmpty) {
        for (Invoice invoice in invoices) {
          totalCostPrice = invoice.productsCart!.cartList!
              .map((cart) => cart.product!.costPrice)
              .reduce((value, element) => value! + element!)!;

          totalSellPrice = invoice.productsCart!.cartList!
              .map((cart) => cart.product!.sellPrice)
              .reduce((value, element) => value! + element!)!;

          totalProfit += invoice.bill! - totalCostPrice;
        }
        totalInvoice = invoices.length;
      }
      if (maxY.value < totalProfit) {
        maxY.value = (totalProfit * 1.2).toInt();
      }

      final chartData = ChartModel(dateString, totalSellPrice, totalCostPrice,
          totalProfit, totalInvoice);
      weekChart.add(chartData);
    }
  }
}
