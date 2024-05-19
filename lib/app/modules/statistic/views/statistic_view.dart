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
                        flex: 2,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 9,
                                  child: BarChart(
                                    BarChartData(
                                      barTouchData: barTouchData,
                                      titlesData: titlesData,
                                      borderData: borderData,
                                      barGroups: barGroups,
                                      gridData: const FlGridData(show: false),
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: controller.maxY.value.toDouble(),
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
                                              'Penjualan',
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
                          child: Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title:
                                      Text(controller.invoiceChart.toString()),
                                )
                              ],
                            ),
                          )),
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
                      onPressed: () {}, child: const Text('Hari Ini')),
                  ElevatedButton(
                      onPressed: () {}, child: const Text('Kemarin')),
                  ElevatedButton(
                      onPressed: () {}, child: const Text('Minggu Ini')),
                  ElevatedButton(
                      onPressed: () => controller.fetchData('month'),
                      child: const Text('Bulan Ini')),
                  ElevatedButton(
                      onPressed: () {}, child: const Text('Pilih Tanggal')),
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
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            final formatter = NumberFormat('#,##0', 'id_ID');
            return BarTooltipItem(
              rodIndex == 0
                  ? formatter.format(rod.toY)
                  : (rod.toY / 50000).round().toString(),
              TextStyle(
                color: rodIndex == 0 ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
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
            barsSpace: 10,
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
            showingTooltipIndicators: [0, 1],
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
