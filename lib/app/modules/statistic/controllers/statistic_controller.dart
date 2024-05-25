import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../main.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/providers/invoice_provider.dart';
import '../../../widget/model/chart_model.dart';
import '../../invoice/controllers/invoice_controller.dart';

class StatisticController extends GetxController {
  InvoiceController invoiceController = Get.put(InvoiceController());
  late final String uuid;
  final formatter = NumberFormat('#,##0', 'id_ID');
  late final RxList<Invoice> invoiceList = RxList<Invoice>();
  final selectedSection = 'daily'.obs;

  late List<Invoice> currentAndPrevFilteredInvoices = <Invoice>[].obs;
  late List<Chart> invoiceChart = <Chart>[].obs;
  late List<Chart> currentWeekInvoiceChart = <Chart>[].obs;
  late List<Chart> prevWeekInvoiceChart = <Chart>[].obs;
  late List<Chart> currentMonthInvoiceChart = <Chart>[].obs;
  late List<Chart> prevMonthInvoiceChart = <Chart>[].obs;
  late List<Chart> currentYearInvoiceChart = <Chart>[].obs;
  late List<Chart> prevYearInvoiceChart = <Chart>[].obs;
  Rx<Chart?> selectedChartDay = Rx<Chart?>(null);
  Rx<Chart?> prevSelectedChartDay = Rx<Chart?>(null);
  final maxY = 0.obs;
  final isWeekly = true.obs;
  final isLastIndex = false.obs;
  final isLoading = true.obs;
  final initDate = DateTime.now().obs;
  DateTime today = DateTime.now();

  final touchedGroupIndex = (-1).obs;
  final touchedDataIndex = (-1).obs;

  @override
  void onInit() async {
    super.onInit();
    uuid = supabase.auth.currentUser!.id;
    List<Invoice> newData = await InvoiceProvider.fetchData(uuid);
    invoiceList.assignAll(newData);
    await fetchData(DateTime.now(), 'weekly');
  }

  Future<void> fetchData(DateTime selectedDate, String section) async {
    maxY.value = 0;
    invoiceChart.clear();
    isLoading.value = true;

    if (section == 'weekly') {
      isWeekly.value = true;
      invoiceChart = await groupWeeklyInvoices(selectedDate);
    } else if (section == 'month') {
      isWeekly.value = false;
      invoiceChart = await groupMonthlyInvoices(selectedDate);
      debugPrint(invoiceChart.toString());
    } else if (section == 'year') {
      // groupYearlyInvoices();
    } else {
      isWeekly.value = false;
      // groupCustomInvoices();
    }
    isLoading.value = false;
    compareData(selectedDate, section);
  }

//! Daily & Weekly ======================================================
  final dailyRangeController = DateRangePickerController().obs;
  final weeklyRangeController = DateRangePickerController().obs;

  void rangePickerHandle(DateRangePickerSelectionChangedArgs pickedDate) async {
    var selectedDate = DateTime.now();
    var selectedPickerRange = PickerDateRange(DateTime.now(), null);

    if (pickedDate.value is DateTime) {
      selectedDate = pickedDate.value;
    } else if (pickedDate.value is PickerDateRange) {
      selectedPickerRange = pickedDate.value;
      selectedDate = selectedPickerRange.startDate!;
    }

    final DateTime startDate = await getStartofWeek(selectedDate);

    final DateTime endDate = startDate.add(const Duration(days: 6));
    final newSelectedPickerRange = PickerDateRange(startDate, endDate);

    weeklyRangeController.value.selectedRange = newSelectedPickerRange;

    if (selectedPickerRange.endDate == null) {
      dailyRangeController.value.selectedDate = selectedDate;
      isLastIndex.value = selectedDate.weekday == DateTime.monday;
      await fetchData(selectedDate, 'weekly');
    }
  }

  final selectedWeeklyRange = PickerDateRange(
          DateTime.now(), DateTime.now().subtract(const Duration(days: 6)))
      .obs;

