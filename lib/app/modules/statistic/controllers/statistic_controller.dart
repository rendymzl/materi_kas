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
  final isDaily = true.obs;
  final selectedSection = 'daily'.obs;

  late List<Invoice> currentAndPrevFilteredInvoices = <Invoice>[].obs;
  late List<Chart> invoiceChart = <Chart>[].obs;
  late List<Chart> currentWeekInvoiceChart = <Chart>[].obs;
  late List<Chart> prevWeekInvoiceChart = <Chart>[].obs;
  late List<Chart> currentMonthInvoiceChart = <Chart>[].obs;
  late List<Chart> prevMonthInvoiceChart = <Chart>[].obs;
  late List<Chart> currentYearInvoiceChart = <Chart>[].obs;
  late List<Chart> prevYearInvoiceChart = <Chart>[].obs;
  Rx<Chart?> selectedChart = Rx<Chart?>(
    Chart(
        date: DateTime.now(),
        dateString: 'dateString',
        totalSellPrice: 0,
        totalCostPrice: 0,
        totalProfit: 0,
        totalInvoice: 0),
  );
  Rx<Chart?> prevSelectedChart = Rx<Chart?>(
    Chart(
        date: DateTime.now(),
        dateString: 'dateString',
        totalSellPrice: 0,
        totalCostPrice: 0,
        totalProfit: 0,
        totalInvoice: 0),
  );
  final maxY = 0.obs;
  int maxTotalInvoice = 0;
  int scale = 20000;
  final groupDate = ''.obs;
  final dailyData = true;
  final isLastIndex = false.obs;
  final isLoading = true.obs;
  final initDate = DateTime.now().obs;
  final selectedDate = DateTime.now().obs;
  DateTime today = DateTime.now();

  final touchedGroupIndex = (-1).obs;
  final touchedDataIndex = (-1).obs;

  @override
  void onInit() async {
    super.onInit();
    uuid = supabase.auth.currentUser!.id;
    List<Invoice> newData = await InvoiceProvider.fetchData(uuid, null);
    invoiceList.assignAll(newData);
    await fetchData(DateTime.now(), 'weekly');
  }

  Future<void> fetchData(DateTime selectedDate, String section) async {
    maxY.value = 0;
    invoiceChart.clear();
    groupDate.value = section;

    switch (section) {
      case 'weekly':
        invoiceChart = await groupWeeklyInvoices(selectedDate);
        break;
      case 'monthly':
        invoiceChart = await groupMonthlyInvoices(selectedDate);
        break;
      case 'yearly':
        invoiceChart = await groupYearlyInvoices(selectedDate);
        break;
    }
    await compareData(selectedDate, selectedSection.value);
    isLoading.value = false;
  }

