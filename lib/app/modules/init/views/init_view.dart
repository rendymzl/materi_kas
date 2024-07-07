import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
            child: controller.isLogin.value
                ? const CircularProgressIndicator()
                : const CircularProgressIndicator()),
      ),
    );
  }
}
