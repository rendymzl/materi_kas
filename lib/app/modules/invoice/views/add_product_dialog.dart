import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materi_kas/app/data/models/cart_item_model.dart';
// import 'package:materi_kas/app/data/models/cart_model.dart';
import 'package:material_symbols_icons/symbols.dart';

// import '../../../data/models/cart_model.dart';
// import '../../../data/models/invoice_model.dart';
import '../../../../main.dart';
import '../../../data/models/invoice_model.dart';
import '../controllers/invoice_controller.dart';
// import 'list_cart_widget.dart';

//! 1 AddProductDialog ==================================================================
class AddProductDialog extends StatelessWidget {
  const AddProductDialog({
    super.key,
    required this.controller,
    required this.invoice,
  });

  final InvoiceController controller;
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    controller.initCartItems.clear();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Cari Barang",
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Symbols.search),
                ),
                onChanged: (value) => controller.filterProducts(value),
              ),
            ),
            Expanded(
              child: Obx(
                () => Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.foundProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final foundProduct = controller.foundProducts[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                horizontal:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: ListTile(
                                leading: SizedBox(
                                  width: 60,
                                  child: Text(
                                    foundProduct.productId,
                                    style: context.textTheme.bodySmall,
                                  ),
                                ),
                                title: Text(
                                  foundProduct.productName,
                                  style: context.textTheme.titleLarge,
                                ),
                                trailing: Text(
                                  'Rp.${currency.format(foundProduct.getPrice(1))}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                onTap: () {
                                  CartItem cartItem = CartItem(
                                    product: foundProduct,
                                    quantity: 1,
                                  );
                                  // invoice.purchaseList.value.addItem(cartItem);
                                  controller.addToReturnCart(cartItem, invoice);
                                  Get.back();
                                }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
