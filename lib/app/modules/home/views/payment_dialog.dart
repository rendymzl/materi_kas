// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../data/models/invoice_model.dart';
// import 'return_widget.dart';
// import '../controllers/invoice_controller.dart';

// void returnDialog(
//     BuildContext context, InvoiceController controller, Invoice invoice) {
//   controller.resetEditData(invoice);
//   Get.defaultDialog(
//     title: 'Return Barang',
//     content: Container(
//       margin: const EdgeInsets.all(8),
//       height: MediaQuery.of(context).size.height * (3 / 4),
//       width: MediaQuery.of(context).size.width * (7 / 10),
//       child: ListView(
//         children: [
//           ReturnCard(
//             controller: controller,
//             invoice: invoice,
//           ),
//         ],
//       ),
//     ),
//   );
// }

// class ReturnCard extends StatelessWidget {
//   const ReturnCard({
//     super.key,
//     required this.controller,
//     required this.invoice,
//   });

//   final InvoiceController controller;
//   final Invoice invoice;

//   @override
//   Widget build(BuildContext context) {
//     controller.totalPurchase.value = 0;
//     final editPurchaseCart = controller.editAfterReturnCart;
//     final editReturnCart = controller.editReturnCart;
//     controller.totalDiscount.value = 0;
//     for (var item in editPurchaseCart) {
//       controller.totalPurchase.value +=
//           (item.product!.sellPrice! * item.quantity! -
//               item.individualDiscount!);

//       controller.totalDiscount.value += item.individualDiscount!;
//     }

//     controller.totalChange.value =
//         (int.parse(controller.payTextController.text.replaceAll('.', '')) -
//             controller.totalPurchase.value);
//     // debugPrint("return fee ${controller.returnFee.value}");
//     controller.returnFeeTextController.text = controller.returnFee.value == 0
//         ? ''
//         : controller.currency.format(controller.returnFee.value);
//     return Column(
//       children: [
//         Obx(
//           () {
//             return SizedBox(
//               height: (editPurchaseCart.length > editReturnCart.length
//                           ? editPurchaseCart.length
//                           : editReturnCart.length) *
//                       105 +
//                   230,
//               child: Card(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 12),
//                     ReturnWidget(
//                       returnCart: editReturnCart,
//                       controller: controller,
//                       invoice: invoice,
//                       purchaseCart: editPurchaseCart,
//                     ),
//                     const SizedBox(height: 12),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
