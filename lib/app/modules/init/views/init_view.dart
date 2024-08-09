import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../controllers/init_controller.dart';

class InitView extends GetView<InitController> {
  const InitView({super.key});
  @override
  Widget build(BuildContext context) {
    // const isLogin = controller.isLogin.value;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('InitView'),
      //   centerTitle: true,
      // ),
      body: Obx(
        () => Center(
          child: controller.loading.value
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        controller.handleAuthChanged();
                      },
                      child: const Text('Mulai Aplikasi'),
                    ),
                    IconButton(
                      onPressed: () async {
                        Get.defaultDialog(
                          title: 'Logout?',
                          middleText: 'Logout akun?',
                          confirm: TextButton(
                            onPressed: () => controller.signOut(),
                            child: const Text('Logout'),
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
        ),
      ),
    );
  }
}
