import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widget/side_menu_widget.dart';
import '../controllers/statistic_controller.dart';

class StatisticView extends GetView<StatisticController> {
  const StatisticView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProfileView'),
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
              // BarChart(),
            ],
          ),
        ),
      ),
    );
  }
}

// class BarChart extends GetView<StatisticController> {
//   const BarChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final Color barBackgroundColor = Theme.of(context).colorScheme.background;
//     final Color barColor = Colors.red[200]!;
//     final Color touchedBarColor = Theme.of(context).colorScheme.primary;
//     return Obx(
//       () => AspectRatio(
//         aspectRatio: 1,
//         child: Stack(
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   Text(
//                     'Mingguan',
//                     style: context.textTheme.displayMedium,
//                   ),
//                   const SizedBox(
//                     height: 4,
//                   ),
//                   Text(
//                     'Grafik konsumsi kalori',
//                     style: context.textTheme.bodySmall,
//                   ),
//                   const SizedBox(
//                     height: 38,
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: BarChart(
//                         isPlaying ? randomData() : mainBarData(),
//                         swapAnimationDuration: animDuration,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: Align(
//                 alignment: Alignment.topRight,
//                 child: IconButton(
//                   icon: Icon(
//                     isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: AppColors.contentColorGreen,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       isPlaying = !isPlaying;
//                       if (isPlaying) {
//                         refreshState();
//                       }
//                     });
//                   },
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildMenuEntry(SideMenuData data, int index, BuildContext context) {
//     return ListTile(
//       contentPadding: const EdgeInsets.all(0),
//       minVerticalPadding: 0,
//       title: Obx(
//         () => Container(
//             padding: const EdgeInsets.all(10),
//             child: controller.isExpand.value
//                 ? ElevatedButton.icon(
//                     onPressed: () => controller.handleClick(index),
//                     icon: Icon(
//                       data.menu[index].icon,
//                       color: controller.selectedIndex.value == index
//                           ? Colors.white
//                           : Colors.grey[700],
//                     ),
//                     label: Text(
//                       data.menu[index].label,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: controller.selectedIndex.value == index
//                             ? Colors.white
//                             : Colors.grey[700],
//                         fontWeight: controller.isExpand.value
//                             ? FontWeight.w600
//                             : FontWeight.normal,
//                       ),
//                     ),
//                     style: ButtonStyle(
//                       alignment: Alignment.centerLeft,
//                       enableFeedback: true,
//                       backgroundColor: MaterialStatePropertyAll(
//                         controller.selectedIndex.value == index
//                             ? Theme.of(context).colorScheme.primary
//                             : Colors.white,
//                       ),
//                     ),
//                   )
//                 : IconButton(
//                     onPressed: () => controller.handleClick(index),
//                     icon: Icon(
//                       data.menu[index].icon,
//                       color: controller.selectedIndex.value == index
//                           ? Colors.white
//                           : Colors.grey[700],
//                     ),
//                     style: ButtonStyle(
//                       padding:
//                           const MaterialStatePropertyAll(EdgeInsets.all(12)),
//                       backgroundColor: MaterialStatePropertyAll(
//                         controller.selectedIndex.value == index
//                             ? Theme.of(context).colorScheme.primary
//                             : Colors.white,
//                       ),
//                     ),
//                   )),
//       ),
//     );
//   }
// }
