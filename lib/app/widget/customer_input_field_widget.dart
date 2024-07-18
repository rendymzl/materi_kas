import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/models/customer_model.dart';
import 'customer_input_field_controller.dart';

class CustomerInputField extends StatelessWidget {
  const CustomerInputField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    late CustomerInputFieldController controller =
        Get.put(CustomerInputFieldController());
    OutlineInputBorder outlineRed =
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    return Card(
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 250,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: Autocomplete<Customer>(
                initialValue: controller.customerNameController.value,
                optionsBuilder: (TextEditingValue customerTextC) {
                  if (customerTextC.text.isEmpty) {
                    return const Iterable<Customer>.empty();
                  } else {
                    return controller.customers.where((Customer customer) {
                      final String customerName =
                          customer.name?.toLowerCase() ?? '';
                      final String input = customerTextC.text.toLowerCase();
                      return customerName.contains(input);
                    });
                  }
                },
                displayStringForOption: (Customer customer) =>
                    customer.name ?? '',
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                    decoration: const InputDecoration(
                      labelText: "Cari Pelanggan",
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Symbols.search),
                      border: InputBorder.none,
                    ),
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<Customer> onSelected,
                    Iterable<Customer> options) {
                  final int optionsLength = options.length;
                  const double itemHeight = 56.0;
                  final double maxHeight = itemHeight * optionsLength;

                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        width: 400.0,
                        height: maxHeight > 150 ? 150 : maxHeight,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: optionsLength,
                          itemBuilder: (BuildContext context, int index) {
                            final Customer option = options.elementAt(index);
                            return ListTile(
                              title: Text(option.name ?? ''),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (Customer customer) {
                  controller.asignCustomer(customer);
                },
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                        controller: controller.customerNameController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Nama Pelanggan',
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          focusedErrorBorder: outlineRed,
                          errorBorder: outlineRed,
                        ),
                        onChanged: (value) {
                          controller.customerNameController.text = value;
                          controller.displayName.value = value;
                          controller.updateSelectedCustomer(
                            controller.selectedCustomer.value!,
                          );
                        }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextField(
                        controller: controller.customerPhoneController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'No. Telp',
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          focusedErrorBorder: outlineRed,
                          errorBorder: outlineRed,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        onChanged: (value) {
                          controller.customerPhoneController.text = value;
                          controller.updateSelectedCustomer(
                            controller.selectedCustomer.value!,
                          );
                        }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller.customerAddressController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Alamat',
                  alignLabelWithHint: true,
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedErrorBorder: outlineRed,
                  errorBorder: outlineRed,
                ),
                onChanged: (value) {
                  controller.customerAddressController.text = value;
                  controller.updateSelectedCustomer(
                    controller.selectedCustomer.value!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