  Future<List<Chart>> groupWeeklyInvoices(DateTime selectedDate) async {
    DateTime prevWeekPickedDay = selectedDate.subtract(const Duration(days: 7));

    DateTime currentStartOfWeek = await getStartofWeek(selectedDate);
    DateTime prevStartOfWeek = await getStartofWeek(prevWeekPickedDay);

    currentAndPrevFilteredInvoices = invoiceList.where((invoice) {
      return convertToLocal(invoice.createdAt!).isAfter(prevWeekPickedDay);
    }).toList();

    selectedWeeklyRange.value = PickerDateRange(
        currentStartOfWeek, currentStartOfWeek.add(const Duration(days: 6)));
    currentWeekInvoiceChart = await getChartData(currentStartOfWeek, 'current');
    prevWeekInvoiceChart = await getChartData(prevStartOfWeek, 'prev');
    return currentWeekInvoiceChart;
  }

  Future<DateTime> getStartofWeek(DateTime selectedDate) async {
    final selectedDay = selectedDate.weekday;
    final offset = selectedDay - DateTime.monday;
    final startOfWeek = selectedDate.subtract(Duration(days: offset));

    return startOfWeek;
  }

//! Monthly ======================================================
  final monthlyRangeController = DateRangePickerController().obs;

  void monthPickerHandle(DateRangePickerSelectionChangedArgs pickedDate) async {
    await fetchData(pickedDate.value, 'monthly');
    debugPrint(invoiceChart.length.toString());
    // var selectedDate = DateTime.now();
    // var selectedPickerRange = PickerDateRange(DateTime.now(), null);

    // if (pickedDate.value is DateTime) {
    //   selectedDate = pickedDate.value;
    // } else if (pickedDate.value is PickerDateRange) {
    //   selectedPickerRange = pickedDate.value;
    //   selectedDate = selectedPickerRange.startDate!;
    // }

    // final DateTime startDate = await getStartofWeek(selectedDate);

    // final DateTime endDate = startDate.add(const Duration(days: 6));
    // final newSelectedPickerRange = PickerDateRange(startDate, endDate);

    // weeklyRangeController.value.selectedRange = newSelectedPickerRange;

    // if (selectedPickerRange.endDate == null) {
    //   dailyRangeController.value.selectedDate = selectedDate;
    //   isLastIndex.value = selectedDate.weekday == DateTime.monday;
    //   await fetchData(selectedDate, 'weekly');
    // }
  }
  // final selectedMonth = DateTime.now().month.obs;

