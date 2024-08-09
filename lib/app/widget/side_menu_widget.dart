import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materi_kas/app/widget/data/side_menu_data.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'side_menu_controller.dart';

class SideMenuWidget extends GetView<SideMenuController> {
  const SideMenuWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final data = SideMenuData();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      height: 100,
      child: Row(
        children: [
          // Expanded(
          //   // flex: 1,
          //   child: Text(
          //     title,
          //     style: context.textTheme.displaySmall!
          //         .copyWith(fontWeight: FontWeight.bold),
          //   ),
          // ),
          Expanded(
            flex: 5,
            child: Obx(
              () => ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount:
                    (data.menu.length - (controller.isAdmin.value ? 0 : 3)),
                itemBuilder: (context, index) =>
                    buildMenuEntry(data, index, context),
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              Get.defaultDialog(
                title: 'Keluar',
                middleText: 'Keluar dari aplikasi?',
                confirm: TextButton(
                  onPressed: () => controller.signOut(),
                  child: const Text('Keluar'),
                ),
                cancel: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal'),
                ),
              );
            },
            icon: const Icon(Symbols.logout),
          ),
        ],
      ),
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index, BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton.icon(
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
        ),
      ),
    );
  }
}
