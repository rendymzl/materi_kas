import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../data/models/customer_model.dart';
import '../../../widget/side_menu_widget.dart';
import '../controllers/customer_controller.dart';
import 'add_customer_dialog.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});
  @override
  Widget build(BuildContext context) {
    // final formatter = NumberFormat('#,##0', 'id_ID');
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const SideMenuWidget(title: 'Pelanggan'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                          // formatter: formatter
                        ), //! 1 customerListCard
                      ),
                      // const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() => Text(
                                  'Total Pelanggan: ${controller.customers.length.toString()}',
                                  style: context.textTheme.bodySmall,
                                )),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      addEditCustomerDialog(context, null),
                                  child: const Text('Tambah Pelanggan'),
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
    // required this.formatter,
  });

  final CustomerController controller;
  // final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              height: 50,
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: "Cari Pelanggan",
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Symbols.search),
                ),
                onChanged: (value) => controller.filterCustomers(value),
              ),
            ),
            TableHeader(controller: controller), //* TableHeader
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
                        // formatter: formatter,
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
    required this.controller,
  });

  final CustomerController controller;
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
                'Nama Pelanggan',
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
      trailing: controller.isAdmin
          ? Text(
              'Hapus',
              style: context.textTheme.headlineSmall,
            )
          : null,
    );
  }
}

//* TableContent from ProductListCard ==================================================================
class TableContent extends StatelessWidget {
  const TableContent({
    super.key,
    required this.foundCustomer,
    // required this.formatter,
    required this.controller,
  });

  final Customer foundCustomer;
  // final NumberFormat formatter;
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
      trailing: controller.isAdmin
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                onPressed: () => controller.destroyHandle(foundCustomer),
                icon: const Icon(
                  Symbols.delete,
                  color: Colors.red,
                ),
              ),
            )
          : null,
      onTap: () => addEditCustomerDialog(context, foundCustomer),
    );
  }
}