  Future<List<Chart>> groupMonthlyInvoices(DateTime selectedDate) async {
    final currentMonth = selectedDate.month;
    final prevMonth = currentMonth - 1;
    final currentYear = selectedDate.year;

    final startOfMonth = DateTime(currentYear, prevMonth, 1);
    final endOfMonth = DateTime(currentYear, currentMonth + 1, 0);

    currentAndPrevFilteredInvoices = invoiceList.where((invoice) {
      return convertToLocal(invoice.createdAt!)
              .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          convertToLocal(invoice.createdAt!)
              .isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
    currentMonthInvoiceChart = await getChartData(selectedDate, 'current');
    prevMonthInvoiceChart = await getChartData(selectedDate, 'prev');
    return currentMonthInvoiceChart;
  }

  // void groupYearlyInvoices() {
  //   final currentMonth = today.month;
  //   final currentYear = today.year;

  //   final startOfMonth = DateTime(currentYear, currentMonth, 1);
  //   final endOfMonth = DateTime(currentYear, currentMonth + 1, 0);

  //   currentAndPrevFilteredInvoices = invoiceList.where((invoice) {
  //     return convertToLocal(invoice.createdAt!)
  //             .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
  //         convertToLocal(invoice.createdAt!)
  //             .isBefore(endOfMonth.add(const Duration(days: 1)));
  //   }).toList();
  //   getChartData(null, 'current');
  // }

  Future<List<Chart>> getChartData(
      DateTime? startingDate, String pastPresent) async {
    bool isCurrentSelected = pastPresent == 'current';
    final List<Chart> listChartData = [];

    final startingMonth = startingDate!.month;
    final startingYear = startingDate.year;

    final formatter = DateFormat('dd/MM');
    debugPrint(isWeekly.value.toString());
    void dayValueLooping(int i) {
      final currentDate = isWeekly.value
          ? startingDate.add(Duration(days: i))
          : DateTime(startingYear, startingMonth, i + 1);

      final invoices = currentAndPrevFilteredInvoices.where((invoice) {
        DateTime localDate = convertToLocal(invoice.createdAt!);
        return localDate.year == currentDate.year &&
            localDate.month == currentDate.month &&
            localDate.day == currentDate.day;
      }).toList();

      DateTime date = currentDate;
      final dateString = formatter.format(date);
      int totalSellPrice = 0;
      int totalCostPrice = 0;
      int totalProfit = 0;
      int totalInvoice = invoices.length;

      for (var invoice in invoices) {
        int sellPrice = invoice.productsCart!.cartList!
            .map((cart) => cart.product!.sellPrice)
            .reduce((value, element) => value! + element!)!;
        int costPrice = invoice.productsCart!.cartList!
            .map((cart) => cart.product!.costPrice)
            .reduce((value, element) => value! + element!)!;

        totalSellPrice += sellPrice;
        totalCostPrice += costPrice;
        totalProfit += invoice.bill! - costPrice;
      }

      if (maxY.value < totalProfit && isCurrentSelected) {
        maxY.value = (totalProfit * 1.4).toInt();
      }

      final chartData = Chart(
        date: date,
        dateString: dateString,
        totalSellPrice: totalSellPrice,
        totalCostPrice: totalCostPrice,
        totalProfit: totalProfit,
        totalInvoice: totalInvoice,
      );

      listChartData.add(chartData);
    }

    if (isWeekly.value) {
      for (var day = 0; day < 7; day++) {
        dayValueLooping(day);
      }
    } else {
      final totalDaysInMonth = DateTime(startingYear, startingMonth + 1, 0).day;
      for (var day = 0; day < totalDaysInMonth; day++) {
        dayValueLooping(day);
      }
    }
    return listChartData;
  }

  // void handleClickDay(DateTime day) async {
  //   fetchData(day, 'weekly');
  // }

  // void handleClickCustom(DateTime day, int totalDay) async {
  //   fetchData(day, 'weekly');
  // }

  void compareData(DateTime selectedDate, String section) async {
    bool isSameDate(DateTime date1, DateTime date2) {
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    }

    final dataInvoiceList = invoiceChart
        .where((invoice) => isSameDate(invoice.date, selectedDate))
        .toList();

    List<Chart> prevList = isLastIndex.value
        ? isWeekly.value
            ? prevWeekInvoiceChart
            : prevMonthInvoiceChart
        : invoiceChart;

    final prevDataInvoiceList = prevList
        .where((invoice) => isSameDate(
            invoice.date, selectedDate.subtract(const Duration(days: 1))))
        .toList();

    Chart reduceInvoiceList(List<Chart> dataInvoiceList, DateTime date) {
      return dataInvoiceList.reduce((value, element) {
        return Chart(
          date: date,
          dateString: DateFormat('EEEE, dd/MM', 'id').format(date),
          totalSellPrice: value.totalSellPrice + element.totalSellPrice,
          totalCostPrice: value.totalCostPrice + element.totalCostPrice,
          totalProfit: value.totalProfit + element.totalProfit,
          totalInvoice: value.totalInvoice + element.totalInvoice,
        );
      });
    }

    if (dataInvoiceList.isNotEmpty) {
      if (section == 'weekly') {
        selectedChartDay.value =
            reduceInvoiceList(dataInvoiceList, selectedDate);

        DateTime yesterday = selectedDate.subtract(const Duration(days: 1));

        prevSelectedChartDay.value =
            reduceInvoiceList(prevDataInvoiceList, yesterday);
      }
    }
  }

  Widget percentage(int value, int prevValue, BuildContext context) {
    double doubleValue = ((value - prevValue) / prevValue * 100);
    String formattedValue = doubleValue.toStringAsFixed(2);

    if (prevValue == 0 || doubleValue == 0) {
      return Text('0%',
          style: context.textTheme.bodySmall!.copyWith(
            fontSize: 11,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ));
    }
    // Hapus .00 jika ada
    if (formattedValue.endsWith('.00')) {
      formattedValue = formattedValue.substring(0, formattedValue.length - 3);
    }

    String sign = doubleValue >= 0 ? "+" : "";
    Color color = doubleValue >= 0 ? Colors.green : Colors.red;

    return Text('$sign$formattedValue%',
        style: context.textTheme.bodySmall!.copyWith(
          fontSize: 11,
          color: color,
          fontStyle: FontStyle.italic,
        ));
  }

  //! dateTime
  final isDateTimeNow = false.obs;
  final selectedTime = TimeOfDay.now().obs;
  final displayDate = DateTime.now().toString().obs;
  final displayTime = TimeOfDay.now().toString().obs;

  DateTime convertToLocal(DateTime utcTime) {
    return utcTime.add(const Duration(hours: 7));
  }
}
