import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:path/path.dart';

import '../../../widget/side_menu_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const SideMenuWidget(title: 'Toko'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (5 / 8),
          // height: MediaQuery.of(context).size.height * (7 / 9),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Obx(
                        () => Column(
                          children: [
                            ListView(
                              shrinkWrap: true,
                              children: [
                                ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Nama Toko'),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          controller.stores.value!.name.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Alamat'),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          controller
                                              .stores.value!.address.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('No Hp'),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          controller.stores.value!.phone.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('No Telp'),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          controller.stores.value!.telp.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(thickness: 1),
                            if (controller.cashiers.isNotEmpty)
                              Text(
                                'Daftar Kasir',
                                style: context.textTheme.titleLarge,
                              ),
                            if (controller.cashiers.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.cashiers.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Text((index + 1).toString()),
                                    title:
                                        Text(controller.cashiers[index].name),
                                  );
                                },
                              )
                          ],
                        ),
                      ),
                      // FormStoresWidget(controller: controller),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: controller.formCashierKey,
                        child: Column(
                          children: [
                            Text('Tambah Kasir',
                                style: context.textTheme.titleLarge),
                            const SizedBox(height: 12),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              height: 50,
                              child: TextFormField(
                                controller: controller.nameController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Nama Kasir'),
                                validator: (value) =>
                                    controller.validateCashierName(value),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              height: 50,
                              child: TextFormField(
                                controller: controller.emailController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Email Kasir'),
                                validator: (value) =>
                                    controller.validateEmail(value),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              height: 50,
                              child: TextFormField(
                                controller: controller.passwordController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Password'),
                                obscureText: true,
                                validator: (value) =>
                                    controller.validatePassword(value),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () => controller.registerWorker(),
                              child: const Text('Tambah Kasir'),
                            ),
                            // ElevatedButton(
                            //   onPressed: () => controller.registerWorker(),
                            //   child: const Text('tes'),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormStoresWidget extends StatelessWidget {
  const FormStoresWidget({
    super.key,
    required this.controller,
  });

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: controller.storeNameController,
            decoration: const InputDecoration(labelText: 'Nama Toko'),
            validator: (value) => controller.validateStoreName(value),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: controller.storeAddressController,
            decoration: const InputDecoration(labelText: 'Alamat Toko'),
            validator: (value) => controller.validateStoreAddress(value),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: controller.storePhoneController,
            decoration: const InputDecoration(labelText: 'No HP Toko'),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: controller.storeTelpController,
            decoration: const InputDecoration(labelText: 'No Telp Toko'),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => controller.submitData(),
            child: const Text('Simpan Data Toko'),
          ),
        ],
      ),
    );
  }
}
