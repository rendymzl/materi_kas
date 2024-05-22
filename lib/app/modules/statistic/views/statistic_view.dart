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
            () => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 9,
                                  child: Obx(
                                    () => BarChart(
                                      BarChartData(
                                        barTouchData: barTouchData,
                                        titlesData: titlesData,
                                        borderData: borderData,
                                        barGroups: barGroups,
                                        gridData: const FlGridData(show: false),
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        maxY: controller.maxY.value.toDouble(),
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
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Obx(
                          () => Card(
                            child: Column(
                              children: [
                                // ListTile(
                                //   title: Row(
                                //     children: [
                                // Expanded(
                                //     child: Text('Kemarin',
                                //         style:
                                //             context.textTheme.bodyLarge)),
                                //       Expanded(
                                //           child: Text('Hari ini',
                                //               style:
                                //                   context.textTheme.bodyLarge)),
                                //     ],
                                //   ),
                                // ),
                                ListTile(
                                  title: Text('Tanggal',
                                      style: context.textTheme.bodySmall),
                                  subtitle: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            '${controller.selectedData.value?.dateString}'),
                                      ),
                                      Expanded(
                                        child: Text(
                                            '${controller.selectedData.value?.dateString}'),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  title: Text('Keuntungan',
                                      style: context.textTheme.bodySmall),
                                  subtitle: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            'Rp.${controller.formatter.format(controller.selectedData.value?.totalProfit)}'),
                                      ),
                                      Expanded(
                                        child: Text(
                                            'Rp.${controller.formatter.format(controller.selectedData.value?.totalProfit)}'),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () => controller.handleClickDate('today')
                      //  {
                      //   controller.isThisWeek.value = true;
                      //   controller.selectedDate.value = DateTime.now();
                      //   controller.fetchData('week');
                      // }
                      ,
                      child: const Text('Hari Ini')),
                  ElevatedButton(
                      onPressed: () => controller.handleClickDate('yesterday')
                      // {
                      //   controller.isThisWeek.value = true;
                      //   controller.selectedDate.value =
                      //       DateTime.now().subtract(const Duration(days: 1));
                      //   controller.fetchData('week');
                      // }
                      ,
                      child: const Text('Kemarin')),
                  ElevatedButton(
                      onPressed: () {}, child: const Text('Minggu Ini')),
                  ElevatedButton(
                      onPressed: () => controller.fetchData('month'),
                      child: const Text('Bulan Ini')),
                  InkWell(
                    onTap: controller.isDateTimeNow.value
                        ? null
                        : () async => controller.handleDate(context),
                    child: Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: controller.isDateTimeNow.value
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          controller.displayDate.value == ''
                              ? 'Pilih Tanggal'
                              : DateFormat('dd MMMM y', 'id')
                                  .format(controller.selectedDate.value),
                          style: controller.isDateTimeNow.value
                              ? context.textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontStyle: FontStyle.italic,
                                )
                              : const TextStyle(color: Colors.white),
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
          getTooltipColor: (group) => controller.isWeekly.value
              ? Colors.transparent
              : Colors.grey[200]!.withOpacity(0.8),
          tooltipPadding: controller.isWeekly.value
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            // final formatter = NumberFormat('#,##0', 'id_ID');
            return BarTooltipItem(
              rodIndex == 0
                  ? controller.isWeekly.value
                      ? controller.formatter.format(rod.toY)
                      : rod.toY > 1000
                          ? '${controller.formatter.format(rod.toY / 1000)}K'
                          : controller.formatter.format(rod.toY / 1000)
                  : (rod.toY / 50000).round().toString(),
              TextStyle(
                color: rodIndex == 0 ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        touchCallback: controller.isWeekly.value
            ? null
            : (event, response) {
                if (event.isInterestedForInteractions &&
                    response != null &&
                    response.spot != null) {
                  controller.touchedGroupIndex.value =
                      response.spot!.touchedBarGroupIndex;
                  controller.touchedDataIndex.value =
                      response.spot!.touchedRodDataIndex;
                  // debugPrint(controller.touchedGroupIndex.toString());
                } else {
                  controller.touchedGroupIndex.value = -1;
                }
              },
      );

  Widget getTitles(double value, TitleMeta meta) {
    // bool isWeekDates = controller.invoiceChart.isNotEmpty;
    List<ChartModel> chart = controller.invoiceChart;
    String dateString = chart[value.toInt()].dateString;
    // debugPrint(controller.weekInvoices[value.toInt()][0].);
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
    String text = '';
    if (controller.isWeekly.value) {
      switch (value.toInt()) {
        case 0:
          text = 'Sen';
          break;
        case 1:
          text = 'Sel';
          break;
        case 2:
          text = 'Rab';
          break;
        case 3:
          text = 'Kam';
          break;
        case 4:
          text = 'Jum';
          break;
        case 5:
          text = 'Sab';
          break;
        case 6:
          text = 'Min';
          break;
        default:
          text = '';
          break;
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
          controller.isWeekly.value
              ? '$text $dateString'
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

  // LinearGradient get _barsGradient => const LinearGradient(
  //       colors: [
  //         Colors.orange,
  //         Colors.red,
  //       ],
  //       begin: Alignment.bottomCenter,
  //       end: Alignment.topCenter,
  //     );

  List<BarChartGroupData> get barGroups => List.generate(
        controller.invoiceChart.length,
        (index) {
          ChartModel chart = controller.invoiceChart[index];
          return BarChartGroupData(
            barsSpace: controller.isWeekly.value ? 10 : 1,
            x: index,
            barRods: [
              BarChartRodData(
                toY: chart.totalProfit.toDouble(),
                color: Colors.red,
              ),
              BarChartRodData(
                toY: chart.totalInvoice.toDouble() * 50000,
                color: Colors.orange,
              )
            ],
            showingTooltipIndicators: controller.isWeekly.value
                ? [0, 1]
                : controller.touchedGroupIndex.value == index
                    ? [controller.touchedDataIndex.value]
                    : [],
          );
        },
      );
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