//! Daily & Weekly ======================================================
  final dailyRangeController = DateRangePickerController().obs;
  final weeklyRangeController = DateRangePickerController().obs;
  final args = DateTime.now().obs;

  void rangePickerHandle(DateTime pickedDate) async {
    args.value = pickedDate;

    final DateTime startDate = await getStartofWeek(pickedDate);

    final DateTime endDate = startDate.add(const Duration(days: 6));
    final newSelectedPickerRange = PickerDateRange(startDate, endDate);

    selectedWeeklyRange.value = newSelectedPickerRange;
    weeklyRangeController.value.selectedRange = newSelectedPickerRange;

    selectedDate.value = pickedDate;
    dailyRangeController.value.selectedDate = pickedDate;
    monthlyRangeController.value.selectedDate = pickedDate;
    yearlyRangeController.value.selectedDate = pickedDate;
    await fetchData(pickedDate, 'weekly');
  }

  final selectedWeeklyRange = PickerDateRange(
          DateTime.now(), DateTime.now().subtract(const Duration(days: 6)))
      .obs;

  Future<List<Chart>> groupWeeklyInvoices(DateTime selectedDate) async {
    isLastIndex.value = selectedDate.weekday == DateTime.monday;

    DateTime prevWeekPickedDay = selectedDate.subtract(const Duration(days: 7));

    DateTime currentStartOfWeek = await getStartofWeek(selectedDate);
    DateTime prevStartOfWeek = await getStartofWeek(prevWeekPickedDay);

    currentAndPrevFilteredInvoices = invoiceList.where((invoice) {
      return convertToLocal(invoice.createdAt!).isAfter(prevStartOfWeek);
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

  void monthPickerHandle(DateTime pickedDate) async {
    args.value = pickedDate;

    selectedDate.value = pickedDate;
    dailyRangeController.value.selectedDate = pickedDate;
    monthlyRangeController.value.selectedDate = pickedDate;
    yearlyRangeController.value.selectedDate = pickedDate;
    await fetchData(pickedDate, 'monthly');
  }

  Future<List<Chart>> groupMonthlyInvoices(DateTime selectedDate) async {
    final currentMonth = selectedDate.month;
    final prevMonth = currentMonth - 1;
    final currentYear = selectedDate.year;

    final startOfCurrentMonth = DateTime(currentYear, currentMonth, 1);
    final startOfPrevMonth = DateTime(currentYear, prevMonth, 1);
    final endOfMonth = DateTime(currentYear, currentMonth + 1, 0);

    currentAndPrevFilteredInvoices = invoiceList.where((invoice) {
      return convertToLocal(invoice.createdAt!)
              .isAfter(startOfPrevMonth.subtract(const Duration(days: 1))) &&
          convertToLocal(invoice.createdAt!)
              .isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    currentMonthInvoiceChart =
        await getChartData(startOfCurrentMonth, 'current');
    prevMonthInvoiceChart = await getChartData(startOfPrevMonth, 'prev');
    return currentMonthInvoiceChart;
  }

//! Yearly ======================================================
  final yearlyRangeController = DateRangePickerController().obs;

  void yearPickerHandle(DateTime pickedDate) async {
    args.value = pickedDate;

    selectedDate.value = pickedDate;
    dailyRangeController.value.selectedDate = pickedDate;
    monthlyRangeController.value.selectedDate = pickedDate;
    yearlyRangeController.value.selectedDate = pickedDate;
    await fetchData(pickedDate, 'yearly');
  }

  Future<List<Chart>> groupYearlyInvoices(DateTime selectedDate) async {
    final currentYear = selectedDate.year;
    final prevYear = selectedDate.year - 1;

    final startOfCurrentYear = DateTime(currentYear, 1);
    final startOfPrevYear = DateTime(prevYear, 1);
    final endOfYear = DateTime(currentYear, 12);

    currentAndPrevFilteredInvoices = invoiceList.where((invoice) {
      return convertToLocal(invoice.createdAt!)
              .isAfter(startOfPrevYear.subtract(const Duration(days: 1))) &&
          convertToLocal(invoice.createdAt!)
              .isBefore(endOfYear.add(const Duration(days: 1)));
    }).toList();

    currentYearInvoiceChart = await getChartData(startOfCurrentYear, 'current');

    prevYearInvoiceChart = await getChartData(startOfPrevYear, 'current');

    return currentYearInvoiceChart;
  }

  Future<List<Chart>> getChartData(
      DateTime? selectedDate, String pastPresent) async {
    bool isCurrentSelected = pastPresent == 'current';
    final List<Chart> listChartData = [];

    final startingMonth = selectedDate!.month;
    final startingYear = selectedDate.year;

    final formatter = DateFormat('EEEE, dd/MM', 'id');

    void dayValueLooping(int i) {
      final currentDate = groupDate.value == 'weekly'
          ? selectedDate.add(Duration(days: i))
          : groupDate.value == 'monthly'
              ? DateTime(startingYear, startingMonth, i + 1)
              : DateTime(startingYear, startingMonth + i);

      final invoices = groupDate.value == 'yearly'
          ? currentAndPrevFilteredInvoices.where((invoice) {
              DateTime localDate = convertToLocal(invoice.createdAt!);
              return localDate.year == currentDate.year &&
                  localDate.month == currentDate.month;
            }).toList()
          : currentAndPrevFilteredInvoices.where((invoice) {
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
        int sellPrice = invoice.productsCart!.cartList!.map((cart) {
          return (cart.product!.sellPrice! * cart.quantity!);
        }).reduce((value, element) => value + element);
        int costPrice = invoice.productsCart!.cartList!.map((cart) {
          return (cart.product!.costPrice! * cart.quantity!);
        }).reduce((value, element) => value + element);

        totalSellPrice += sellPrice;
        totalCostPrice += costPrice;
        totalProfit += invoice.bill! - costPrice;
      }

      if (maxY.value < totalProfit && isCurrentSelected) {
        maxY.value = (totalProfit * 1.4).toInt();
      }

      if (maxTotalInvoice < totalInvoice && isCurrentSelected) {
        maxTotalInvoice = (totalInvoice * 1.4).toInt();
      }

      scale = (maxY.value * maxTotalInvoice) ~/ maxTotalInvoice;

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

    if (groupDate.value == 'weekly') {
      for (var day = 0; day < 7; day++) {
        dayValueLooping(day);
      }
    } else if (groupDate.value == 'monthly') {
      final totalDaysInMonth = DateTime(startingYear, startingMonth + 1, 0).day;
      for (var day = 0; day < totalDaysInMonth; day++) {
        dayValueLooping(day);
      }
    } else if (groupDate.value == 'yearly') {
      for (var day = 0; day < 12; day++) {
        dayValueLooping(day);
      }
    }
    return listChartData;
  }

  Future<void> compareData(DateTime selectedDate, String period) async {
    bool isSamePeriod(DateTime date1, DateTime date2, String period) {
      DateTime start1, end1, start2, end2;
      switch (period) {
        case 'daily':
          start1 = DateTime(date1.year, date1.month, date1.day);
          end1 = start1;
          start2 = DateTime(date2.year, date2.month, date2.day);
          end2 = start2;
          break;
        case 'weekly':
          start1 = date1.subtract(Duration(days: date1.weekday - 1));
          end1 = start1.add(const Duration(days: 6));
          start2 = date2.subtract(Duration(days: date2.weekday - 1));
          end2 = start2.add(const Duration(days: 6));
          break;
        case 'monthly':
          start1 = DateTime(date1.year, date1.month, 1);
          end1 = DateTime(date1.year, date1.month + 1, 0);
          start2 = DateTime(date2.year, date2.month, 1);
          end2 = DateTime(date2.year, date2.month + 1, 0);
          break;
        case 'yearly':
          start1 = DateTime(date1.year, 1, 1);
          end1 = DateTime(date1.year + 1, 1, 0);
          start2 = DateTime(date2.year, 1, 1);
          end2 = DateTime(date2.year + 1, 1, 0);
          break;
        default:
          return false;
      }

      return start1.isAtSameMomentAs(start2) && end1.isAtSameMomentAs(end2);
    }

    DateFormat formatter;
    switch (period) {
      case 'daily':
        formatter = DateFormat('EEEE, dd/MM', 'id');
        break;
      case 'weekly':
        formatter = DateFormat('EEE, dd/MM', 'id');
        break;
      case 'monthly':
        formatter = DateFormat('MMM y', 'id');
        break;
      default:
        formatter = DateFormat('y', 'id');
        break;
    }

    Future<Chart> reduceInvoiceList(
        List<Chart> dataInvoiceList, DateTime date) async {
      return dataInvoiceList.reduce((value, element) {
        return Chart(
          date: date,
          dateString: selectedSection.value != 'weekly'
              ? formatter.format(date)
              : '${formatter.format(dataInvoiceList[0].date)} - ${formatter.format(dataInvoiceList[6].date)}',
          totalSellPrice: value.totalSellPrice + element.totalSellPrice,
          totalCostPrice: value.totalCostPrice + element.totalCostPrice,
          totalProfit: value.totalProfit + element.totalProfit,
          totalInvoice: value.totalInvoice + element.totalInvoice,
        );
      });
    }

    final dataInvoiceList = invoiceChart
        .where((invoice) => isSamePeriod(invoice.date, selectedDate, period))
        .toList();

    selectedChart.value =
        await reduceInvoiceList(dataInvoiceList, selectedDate);

    List<Chart> prevList = isLastIndex.value
        ? groupDate.value == 'weekly'
            ? prevWeekInvoiceChart
            : prevMonthInvoiceChart
        : invoiceChart;

    if (dataInvoiceList.isNotEmpty) {
      DateTime prevPeriod;
      switch (period) {
        case 'daily':
          prevPeriod = selectedDate.subtract(const Duration(days: 1));
          final prevDayInvoiceList = prevList
              .where(
                  (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
              .toList();
          prevSelectedChart.value =
              await reduceInvoiceList(prevDayInvoiceList, prevPeriod);
          break;
        case 'weekly':
          prevPeriod = selectedDate.subtract(const Duration(days: 7));
          final prevWeekInvoiceList = prevWeekInvoiceChart
              .where(
                  (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
              .toList();
          prevSelectedChart.value =
              await reduceInvoiceList(prevWeekInvoiceList, prevPeriod);
          break;
        case 'monthly':
          prevPeriod = DateTime(selectedDate.year, selectedDate.month - 1);
          final prevMonthInvoiceList = prevMonthInvoiceChart
              .where(
                  (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
              .toList();
          prevSelectedChart.value =
              await reduceInvoiceList(prevMonthInvoiceList, prevPeriod);
          break;
        case 'yearly':
          prevPeriod = DateTime(selectedDate.year - 1);
          final prevYearInvoiceList = prevYearInvoiceChart
              .where(
                  (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
              .toList();
          prevSelectedChart.value =
              await reduceInvoiceList(prevYearInvoiceList, prevPeriod);
          break;
        default:
          return;
      }
    }
  }

  Widget percentage(int value, int prevValue, BuildContext context) {
    double doubleValue = ((value - prevValue) / prevValue * 100);
    String formattedValue = doubleValue.toStringAsFixed(2);

    if (prevValue == 0 || doubleValue == 0) {
      return Text('(0%)',
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

    return Text('($sign$formattedValue%)',
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
