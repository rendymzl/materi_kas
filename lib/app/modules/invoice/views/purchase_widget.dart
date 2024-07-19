// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:material_symbols_icons/symbols.dart';

// import '../../../data/models/cart_model.dart';
// import '../../../data/models/invoice_model.dart';
// import '../controllers/invoice_controller.dart';
// import 'list_cart_widget.dart';

// class PurchaseWidget extends StatelessWidget {
//   const PurchaseWidget({
//     super.key,
//     // required this.returnCart,
//     required this.controller,
//     required this.invoice,
//     required this.purchaseCart,
//   });

//   // final RxList<Cart> returnCart;
//   final InvoiceController controller;
//   final Invoice invoice;
//   final RxList<Cart> purchaseCart;

//   @override
//   Widget build(BuildContext context) {
//     const source = 'purchaseWidget';
//     return Flexible(
//       child: Row(
//         children: [
//           // if (returnCart.isNotEmpty)
//           // Expanded(
//           //   flex: 3,
//           //   child: Container(
//           //     decoration: const BoxDecoration(
//           //       border: Border(
//           //         right: BorderSide(
//           //           color: Colors.grey,
//           //         ),
//           //       ),
//           //     ),
//           //     child: Column(
//           //       children: [
//           //         Flexible(
//           //           child: ListCartWidget(
//           //             source: source,
//           //             cartList: returnCart,
//           //             controller: controller,
//           //             isReturn: true,
//           //           ),
//           //         ),
//           //         ListTile(
//           //           title: Column(
//           //             crossAxisAlignment: CrossAxisAlignment.end,
//           //             children: [
//           //               Row(
//           //                 mainAxisAlignment: MainAxisAlignment.end,
//           //                 children: [
//           //                   Text(
//           //                     'Total:',
//           //                     textAlign: TextAlign.right,
//           //                     style: Theme.of(Get.context!)
//           //                         .textTheme
//           //                         .bodyLarge!
//           //                         .copyWith(
//           //                             fontStyle: FontStyle.italic,
//           //                             color: Theme.of(Get.context!)
//           //                                 .colorScheme
//           //                                 .primary),
//           //                   ),
//           //                   const SizedBox(width: 20),
//           //                   SizedBox(
//           //                     width: 120,
//           //                     child: Text(
//           //                       'Rp.${controller.currency.format(controller.totalReturn.value)}',
//           //                       textAlign: TextAlign.end,
//           //                       style: Theme.of(Get.context!)
//           //                           .textTheme
//           //                           .bodyLarge!
//           //                           .copyWith(
//           //                               fontStyle: FontStyle.italic,
//           //                               color: Theme.of(Get.context!)
//           //                                   .colorScheme
//           //                                   .primary),
//           //                     ),
//           //                   ),
//           //                 ],
//           //               ),
//           //               Row(
//           //                 mainAxisAlignment: MainAxisAlignment.end,
//           //                 children: [
//           //                   Text(
//           //                     'Biaya Return:',
//           //                     style: context.textTheme.titleLarge,
//           //                   ),
//           //                   const SizedBox(width: 20),
//           //                   SizedBox(
//           //                     width: 120,
//           //                     child: TextField(
//           //                         controller:
//           //                             controller.returnFeeTextController,
//           //                         style: context.textTheme.titleLarge,
//           //                         textAlign: TextAlign.right,
//           //                         decoration: InputDecoration(
//           //                           prefixIcon: Text(
//           //                             'Rp.',
//           //                             style: context.textTheme.titleLarge,
//           //                           ),
//           //                           prefixIconConstraints: const BoxConstraints(
//           //                               minWidth: 0, minHeight: 0),
//           //                           hintText: '0',
//           //                         ),
//           //                         keyboardType:
//           //                             const TextInputType.numberWithOptions(
//           //                                 decimal: true),
//           //                         inputFormatters: [
//           //                           FilteringTextInputFormatter.allow(
//           //                               RegExp(r'[0-9]'))
//           //                         ],
//           //                         onChanged: (value) {
//           //                           controller.returnFeeHandle(value, invoice);
//           //                         }),
//           //                   ),
//           //                 ],
//           //               ),
//           //               Obx(
//           //                 () => Row(
//           //                   mainAxisAlignment: MainAxisAlignment.end,
//           //                   children: [
//           //                     Text(
//           //                       'TOTAL RETURN:',
//           //                       textAlign: TextAlign.right,
//           //                       style: Theme.of(Get.context!)
//           //                           .textTheme
//           //                           .bodyLarge!
//           //                           .copyWith(
//           //                               fontStyle: FontStyle.italic,
//           //                               color: Theme.of(Get.context!)
//           //                                   .colorScheme
//           //                                   .primary),
//           //                     ),
//           //                     const SizedBox(width: 20),
//           //                     SizedBox(
//           //                       width: 120,
//           //                       child: Text(
//           //                         'Rp.${controller.currency.format(controller.totalReturnFinal.value)}',
//           //                         textAlign: TextAlign.end,
//           //                         style: Theme.of(Get.context!)
//           //                             .textTheme
//           //                             .bodyLarge!
//           //                             .copyWith(
//           //                                 fontStyle: FontStyle.italic,
//           //                                 color: Theme.of(Get.context!)
//           //                                     .colorScheme
//           //                                     .primary),
//           //                       ),
//           //                     ),
//           //                   ],
//           //                 ),
//           //               ),
//           //             ],
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   ),
//           // ),
//           Expanded(
//             flex: 5,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: ListCartWidget(
//                     source: source,
//                     cartList: purchaseCart,
//                     controller: controller,
//                     isReturn: false,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 250,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Get.defaultDialog(
//                               content: Container(
//                                 margin: const EdgeInsets.all(8),
//                                 height: MediaQuery.of(context).size.height *
//                                     (3 / 4),
//                                 width: MediaQuery.of(context).size.width *
//                                     (9 / 10),
//                                 child: ProductListCard(
//                                   controller: controller,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: const Text('Tambah barang'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// //! 1 ProductListCard ==================================================================
// class ProductListCard extends StatelessWidget {
//   const ProductListCard({
//     super.key,
//     required this.controller,
//   });

//   final InvoiceController controller;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: Column(
//           children: [
//             Container(
//               color: Colors.white,
//               child: TextField(
//                 decoration: const InputDecoration(
//                   labelText: "Cari Barang",
//                   labelStyle: TextStyle(color: Colors.grey),
//                   suffixIcon: Icon(Symbols.search),
//                 ),
//                 onChanged: (value) => controller.filterProducts(value),
//               ),
//             ),
//             Expanded(
//               child: Obx(
//                 () => Column(
//                   children: [
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: controller.foundProducts.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           final foundProduct = controller.foundProducts[index];
//                           return Container(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             decoration: BoxDecoration(
//                               border: Border.symmetric(
//                                 horizontal:
//                                     BorderSide(color: Colors.grey[200]!),
//                               ),
//                             ),
//                             child: ListTile(
//                                 leading: Text(
//                                   foundProduct.productId!,
//                                   style: context.textTheme.bodySmall,
//                                 ),
//                                 title: Text(
//                                   '${foundProduct.productName}',
//                                   style: context.textTheme.titleLarge,
//                                 ),
//                                 trailing: Text(
//                                   'Rp.${controller.currency.format(foundProduct.sellPrice)}',
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                                 onTap: () {
//                                   controller.addToCart(foundProduct);
//                                   Get.back();
//                                 }),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
