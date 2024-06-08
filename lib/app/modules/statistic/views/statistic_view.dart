import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/invoice_model.dart';
import '../../../widget/model/chart_model.dart';
import '../../../widget/side_menu_widget.dart';
import '../controllers/statistic_controller.dart';

class StatisticView extends GetView<StatisticController> {
  const StatisticView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
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
              SideMenuWidget(),
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
              final date = controller.selectedChart.value!.dateString;
              final prevDate = controller.prevSelectedChart.value!.dateString;

              final sell = controller.selectedChart.value!.totalSellPrice;
              final prevSell =
                  controller.prevSelectedChart.value!.totalSellPrice;

              final profit = controller.selectedChart.value!.totalProfit;
              final prevProfit =
                  controller.prevSelectedChart.value!.totalProfit;

              final totalInvoice = controller.selectedChart.value!.totalInvoice;
              final prevTotalInvoice =
                  controller.prevSelectedChart.value!.totalInvoice;
              return controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: Card(
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
                                          gridData:
                                              const FlGridData(show: false),
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY:
                                              controller.maxY.value.toDouble(),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 16,
                                                width: 16,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  color: Colors.red,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Keuntungan',
                                                style:
                                                    context.textTheme.bodySmall,
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                height: 16,
                                                width: 16,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Jumlah Invoice',
                                                style:
                                                    context.textTheme.bodySmall,
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(color: Colors.grey[400]),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 35),
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
                                            flex: 4,
                                            child: DisplayDataListTile(
                                              controller: controller,
                                              title: 'Pembelian',
                                              subtitle1:
                                                  'Rp.${controller.formatter.format(sell)}',
                                              subtitle2:
                                                  'Rp.${controller.formatter.format(prevSell)}',
                                              subtitle3: controller.percentage(
                                                  sell, prevSell, context),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: DisplayDataListTile(
                                              controller: controller,
                                              title: 'Keuntungan',
                                              subtitle1:
                                                  'Rp.${controller.formatter.format(profit)}',
                                              subtitle2:
                                                  'Rp.${controller.formatter.format(prevProfit)}',
                                              subtitle3: controller.percentage(
                                                  profit, prevProfit, context),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: DisplayDataListTile(
                                              controller: controller,
                                              title: 'Jumlah Invoice',
                                              subtitle1:
                                                  totalInvoice.toString(),
                                              subtitle2:
                                                  prevTotalInvoice.toString(),
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
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: DatePickerCard(controller: controller),
                        ),
                      ],
                    );
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
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
        ),
      ],
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => controller.groupDate.value == 'weekly'
              ? Colors.transparent
              : Colors.grey[200]!.withOpacity(0.8),
          tooltipPadding: controller.groupDate.value == 'weekly'
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rodIndex == 0
                  ? controller.groupDate.value == 'weekly'
                      ? controller.formatter.format(rod.toY)
                      : rod.toY > 1000
                          ? 'Rp.${controller.formatter.format(rod.toY)}'
                          : controller.formatter.format(rod.toY / 1000)
                  : (rod.toY / 50000).round().toString(),
              TextStyle(
                color: rodIndex == 0 ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        touchCallback: controller.groupDate.value == 'weekly'
            ? null
            : (event, response) {
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
        show: false,
      );

  List<BarChartGroupData> get barGroups => List.generate(
        controller.invoiceChart.length,
        (index) {
          Chart chart = controller.invoiceChart[index];
          return BarChartGroupData(
            barsSpace: controller.groupDate.value == 'weekly' ? 10 : 1,
            x: index,
            barRods: [
              BarChartRodData(
                toY: chart.totalProfit.toDouble(),
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
              BarChartRodData(
                toY: chart.totalInvoice.toDouble() * 50000,
                color: Colors.orange,
                borderRadius: BorderRadius.circular(2),
              )
            ],
            showingTooltipIndicators: controller.groupDate.value == 'weekly'
                ? [0, 1]
                : controller.touchedGroupIndex.value == index
                    ? [controller.touchedDataIndex.value]
                    : [],
          );
        },
      );
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
          const SizedBox(height: 10),
          Row(
            children: [
              Text(subtitle1,
                  style: context.textTheme.bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(width: 4),
              subtitle3
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle2, style: context.textTheme.bodySmall),
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
