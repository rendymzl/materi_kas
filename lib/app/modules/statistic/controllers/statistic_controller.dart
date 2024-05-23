import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  late List<Invoice> selectedFilteredInvoices = <Invoice>[].obs;
  late List<ChartModel> invoiceChart = <ChartModel>[].obs;
  late List<ChartModel> selectedWeekInvoiceChart = <ChartModel>[].obs;
  late List<ChartModel> prevWeekInvoiceChart = <ChartModel>[].obs;
  late List<ChartModel> selectedMonthInvoiceChart = <ChartModel>[].obs;
  late List<ChartModel> prevMonthInvoiceChart = <ChartModel>[].obs;
  late List<ChartModel> selectedYearInvoiceChart = <ChartModel>[].obs;
  late List<ChartModel> prevYearInvoiceChart = <ChartModel>[].obs;
  Rx<ChartModel?> selectedDay = Rx<ChartModel?>(null);
  Rx<ChartModel?> prevSelectedDay = Rx<ChartModel?>(null);
  final maxY = 0.obs;
  final isWeekly = true.obs;
  final isLastIndex = false.obs;
  // final isThisWeek = true.obs;
  final isLoading = true.obs;
  DateTime today = DateTime.now();

  final totalInvoice = 0.obs;
  final touchedGroupIndex = (-1).obs;
  final touchedDataIndex = (-1).obs;

  @override
  void onInit() async {
    super.onInit();
    uuid = supabase.auth.currentUser!.id;
    List<Invoice> newData = await InvoiceProvider.fetchData(uuid);
    invoiceList.assignAll(newData);
    fetchData('weekly', selectedDate.value);
  }

  void fetchData(String section, DateTime day) {
    maxY.value = 0;
    invoiceChart.clear();
    isLoading.value = true;

    if (section == 'weekly') {
      isWeekly.value = true;
      groupWeeklyInvoices(day);
    } else if (section == 'month') {
      isWeekly.value = false;
      groupMonthlyInvoices();
    } else if (section == 'month') {
      groupYearlyInvoices();
    } else {
      isWeekly.value = false;
      // groupCustomInvoices();
    }
    isLoading.value = false;
    compareData(section);
  }

  DateTime convertToLocal(DateTime utcTime) {
    return utcTime.add(const Duration(hours: 7));
  }

  void groupWeeklyInvoices(DateTime pickedDay) {
    DateTime prevWeekPickedDay = pickedDay.subtract(const Duration(days: 7));

    for (var day = 0; day < 2; day++) {
      final selectedDay =
          day == 0 ? pickedDay.weekday : prevWeekPickedDay.weekday;
      final offset = selectedDay - DateTime.monday;
      DateTime startOfWeek = day == 0
          ? pickedDay.subtract(Duration(days: offset))
          : prevWeekPickedDay.subtract(Duration(days: offset));

      selectedFilteredInvoices = invoiceList.where((invoice) {
        return convertToLocal(invoice.createdAt!).isAfter(startOfWeek);
      }).toList();
      getData(startOfWeek, day == 0);
    }
    invoiceChart = selectedWeekInvoiceChart;
  }

  void groupMonthlyInvoices() {
    final currentMonth = today.month;
    final currentYear = today.year;

    final startOfMonth = DateTime(currentYear, currentMonth, 1);
    final endOfMonth = DateTime(currentYear, currentMonth + 1, 0);

    selectedFilteredInvoices = invoiceList.where((invoice) {
      return convertToLocal(invoice.createdAt!)
              .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          convertToLocal(invoice.createdAt!)
              .isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
    getData(null, true);
  }

  void groupYearlyInvoices() {
    final currentMonth = today.month;
    final currentYear = today.year;

    final startOfMonth = DateTime(currentYear, currentMonth, 1);
    final endOfMonth = DateTime(currentYear, currentMonth + 1, 0);

    selectedFilteredInvoices = invoiceList.where((invoice) {
      return convertToLocal(invoice.createdAt!)
              .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          convertToLocal(invoice.createdAt!)
              .isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
    getData(null, true);
  }

  void getData(DateTime? adjustedStartingDay, bool isSelectedDate) {
    bool isWeekly = adjustedStartingDay != null;

    final currentMonth = today.month;
    final currentYear = today.year;

    final formatter = DateFormat('dd/MM');

    void dayValueLooping(int i) {
      final currentDate = isWeekly
          ? adjustedStartingDay.add(Duration(days: i))
          : DateTime(currentYear, currentMonth, i + 1);

      final invoices = selectedFilteredInvoices.where((invoice) {
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

      if (maxY.value < totalProfit && isSelectedDate) {
        maxY.value = (totalProfit * 1.4).toInt();
      }

      final chartData = ChartModel(
        date: date,
        dateString: dateString,
        totalSellPrice: totalSellPrice,
        totalCostPrice: totalCostPrice,
        totalProfit: totalProfit,
        totalInvoice: totalInvoice,
      );

      // invoiceChart.add(chartData);

      isWeekly
          ? isSelectedDate
              ? selectedWeekInvoiceChart.add(chartData)
              : prevWeekInvoiceChart.add(chartData)
          : isSelectedDate
              ? selectedMonthInvoiceChart.add(chartData)
              : prevMonthInvoiceChart.add(chartData);
    }

    if (isWeekly) {
      for (var day = 0; day < 7; day++) {
        dayValueLooping(day);
      }
    } else {
      final totalDaysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
      for (var day = 0; day < totalDaysInMonth; day++) {
        dayValueLooping(day);
      }
    }
  }

  void handleClickDay(DateTime day) async {
    fetchData('week', day);
  }

  void handleClickCustom(DateTime day, int totalDay) async {
    fetchData('week', day);
  }

  void compareData(String section) async {
    bool isSameDate(DateTime date1, DateTime date2) {
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    }

    final dataInvoiceList = invoiceChart
        .where((invoice) => isSameDate(invoice.date, selectedDate.value))
        .toList();

    List<ChartModel> prevList = isLastIndex.value
        ? isWeekly.value
            ? prevWeekInvoiceChart
            : prevMonthInvoiceChart
        : invoiceChart;

    final prevDataInvoiceList = prevList
        .where((invoice) => isSameDate(
            invoice.date, selectedDate.value.subtract(const Duration(days: 1))))
        .toList();

    ChartModel reduceInvoiceList(
        List<ChartModel> dataInvoiceList, DateTime date) {
      return dataInvoiceList.reduce((value, element) {
        return ChartModel(
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
        selectedDay.value =
            reduceInvoiceList(dataInvoiceList, selectedDate.value);

        DateTime yesterday =
            selectedDate.value.subtract(const Duration(days: 1));

        prevSelectedDay.value =
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
  // DateTime startOfWeek = DateTime.now();
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
      initialPickerType: PickerType.years,
      // locale: const Locale('id', 'ID'),
    );

    if (pickedDate != null) {
      selectedDate.value = pickedDate;
      displayDate.value = pickedDate.toString();
      // isThisWeek.value = isDateInCurrentWeek(selectedDate.value);
      isLastIndex.value = pickedDate.weekday == DateTime.monday;
      fetchData('week', pickedDate);
    }
  }

  void handleGroupDate(BuildContext context) async {
    DateTimeRange? pickedDateRange = await showRangePickerDialog(
      context: context,
      height: 400,
      width: 400,
      initialDate: selectedDate.value,
      // selectedRange: DateTimeRange(start: DateTime(2022), end: DateTime(2023)),
      minDate: DateTime(2000),
      maxDate: today,
    );
    debugPrint(pickedDateRange?.start.toString());
    debugPrint(pickedDateRange?.end.toString());
    // if (pickedDate != null) {
    //   selectedDate.value = pickedDate;
    //   displayDate.value = pickedDate.toString();
    //   isLastIndex.value = pickedDate.weekday == DateTime.monday;
    //   fetchData('week', pickedDate);
    // }
  }

  // bool isDateInCurrentWeek(DateTime date) {
  //   DateTime startOfWeek = today.subtract(Duration(days: today.weekday));
  //   DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

  //   return date.isAfter(startOfWeek) &&
  //       date.isBefore(endOfWeek.add(const Duration(days: 1)));
  // }

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
