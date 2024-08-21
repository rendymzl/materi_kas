// import 'package:date_picker_plus/date_picker_plus.dart';
// import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../../data/models/invoice_model.dart';
import '../../../../main.dart';
import '../../../widget/model/chart_model.dart';
import '../../../widget/properties_row_widget.dart';
import '../../../widget/side_menu_widget.dart';
import '../controllers/statistic_controller.dart';
import 'add_operating_cost_dialog.dart';

class StatisticView extends GetView<StatisticController> {
  const StatisticView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const SideMenuWidget(title: 'Laporan'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: const SizedBox(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SideMenuWidget(),
              Expanded(child: Center(child: BarChartWidget())),
            ],
          ),
        ),
      ),
    );
  }
}

class BarChartWidget extends GetView<StatisticController> {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Obx(
            () {
              final selectedChart = controller.selectedChart.value!;
              final prevSelectedChart = controller.prevSelectedChart.value!;

              final date = selectedChart.dateString;
              final prevDate = prevSelectedChart.dateString;

              final sell = selectedChart.totalSellPrice;
              final prevSell = prevSelectedChart.totalSellPrice;

              final returnPrice = selectedChart.totalReturn;
              final prevReturnPrice = prevSelectedChart.totalReturn;

              final totalReturnFee = selectedChart.totalChargeReturn;
              final prevTotalReturnFee = prevSelectedChart.totalChargeReturn;

              final discount = selectedChart.totalDiscount;
              final prevDiscount = prevSelectedChart.totalDiscount;

              final cash = selectedChart.cash;
              final prevCash = prevSelectedChart.cash;

              final transfer = selectedChart.transfer;
              final prevTransfer = prevSelectedChart.transfer;

              final salesCash = selectedChart.salesCash;
              final prevSalesCash = prevSelectedChart.salesCash;

              final salesTransfer = selectedChart.salesTransfer;
              final prevSalesTransfer = prevSelectedChart.salesTransfer;

              final cost = selectedChart.totalCostPrice;
              final prevCost = prevSelectedChart.totalCostPrice;

              final totaplOperatingCost = selectedChart.operatingCost;
              final prevTotalOperatingCost = prevSelectedChart.operatingCost;

              final totalInvoice = selectedChart.totalInvoice;
              final prevTotalInvoice = prevSelectedChart.totalInvoice;

              final pay = selectedChart.totalPay;
              final prevPay = prevSelectedChart.totalPay;

              final salesPay = selectedChart.totalSalesPay;
              final prevSalesPay = prevSelectedChart.totalSalesPay;

              final grossProfit = selectedChart.grossProfit;
              final prevGrossProfit = prevSelectedChart.grossProfit;

              final cleanProfit = selectedChart.cleanProfit;
              final prevCleanProfit = prevSelectedChart.cleanProfit;

              final debt = selectedChart.totalDebt;
              final prevDebt = prevSelectedChart.totalDebt;

              return controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                            flex: 7,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(date),
                                        const SizedBox(width: 12),
                                        Text('Total Invoice: $totalInvoice'),
                                        // Container(
                                        //   height: 42,
                                        //   width: 42,
                                        //   decoration: BoxDecoration(
                                        //       color: Theme.of(context)
                                        //           .colorScheme
                                        //           .primary,
                                        //       borderRadius:
                                        //           const BorderRadius.all(
                                        //               Radius.circular(5))),
                                        //   child: IconButton(
                                        //     onPressed: () {},
                                        //     icon: const Icon(
                                        //       Symbols.bar_chart,
                                        //       // size: 24,
                                        //       color: Colors.white,
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    PropertiesRowWidget(
                                      title: 'SubTotal Penjualan',
                                      value: currency.format(sell),
                                      primary: true,
                                    ),
                                    PropertiesRowWidget(
                                      title: 'Total Harga Modal',
                                      value: currency.format(cost * -1),
                                      color: Colors.red,
                                    ),
                                    Divider(color: Colors.grey[400]),
                                    PropertiesRowWidget(
                                      title: 'Laba Kotor',
                                      value: currency.format(sell - cost),
                                      primary: true,
                                    ),
                                    // PropertiesRowWidget(
                                    //   title: 'Total Harga Modal',
                                    //   value: currency.format(cost * -1),
                                    //   color: Colors.red,
                                    // ),
                                    PropertiesRowWidget(
                                      title: 'Biaya Operasional',
                                      value: currency
                                          .format(totaplOperatingCost * -1),
                                      color: Colors.red,
                                    ),
                                    PropertiesRowWidget(
                                      title: 'Total Diskon',
                                      value: '-${currency.format(discount)}',
                                      color: Colors.red,
                                    ),
                                    PropertiesRowWidget(
                                      title: 'Total Cas Retur',
                                      value: currency.format(totalReturnFee),
                                      color: Colors.green,
                                    ),
                                    Divider(color: Colors.grey[400]),
                                    PropertiesRowWidget(
                                      title: 'Laba Bersih',
                                      value: currency.format(cleanProfit),
                                      primary: true,
                                    ),
                                    const SizedBox(height: 60),
                                    Divider(
                                        color: Colors.grey[400], thickness: 3),
                                    const Text(
                                      'MUTASI',
                                      textAlign: TextAlign.center,
                                    ),
                                    Divider(
                                        color: Colors.grey[400], thickness: 3),
                                    PropertiesRowWidget(
                                      title: 'Total Penjualan',
                                      value: currency.format(sell),
                                      subValue: '',
                                      primary: true,
                                    ),
                                    const PropertiesPayWidget(
                                      title: '',
                                    ),
                                    PropertiesPayWidget(
                                      title: 'Pembayaran Pelanggan',
                                      cash: 'Rp${currency.format(cash)}',
                                      transfer:
                                          'Rp${currency.format(transfer)}',
                                      total: 'Rp${currency.format(pay)}',
                                      color: Colors.green,
                                    ),
                                    PropertiesPayWidget(
                                      title: 'Pembayaran Sales',
                                      cash: 'Rp-${currency.format(salesCash)}',
                                      transfer:
                                          'Rp-${currency.format(salesTransfer)}',
                                      // total: 'Rp-${currency.format(salesPay)}',
                                      color: Colors.red,
                                    ),
                                    PropertiesPayWidget(
                                      title: 'Total Cas Retur',
                                      cash:
                                          'Rp${currency.format(totalReturnFee)}',
                                      transfer: '-',
                                      // total: 'Rp-${currency.format(salesPay)}',
                                      color: Colors.green,
                                    ),
                                    PropertiesPayWidget(
                                      title: 'Total Retur',
                                      cash:
                                          'Rp-${currency.format(returnPrice)}',
                                      transfer: '-',
                                      // total: 'Rp-${currency.format(salesPay)}',
                                      color: Colors.red,
                                    ),
                                    PropertiesPayWidget(
                                      title: 'Biaya Operasional',
                                      cash:
                                          'Rp-${currency.format(totaplOperatingCost)}',
                                      transfer: '-',
                                      // total: 'Rp-${currency.format(salesPay)}',
                                      color: Colors.red,
                                    ),
                                    PropertiesPayWidget(
                                      title: 'Sisa Bayar',
                                      cash:
                                          'Rp${currency.format(cash - salesCash - returnPrice + totalReturnFee - totaplOperatingCost)}',
                                      transfer:
                                          'Rp${currency.format(transfer - salesTransfer)}',
                                      // total: 'Rp${currency.format(debt)}',
                                    ),
                                    Divider(color: Colors.grey[400]),
                                    PropertiesRowWidget(
                                      title: 'Total Belum Bayar',
                                      value: currency.format(debt),
                                      primary: true,
                                    ),
                                    Divider(
                                        color: Colors.grey[400], thickness: 3),
                                    const SizedBox(height: 12),
                                    // PropertiesRowWidget(
                                    //   title: 'Total Retur',
                                    //   value: '-${currency.format(returnPrice)}',
                                    //   color: Colors.red,
                                    // ),
                                  ],
                                ),
                              ),
                            )
                            // BarChartDialog(barTouchData: barTouchData, titlesData: titlesData, borderData: borderData, barGroups: barGroups, controller: controller, date: date, prevDate: prevDate, sell: sell, prevSell: prevSell, profit: profit, prevProfit: prevProfit, pay: pay, prevPay: prevPay, totalInvoice: totalInvoice, prevTotalInvoice: prevTotalInvoice),
                            ),
                        if (controller.selectedSection.value == 'daily')
                          Expanded(
                              flex: 3,
                              child: Card(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox(
                                          height: 40,
                                          child: Text('Biaya Operasional')),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: controller
                                              .dailyOperatingCosts.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            var operatingCost = controller
                                                .dailyOperatingCosts[index];
                                            return ListTile(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(operatingCost.name!),
                                                  Text(
                                                      'Rp${currency.format(operatingCost.amount!)}')
                                                ],
                                              ),
                                              subtitle: Text(
                                                operatingCost.note!,
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              leading: IconButton(
                                                onPressed: () async =>
                                                    await Get.defaultDialog(
                                                  title: 'Hapus',
                                                  middleText: 'Hapus Biaya?',
                                                  confirm: TextButton(
                                                    onPressed: () async {
                                                      controller
                                                          .deleteOperatingCost(
                                                              operatingCost);
                                                      // controller
                                                      //     .rangePickerHandle(
                                                      //         controller
                                                      //             .args.value);
                                                      // controller.selectedSection
                                                      //     .value = 'daily';
                                                      // await controller
                                                      //     .fetchData(
                                                      //         DateTime.now(),
                                                      //         'weekly');
                                                      Get.back();
                                                    },
                                                    child: const Text('Hapus'),
                                                  ),
                                                  cancel: TextButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: Text(
                                                      'Batal',
                                                      style: TextStyle(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.5)),
                                                    ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Symbols.close,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => addOperatingCostDialog(
                                          context,
                                          controller,
                                        ),
                                        child: const Text(
                                          'Tambah Biaya Operasional',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        Expanded(
                          flex: 3,
                          child: DatePickerCard(controller: controller),
                        ),
                      ],
                    );
            },
          ),
        ),
        Card(
          child: Container(
            padding: const EdgeInsets.all(12),
            height: 70,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.rangePickerHandle(controller.args.value);
                        controller.selectedSection.value = 'daily';
                      },
                      style: ButtonStyle(
                        enableFeedback: true,
                        backgroundColor: WidgetStatePropertyAll(
                          controller.selectedSection.value == 'daily'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                        ),
                      ),
                      child: Text(
                        'Harian',
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.selectedSection.value == 'daily'
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.rangePickerHandle(controller.args.value);
                        controller.selectedSection.value = 'weekly';
                      },
                      style: ButtonStyle(
                        enableFeedback: true,
                        backgroundColor: WidgetStatePropertyAll(
                          controller.selectedSection.value == 'weekly'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                        ),
                      ),
                      child: Text(
                        'Mingguan',
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.selectedSection.value == 'weekly'
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.monthPickerHandle(controller.args.value);
                        controller.selectedSection.value = 'monthly';
                      },
                      style: ButtonStyle(
                        enableFeedback: true,
                        backgroundColor: WidgetStatePropertyAll(
                          controller.selectedSection.value == 'monthly'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                        ),
                      ),
                      child: Text(
                        'Bulanan',
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.selectedSection.value == 'monthly'
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.yearPickerHandle(controller.args.value);
                        controller.selectedSection.value = 'yearly';
                      },
                      style: ButtonStyle(
                        enableFeedback: true,
                        backgroundColor: WidgetStatePropertyAll(
                          controller.selectedSection.value == 'yearly'
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                        ),
                      ),
                      child: Text(
                        'Tahunan',
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.selectedSection.value == 'yearly'
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.grey[200]!.withOpacity(0.8),
          tooltipPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rodIndex == 0
                  ? rod.toY == 0
                      ? '0'
                      : 'Rp${currency.format(controller.invoiceChart[groupIndex].totalSellPrice)}'
                  : controller.invoiceChart[groupIndex].totalInvoice.toString(),
              TextStyle(
                color: rodIndex == 0 ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        touchCallback: (event, response) {
          if (event.isInterestedForInteractions &&
              response != null &&
              response.spot != null) {
            controller.touchedGroupIndex.value =
                response.spot!.touchedBarGroupIndex;
            controller.touchedDataIndex.value =
                response.spot!.touchedRodDataIndex;
          } else {
            controller.touchedGroupIndex.value = -1;
          }
        },
      );

  Widget getTitles(double value, TitleMeta meta) {
    List<Chart> chart = controller.invoiceChart;
    String dateString = chart[value.toInt()].dateString;
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
          controller.groupDate.value == 'weekly'
              ? dateString
              : (value.toInt() + 1).toString(),
          style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
      );

  List<BarChartGroupData> get barGroups => List.generate(
        controller.invoiceChart.length,
        (index) {
          Chart chart = controller.invoiceChart[index];
          // debugPrint('-----');
          // debugPrint(
          //     'chartTotalProfit: ${chart.totalProfit == 0 ? 0 : (chart.totalProfit / controller.maxTotalProfit)}');
          // debugPrint(
          //     'chartTotalInvoice: ${chart.totalInvoice == 0 ? 0 : (chart.totalInvoice / controller.maxTotalInvoice)}');
          // debugPrint('-----');
          double totalPurchase =
              chart.totalSellPrice / controller.maxTotalPurchase;
          double totalProfit = chart.cleanProfit / controller.maxTotalPurchase;
          double totalPaid = chart.totalPay / controller.maxTotalPurchase;
          return BarChartGroupData(
            barsSpace: 1,
            x: index,
            barRods: [
              BarChartRodData(
                toY: chart.cleanProfit == 0 ? 0 : totalPurchase,
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    totalProfit,
                    Colors.red,
                  ),
                  BarChartRodStackItem(
                    totalProfit,
                    totalPaid,
                    Colors.orange,
                  ),
                ],
                color: Colors.amber,
                borderRadius: BorderRadius.circular(2),
              ),
              BarChartRodData(
                toY: (chart.totalInvoice == 0
                        ? 0
                        : chart.totalInvoice /
                            (controller.maxTotalInvoice * (120 / 100))) *
                    (100 / 100),
                color: Colors.orange,
                borderRadius: BorderRadius.circular(2),
              )
            ],
            showingTooltipIndicators:
                controller.touchedGroupIndex.value == index
                    ? [controller.touchedDataIndex.value]
                    : [],
          );
        },
      );
}

