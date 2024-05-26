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
  final isMonthly = true.obs;
  final isYearly = true.obs;
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
    List<Invoice> newData = await InvoiceProvider.fetchData(uuid);
    invoiceList.assignAll(newData);
    await fetchData(DateTime.now(), 'weekly');
  }

  Future<void> fetchData(DateTime selectedDate, String section) async {
    maxY.value = 0;
    invoiceChart.clear();
    isLoading.value = true;
    isWeekly.value = false;
    isMonthly.value = false;
    isYearly.value = false;
    if (section == 'weekly') {
      isWeekly.value = true;
      invoiceChart = await groupWeeklyInvoices(selectedDate);
    } else if (section == 'monthly') {
      isMonthly.value = true;
      invoiceChart = await groupMonthlyInvoices(selectedDate);
    } else if (section == 'yearly') {
      isYearly.value = true;
      invoiceChart = await groupYearlyInvoices(selectedDate);
    }
    isLoading.value = false;
    compareData(selectedDate, section);
  }

//! Daily & Weekly ======================================================
  final dailyRangeController = DateRangePickerController().obs;
  final weeklyRangeController = DateRangePickerController().obs;
  final args = DateRangePickerSelectionChangedArgs(DateTime.now()).obs;

  void rangePickerHandle(DateRangePickerSelectionChangedArgs pickedDate) async {
    args.value = pickedDate;
    var selectedpickedDate = DateTime.now();
    var selectedPickerRange = PickerDateRange(DateTime.now(), null);

    if (pickedDate.value is DateTime) {
      selectedpickedDate = pickedDate.value;
    } else if (pickedDate.value is PickerDateRange) {
      selectedPickerRange = pickedDate.value;
      selectedpickedDate = selectedPickerRange.startDate!;
    }

    final DateTime startDate = await getStartofWeek(selectedpickedDate);

    final DateTime endDate = startDate.add(const Duration(days: 6));
    final newSelectedPickerRange = PickerDateRange(startDate, endDate);

    selectedWeeklyRange.value = newSelectedPickerRange;
    weeklyRangeController.value.selectedRange = newSelectedPickerRange;

    if (selectedPickerRange.endDate == null) {
      selectedDate.value = selectedpickedDate;
      dailyRangeController.value.selectedDate = selectedpickedDate;
      monthlyRangeController.value.selectedDate = selectedpickedDate;
      isLastIndex.value = selectedpickedDate.weekday == DateTime.monday;
      await fetchData(selectedpickedDate, 'weekly');
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
    args.value = pickedDate;
    var selectedpickedDate = DateTime.now();
    var selectedPickerRange = PickerDateRange(DateTime.now(), null);

    if (pickedDate.value is DateTime) {
      selectedpickedDate = pickedDate.value;
    } else if (pickedDate.value is PickerDateRange) {
      selectedPickerRange = pickedDate.value;
      selectedpickedDate = selectedPickerRange.startDate!;
    }
    selectedDate.value = selectedpickedDate;
    await fetchData(selectedpickedDate, 'monthly');
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

  void yearPickerHandle(DateRangePickerSelectionChangedArgs pickedDate) async {
    args.value = pickedDate;
    var selectedpickedDate = DateTime.now();
    var selectedPickerRange = PickerDateRange(DateTime.now(), null);

    if (pickedDate.value is DateTime) {
      selectedpickedDate = pickedDate.value;
    } else if (pickedDate.value is PickerDateRange) {
      selectedPickerRange = pickedDate.value;
      selectedpickedDate = selectedPickerRange.startDate!;
    }
    selectedDate.value = selectedpickedDate;
    await fetchData(selectedpickedDate, 'yearly');
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

    // var yearMonthlyData = <Chart>[];

    // const totalMonthInCurrentYear = 12;
    // for (var day = 0; day < totalMonthInCurrentYear; day++) {
    //   final getSelectedMonth = DateTime(currentYear, 1 + day);
    //   var data = await getChartData(getSelectedMonth, 'current');
    //   yearMonthlyData.addAll(data);
    // }

    currentYearInvoiceChart = await getChartData(startOfCurrentYear, 'current');

    // yearMonthlyData.clear;

    // final totalMonthInPrevYear = DateTime(prevYear).month;
    // for (var day = 0; day < totalMonthInPrevYear; day++) {
    //   yearMonthlyData.addAll(await getChartData(selectedDate, 'prev'));
    // }

    prevYearInvoiceChart = await getChartData(startOfPrevYear, 'current');
    ;
    return currentYearInvoiceChart;
  }

  Future<List<Chart>> getChartData(
      DateTime? selectedDate, String pastPresent) async {
    bool isCurrentSelected = pastPresent == 'current';
    final List<Chart> listChartData = [];

    final startingMonth = selectedDate!.month;
    final startingYear = selectedDate.year;

    final formatter = DateFormat('dd/MM');

    void dayValueLooping(int i) {
      final currentDate = isWeekly.value
          ? selectedDate.add(Duration(days: i))
          : isMonthly.value
              ? DateTime(startingYear, startingMonth, i + 1)
              : DateTime(startingYear, startingMonth + i);

      final invoices = isYearly.value
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
      debugPrint('$i ${chartData.totalInvoice}');

      listChartData.add(chartData);
    }

    if (isWeekly.value) {
      for (var day = 0; day < 7; day++) {
        dayValueLooping(day);
      }
    } else if (isMonthly.value) {
      final totalDaysInMonth = DateTime(startingYear, startingMonth + 1, 0).day;
      for (var day = 0; day < totalDaysInMonth; day++) {
        dayValueLooping(day);
      }
    } else if (isYearly.value) {
      for (var day = 0; day < 12; day++) {
        dayValueLooping(day);
      }
    }
    // listChartDataYearly.addAll(listChartData);
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
