import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/setup_controller.dart';

class SetupView extends GetView<SetupController> {
  const SetupView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Toko'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (5 / 9),
          height: MediaQuery.of(context).size.height * (7 / 9),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            height: 50,
                            child: TextFormField(
                              controller: controller.storeNameController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Nama Toko'),
                              validator: (value) =>
                                  controller.validateStoreName(value),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            height: 50,
                            child: TextFormField(
                              controller: controller.storeAddressController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Alamat Toko'),
                              validator: (value) =>
                                  controller.validateStoreAddress(value),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            height: 50,
                            child: TextFormField(
                              controller: controller.storePhoneController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'No HP Toko'),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            height: 50,
                            child: TextFormField(
                              controller: controller.storeTelpController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'No Telp Toko'),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () => controller.submitData(),
                            child: const Text('Simpan Data Toko'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(() => Text(
                              controller.storeName.value.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        Obx(() => Text(
                              controller.storeAddress.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 12,
                              ),
                            )),
                        Obx(
                          () {
                            String phone = controller.storePhone.value;
                            String telp = controller.storeTelp.value;
                            String slash = (phone.isNotEmpty && telp.isNotEmpty)
                                ? '/'
                                : '';
                            return Text(
                              '${controller.storePhone.value} $slash ${controller.storeTelp.value}',
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                        const Divider(thickness: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