class PropertiesPayWidget extends StatelessWidget {
  const PropertiesPayWidget({
    super.key,
    required this.title,
    this.cash,
    this.transfer,
    this.total,
    this.color,
  });

  final String title;
  final String? cash;
  final String? transfer;
  final String? total;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: context.textTheme.titleMedium!
                          .copyWith(color: color)),
                  SizedBox(
                    width: 300,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            cash == 'Rp0' || cash == 'Rp-0'
                                ? '-'
                                : (cash ?? 'Cash'),
                            textAlign: TextAlign.right,
                            style: context.textTheme.titleMedium!
                                .copyWith(color: color),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            transfer == 'Rp0' || transfer == 'Rp-0'
                                ? '-'
                                : (transfer ?? 'Transfer'),
                            textAlign: TextAlign.right,
                            style: context.textTheme.titleMedium!
                                .copyWith(color: color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                total ?? '',
                textAlign: TextAlign.right,
                style: context.textTheme.titleMedium!.copyWith(color: color),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BarChartDialog extends StatelessWidget {
  const BarChartDialog({
    super.key,
    required this.barTouchData,
    required this.titlesData,
    required this.borderData,
    required this.barGroups,
    required this.controller,
    required this.date,
    required this.prevDate,
    required this.sell,
    required this.prevSell,
    required this.profit,
    required this.prevProfit,
    required this.pay,
    required this.prevPay,
    required this.totalInvoice,
    required this.prevTotalInvoice,
  });

  final BarTouchData barTouchData;
  final FlTitlesData titlesData;
  final FlBorderData borderData;
  final List<BarChartGroupData> barGroups;
  final StatisticController controller;
  final String date;
  final String prevDate;
  final int sell;
  final int prevSell;
  final int profit;
  final int prevProfit;
  final int pay;
  final int prevPay;
  final int totalInvoice;
  final int prevTotalInvoice;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: Obx(
                () => BarChart(
                  BarChartData(
                    barTouchData: barTouchData,
                    titlesData: titlesData,
                    borderData: borderData,
                    barGroups: barGroups,
                    gridData: const FlGridData(show: false),
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.4,
                  ),
                ),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Expanded(
              flex: 1,
              child: SizedBox(
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Keuntungan',
                          style: context.textTheme.bodySmall,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Jumlah Invoice',
                          style: context.textTheme.bodySmall,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: DisplayDataListTile(
                        controller: controller,
                        title: '',
                        subtitle1: date,
                        subtitle2: prevDate,
                        subtitle3: const Text(''),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: DisplayDataListTile(
                        controller: controller,
                        title: 'Tagihan',
                        subtitle1: 'Rp.${currency.format(sell)}',
                        subtitle2: 'Rp.${currency.format(prevSell)}',
                        subtitle3:
                            controller.percentage(sell, prevSell, context),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: DisplayDataListTile(
                        controller: controller,
                        title: 'Keuntungan',
                        subtitle1: 'Rp.${currency.format(profit)}',
                        subtitle2: 'Rp.${currency.format(prevProfit)}',
                        subtitle3:
                            controller.percentage(profit, prevProfit, context),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: DisplayDataListTile(
                        controller: controller,
                        title: 'Dibayar',
                        subtitle1: 'Rp.${currency.format(pay)}',
                        subtitle2: 'Rp.${currency.format(prevPay)}',
                        subtitle3:
                            controller.percentage(profit, prevProfit, context),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: DisplayDataListTile(
                        controller: controller,
                        title: 'Invoice',
                        subtitle1: totalInvoice.toString(),
                        subtitle2: prevTotalInvoice.toString(),
                        subtitle3: controller.percentage(
                          totalInvoice,
                          prevTotalInvoice,
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DatePickerCard extends StatelessWidget {
  const DatePickerCard({
    super.key,
    required this.controller,
  });

  final StatisticController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Card(
          child: Column(
            children: [
              const Text('Pilih Data:'),
              if (controller.selectedSection.value == 'daily')
                Expanded(child: DatePickerDaily(controller: controller)),
              if (controller.selectedSection.value == 'weekly')
                Expanded(child: DatePickerWeekly(controller: controller)),
              if (controller.selectedSection.value == 'monthly')
                Expanded(child: DatePickerMonthly(controller: controller)),
              if (controller.selectedSection.value == 'yearly')
                Expanded(child: DatePickerYearly(controller: controller)),
            ],
          ),
        );
      },
    );
  }
}

class DatePickerDaily extends StatelessWidget {
  const DatePickerDaily({
    super.key,
    required this.controller,
  });

  final StatisticController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 480,
      child: SfDateRangePicker(
        controller: controller.dailyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        enableMultiView: true,
        initialSelectedDate: controller.initDate.value,
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        selectionMode: DateRangePickerSelectionMode.single,
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          controller.rangePickerHandle(args.value);
        },
      ),
    );
  }
}

class DatePickerWeekly extends StatelessWidget {
  const DatePickerWeekly({
    super.key,
    required this.controller,
  });

  final StatisticController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 480,
      child: SfDateRangePicker(
        controller: controller.weeklyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        enableMultiView: true,
        initialSelectedRange: controller.selectedWeeklyRange.value,
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        selectionMode: DateRangePickerSelectionMode.range,
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          PickerDateRange value = args.value;
          if (value.endDate == null) {
            controller.rangePickerHandle(value.startDate!);
          }
        },
      ),
    );
  }
}

class DatePickerMonthly extends StatelessWidget {
  const DatePickerMonthly({
    super.key,
    required this.controller,
  });

  final StatisticController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 480,
      child: SfDateRangePicker(
        controller: controller.monthlyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        // enableMultiView: true,
        view: DateRangePickerView.year,
        allowViewNavigation: false,
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          controller.monthPickerHandle(args.value);
        },
      ),
    );
  }
}

class DatePickerYearly extends StatelessWidget {
  const DatePickerYearly({
    super.key,
    required this.controller,
  });

  final StatisticController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 480,
      child: SfDateRangePicker(
        controller: controller.yearlyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        view: DateRangePickerView.decade,
        allowViewNavigation: false,
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          controller.yearPickerHandle(args.value);
        },
      ),
    );
  }
}

class DisplayDataListTile extends StatelessWidget {
  const DisplayDataListTile({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.subtitle3,
  });

  final StatisticController controller;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final Widget subtitle3;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(title, style: context.textTheme.bodySmall),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(subtitle1,
                  style: context.textTheme.bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle2, style: context.textTheme.bodySmall),
          const SizedBox(height: 2),
          subtitle3,
        ],
      ),
    );
  }
}

class BarChartSample3 extends StatefulWidget {
  const BarChartSample3({super.key});

  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1.6,
      child: BarChartWidget(),
    );
  }
}
