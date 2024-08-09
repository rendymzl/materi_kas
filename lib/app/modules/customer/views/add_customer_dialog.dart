import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/customer_model.dart';
import '../controllers/add_customer_controller_dialog.dart';

void addEditCustomerDialog(BuildContext context, Customer? foundCustomer) {
  AddCustomerController controller = Get.put(AddCustomerController());

  if (foundCustomer != null) {
    controller.bindingEditData(foundCustomer);
  } else {
    controller.bindingEditData(Customer());
  }
  // controller.minNameLenght.value = 0;
  controller.clickedField['name'] = false;
  controller.clickedField['phone'] = false;
  controller.clickedField['address'] = false;
  OutlineInputBorder outlineRed =
      const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
  Get.defaultDialog(
    title: foundCustomer != null ? 'Edit Pelanggan' : 'Tambah Pelanggan',
    content: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        margin: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * (1 / 2),
        width: MediaQuery.of(context).size.width * (3 / 10),
        child: Form(
          key: controller.formkey,
          autovalidateMode: AutovalidateMode.always,
          child: ListView(
            children: <Widget>[
              TextFormField(
                // enabled: false,
                controller: controller.idController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'ID Pelanggan',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                ),
                onChanged: (value) => controller.clickedField['id'] = true,
                validator: (value) => controller.idValidator(value!),
                onFieldSubmitted: (_) => controller.handleSave(foundCustomer),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Nama Pelanggan',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                ),
                onChanged: (value) => controller.clickedField['name'] = true,
                validator: (value) => controller.nameValidator(value!),
                onFieldSubmitted: (_) => controller.handleSave(foundCustomer),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.phoneController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'No.Telp',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                onChanged: (value) => controller.clickedField['phone'] = true,
                onFieldSubmitted: (_) => controller.handleSave(foundCustomer),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.addressController,
                minLines: 1,
                maxLines: 7,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Alamat',
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                ),
                onChanged: (value) => controller.clickedField['address'] = true,
                onFieldSubmitted: (_) => controller.handleSave(foundCustomer),
              ),
            ],
          ),
        ),
      ),
    ),
    backgroundColor: Colors.white,
    confirm: Container(
      margin: const EdgeInsets.all(10),
      width: 160,
      child: ElevatedButton(
        onPressed: () async => await controller.handleSave(foundCustomer),
        child: const Text('Simpan'),
      ),
    ),
    cancel: Container(
      margin: const EdgeInsets.all(10),
      width: 160,
      child: OutlinedButton(
        style: ButtonStyle(
          side: WidgetStateProperty.all(
              BorderSide(color: Colors.black.withOpacity(0.5))),
        ),
        onPressed: () => Get.back(),
        child: const Text('Batal'),
      ),
    ),
  );
}
