import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materi_kas/app/widget/data/side_menu_data.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'side_menu_controller.dart';

class SideMenuWidget extends GetView<SideMenuController> {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final data = SideMenuData();
    return Obx(
      () => SizedBox(
        width: controller.isExpand.value ? 230 : 100,
        child: Card(
          child: Column(
            crossAxisAlignment: controller.isExpand.value
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center,
            children: [
              // const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(5),
                child: IconButton(
                  onPressed: () => controller.toggleDrawer(),
                  icon: !controller.isExpand.value
                      ? const Icon(Symbols.keyboard_arrow_right)
                      : const Icon(Symbols.keyboard_arrow_left),
                ),
              ),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: ListView.builder(
                    itemCount: data.menu.length,
                    itemBuilder: (context, index) =>
                        buildMenuEntry(data, index, context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      minVerticalPadding: 0,
      title: Obx(
        () => Container(
            padding: const EdgeInsets.all(10),
            child: controller.isExpand.value
                ? ElevatedButton.icon(
                    onPressed: () => controller.handleClick(index),
                    icon: Icon(
                      data.menu[index].icon,
                      color: controller.selectedIndex.value == index
                          ? Colors.white
                          : Colors.grey[700],
                    ),
                    label: Text(
                      data.menu[index].label,
                      style: TextStyle(
                        fontSize: 16,
                        color: controller.selectedIndex.value == index
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: controller.isExpand.value
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    style: ButtonStyle(
                      alignment: Alignment.centerLeft,
                      enableFeedback: true,
                      backgroundColor: WidgetStatePropertyAll(
                        controller.selectedIndex.value == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: () => controller.handleClick(index),
                    icon: Icon(
                      data.menu[index].icon,
                      color: controller.selectedIndex.value == index
                          ? Colors.white
                          : Colors.grey[700],
                    ),
                    style: ButtonStyle(
                      padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
                      backgroundColor: WidgetStatePropertyAll(
                        controller.selectedIndex.value == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                    ),
                  )),
      ),
    );
  }
}
