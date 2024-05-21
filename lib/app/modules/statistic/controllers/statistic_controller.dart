import 'package:date_picker_plus/date_picker_plus.dart';
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
  late ChartModel selectedData.obs;
  final maxY = 0.obs;
  // final clickSection = 'week'.obs;
  final isWeekly = true.obs;
  final isThisWeek = true.obs;
  final isLoading = true.obs;
  DateTime today = DateTime.now();

  final totalInvoice = 0.obs;
  final touchedGroupIndex = (-1).obs;
  final touchedDataIndex = (-1).obs;

  @override
  void onInit() async {
    super.onInit();
    fetchData('week');
  }

  void fetchData(String rangeDate) {
    maxY.value = 0;
    invoiceChart.clear();
    isLoading.value = true;
    Future.delayed(
      const Duration(milliseconds: 360),
      () {
        if (rangeDate == 'week') {
          isWeekly.value = true;
          groupWeeklyInvoices(selectedDate.value);
        } else if (rangeDate == 'month') {
          isWeekly.value = false;
          groupMonthlyInvoices();
        } else {
          isWeekly.value = false;
          // groupCustomInvoices();
        }
        isLoading.value = false;
      },
    );
  }

  DateTime convertToLocal(DateTime utcTime) {
    return utcTime.add(const Duration(hours: 7));
  }

  void groupWeeklyInvoices(DateTime? selectedDate) {
    if (isThisWeek.value) {
      final currentDay = today.weekday;
      final offset = currentDay - DateTime.monday;
      startOfWeek = today.subtract(Duration(days: offset));
    } else {
      final selectedDay = selectedDate!.weekday;
      final offset = selectedDay - DateTime.monday;
      startOfWeek = selectedDate.subtract(Duration(days: offset));
    }

    filteredInvoices = invoiceList
        .where((invoice) =>
            convertToLocal(invoice.createdAt!).isAfter(startOfWeek))
        .toList();

    getData(startOfWeek);
  }

  void groupMonthlyInvoices() {
    final currentMonth = today.month;
    final currentYear = today.year;

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

    final currentMonth = today.month;
    final currentYear = today.year;

    final formatter = DateFormat('dd/MM');

    void dateLooping(int i) {
      final currentDate = isWeekly
          ? adjustedStartingDay.add(Duration(days: i))
          : DateTime(currentYear, currentMonth, i + 1);

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
      final totalDaysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
      for (var day = 0; day < totalDaysInMonth; day++) {
        dateLooping(day);
      }
    }
  }

  void handleClickDate(String clickSection) async {
    if (clickSection == 'today' ||
        clickSection == 'yesterday' ||
        clickSection == 'lastWeek') {
      // isWeekly.value = true;
      // isThisWeek.value = true;

      selectedDate.value = DateTime.now();
      if (clickSection == 'yesterday') {
        selectedDate.value = DateTime.now().subtract(const Duration(days: 1));
      }

      fetchData('week');
    }

    // fetchData('month');
    // fetchData('year');
  }

  void compareData(DateTime date, String section) async {
    String dateString = '';
    int totalSellPrice = 0;
    int totalCostPrice = 0;
    int totalProfit = 0;
    int totalInvoice = 0;
    

    if (section == 'day') {
      totalSellPrice = invoiceChart
          .map((data) => data.totalSellPrice)
          .reduce((value, element) => value + element);

      totalCostPrice = invoiceChart
          .map((data) => data.totalCostPrice)
          .reduce((value, element) => value + element);

      totalProfit = invoiceChart
          .map((data) => data.totalCostPrice)
          .reduce((value, element) => value + element);
    }
    selectedData = ChartModel(
        dateString, totalSellPrice, totalCostPrice, totalProfit, totalInvoice);
  }

  //! dateTime
  final isDateTimeNow = false.obs;
  DateTime startOfWeek = DateTime.now();
  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final displayDate = DateTime.now().toString().obs;
  final displayTime = TimeOfDay.now().toString().obs;

  void handleDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePickerDialog(
      context: context,
      height: 400,
      width: 400,
      initialDate: selectedDate.value,
      selectedDate: selectedDate.value,
      minDate: DateTime(2000),
      maxDate: today,
      // locale: const Locale('id', 'ID'),
    );

    if (pickedDate != null) {
      selectedDate.value = pickedDate;
      displayDate.value = pickedDate.toString();

      isThisWeek.value = isDateInCurrentWeek(selectedDate.value);
      fetchData('week');
    }
  }

  bool isDateInCurrentWeek(DateTime date) {
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // void handleTime(BuildContext context) async {
  //   TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: selectedTime.value,
  //   );

  //   selectedTime.value = pickedTime ?? TimeOfDay.now();
  //   displayTime.value = pickedTime.toString();
  // }

  void dateTimeCheckBox() async {
    isDateTimeNow.value = !isDateTimeNow.value;
    if (!isDateTimeNow.value) {
      displayDate.value = '';
      displayTime.value = '';
    } else {
      displayDate.value = today.toString();
      displayTime.value = TimeOfDay.now().toString();
    }
    selectedDate.value = today;
    selectedTime.value = TimeOfDay.now();
  }
}
