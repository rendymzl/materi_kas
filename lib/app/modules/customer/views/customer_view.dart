import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/models/customer_model.dart';
import '../../../widget/side_menu_widget.dart';
import '../controllers/customer_controller.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Customers'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SideMenuWidget(),
              Expanded(
                flex: 4,
                child: SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 13,
                        child: CustomerListCard(
                            controller: controller,
                            formatter: formatter), //! 1 customerListCard
                      ),
                      // const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() => Text(
                                  'Total Customer: ${controller.customerList.length.toString()}',
                                  style: context.textTheme.bodySmall,
                                )),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    controller.bindingEditData(
                                      Customer(
                                        name: '',
                                        phone: '',
                                        address: '',
                                        uuid: '',
                                      ),
                                    );
                                    addEditDialog(context, controller, null,
                                        'Tambah Customer');
                                  },
                                  child: const Text('Tambah Customer'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

//! 1 customerListCard ==================================================================
class CustomerListCard extends StatelessWidget {
  const CustomerListCard({
    super.key,
    required this.controller,
    required this.formatter,
  });

  final CustomerController controller;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Cari Customer",
                labelStyle: TextStyle(color: Colors.grey),
                suffixIcon: Icon(Symbols.search),
              ),
              onChanged: (value) => controller.filterCustomers(value),
            ),
            const TableHeader(), //* TableHeader
            Divider(color: Colors.grey[500]),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey[300]),
                  itemCount: controller.foundCustomers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final foundCustomer = controller.foundCustomers[index];
                    return TableContent(
                        foundCustomer: foundCustomer,
                        formatter: formatter,
                        controller: controller); //* TableContent
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//* TableHeader from ProductListCard ==================================================================
class TableHeader extends StatelessWidget {
  const TableHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        child: Text(
          'ID',
          style: context.textTheme.headlineSmall,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 8,
            child: SizedBox(
              child: Text(
                'Nama Customer',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: SizedBox(
              child: Text(
                'No. Telp',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: SizedBox(
              child: Text(
                'Alamat',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
        ],
      ),
      trailing: Text(
        'Hapus',
        style: context.textTheme.headlineSmall,
      ),
    );
  }
}

//* TableContent from ProductListCard ==================================================================
class TableContent extends StatelessWidget {
  const TableContent({
    super.key,
    required this.foundCustomer,
    required this.formatter,
    required this.controller,
  });

  final Customer foundCustomer;
  final NumberFormat formatter;
  final CustomerController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        child: Text(
          foundCustomer.customerId!,
          style: context.textTheme.bodySmall,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.only(right: 30),
              child: Text(
                '${foundCustomer.name}',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: SizedBox(
              child: Text(
                '${foundCustomer.phone}',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: SizedBox(
              child: Text(
                '${foundCustomer.address}',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IconButton(
          onPressed: () => controller.destroyHandle(foundCustomer),
          icon: const Icon(
            Symbols.delete,
            color: Colors.red,
          ),
        ),
      ),
      onTap: () {
        controller.bindingEditData(foundCustomer);
        addEditDialog(context, controller, foundCustomer, 'Edit Customer');
      },
    );
  }
}

//* addEditDialog ==================================================================
void addEditDialog(BuildContext context, CustomerController controller,
    Customer? foundCustomer, String title) {
  controller.clickedField['name'] = false;
  controller.clickedField['phone'] = false;
  controller.clickedField['address'] = false;
  OutlineInputBorder outlineRed =
      const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
  Get.defaultDialog(
    title: title,
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
                controller: controller.nameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Nama Customer',
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
          side: MaterialStateProperty.all(
              BorderSide(color: Colors.black.withOpacity(0.5))),
        ),
        onPressed: () => Get.back(),
        child: const Text('Batal'),
      ),
    ),
  );
}
