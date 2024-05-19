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
  late List<ChartModel> invoiceChart = <ChartModel>[].obs;
  // late List<ChartModel> monthlyChart = <ChartModel>[].obs;
  final maxY = 0.obs;
  final isWeekly = true.obs;
  final isLoading = true.obs;
  DateTime today = DateTime.now();

  final totalInvoice = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    fetchData('week');
  }

  void fetchData(String rangeDate) {
    invoiceChart.clear();
    // monthlyChart.clear();
    Future.delayed(
      const Duration(milliseconds: 360),
      () {
        if (rangeDate == 'week') {
          isWeekly.value = true;
          // groupMonthlyInvoices();
          groupWeeklyInvoices();
        } else {
          isWeekly.value = false;
          groupMonthlyInvoices();
        }
        isLoading.value = false;
      },
    );
  }

  DateTime convertToLocal(DateTime utcTime) {
    return utcTime.add(const Duration(hours: 7));
  }

  void groupWeeklyInvoices() {
    const startingDay = DateTime.monday;
    final currentDay = DateTime.now().weekday;

    final offset = currentDay - startingDay;
    final adjustedStartingDay = DateTime.now().subtract(Duration(days: offset));

    filteredInvoices = invoiceList
        .where((invoice) =>
            convertToLocal(invoice.createdAt!).isAfter(adjustedStartingDay))
        .toList();
    getData(adjustedStartingDay);
  }

  void groupMonthlyInvoices() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    final startOfMonth = DateTime(currentYear, currentMonth, 1);
    final endOfMonth = DateTime(currentYear, currentMonth + 1, 0);

    filteredInvoices = invoiceList
        .where((invoice) =>
            convertToLocal(invoice.createdAt!)
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            convertToLocal(invoice.createdAt!)
                .isBefore(endOfMonth.add(const Duration(days: 1))))
        .toList();
    getData(null);
  }

  void getData(DateTime? adjustedStartingDay) {
    bool isWeekly = adjustedStartingDay != null;

    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    final formatter = DateFormat('dd/MM');

    void dateLooping(int i) {
      final currentDate = isWeekly
          ? adjustedStartingDay.add(Duration(days: i))
          : DateTime(currentYear, currentMonth, i);

      final invoices = filteredInvoices
          .where((invoice) =>
              convertToLocal(invoice.createdAt!).year == currentDate.year &&
              convertToLocal(invoice.createdAt!).month == currentDate.month &&
              convertToLocal(invoice.createdAt!).day == currentDate.day)
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
      invoiceChart.add(chartData);
    }

    if (isWeekly) {
      for (var i = 0; i < 7; i++) {
        dateLooping(i);
      }
    } else {
      for (var day = 0;
          day <= DateTime(currentYear, currentMonth + 1, 0).day;
          day++) {
        dateLooping(day);
      }
    }
    // debugPrint(monthlyChart.toString());
  }
}
