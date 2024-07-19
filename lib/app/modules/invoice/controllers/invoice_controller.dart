// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// import '../../../data/models/cart_model.dart';
// import '../../../data/models/customer_model.dart';
// import '../../../data/models/invoice_model.dart';
// import '../../../data/models/product_model.dart';
// import '../../../data/providers/auth_services.dart';
// import '../../../data/providers/invoice_services.dart';
// import '../../../data/providers/product_services.dart';
// import '../../../widget/customer_input_field_controller.dart';
// import '../../product/controllers/product_controller.dart';

// class InvoiceController extends GetxController {
//   final AuthService authService = Get.find();
//   final InvoiceService invoiceServices = Get.find();
//   final ProductService productServices = Get.find();
//   final CustomerInputFieldController customerInputFieldC = Get.find();

//   late final invoices = invoiceServices.invoices;
//   late final foundInvoices = invoiceServices.foundInvoices;
//   late final products = productServices.products;
//   late final foundProducts = productServices.foundProducts;

//   final currency = NumberFormat('#,##0', 'id_ID');

//   @override
//   void onInit() async {
//     super.onInit();
//     filterInvoices('');
//   }

//   //! Filtered
//   void filterInvoices(dynamic searchValue) {
//     if (searchValue is String) {
//       invoiceServices.searchInvoicesByName(searchValue);
//     } else if (searchValue is PickerDateRange) {
//       invoiceServices.searchInvoicesByPickerDateRange(searchValue);
//     }
//   }

//   final startFilteredDate = ''.obs;
//   final endFilteredDate = ''.obs;
//   final displayFilteredDate = ''.obs;
//   final dateIsSelected = false.obs;
//   final selectedFilteredDate = DateTime.now().obs;

//   handleFilteredDate(BuildContext context) {
//     startFilteredDate.value = '';
//     endFilteredDate.value = '';
//     displayFilteredDate.value = '';
//     Get.defaultDialog(
//       title: 'Pilih Tanggal',
//       backgroundColor: Colors.white,
//       content: Column(
//         children: [
//           Obx(() {
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   '$startFilteredDate',
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.primary,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 4),
//                 const Text('sampai',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 4),
//                 Text(
//                   '$endFilteredDate',
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.primary,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ],
//             );
//           }),
//           SizedBox(
//             width: 400,
//             height: 350,
//             child: SfDateRangePicker(
//               headerStyle: DateRangePickerHeaderStyle(
//                   backgroundColor: Colors.white,
//                   textStyle: context.textTheme.bodyLarge),
//               showNavigationArrow: true,
//               backgroundColor: Colors.white,
//               monthViewSettings: const DateRangePickerMonthViewSettings(
//                 firstDayOfWeek: 1,
//               ),
//               initialSelectedDate: selectedFilteredDate.value,
//               selectionMode: DateRangePickerSelectionMode.range,
//               minDate: DateTime(2000),
//               maxDate: DateTime.now(),
//               showActionButtons: true,
//               cancelText: 'Batal',
//               onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
//                 startFilteredDate.value =
//                     DateFormat('dd MMMM y', 'id').format(args.value.startDate!);
//                 if (args.value.endDate != null) {
//                   endFilteredDate.value =
//                       DateFormat('dd MMMM y', 'id').format(args.value.endDate!);
//                 }
//               },
//               onCancel: () => Get.back(),
//               onSubmit: (value) {
//                 if (value is PickerDateRange) {
//                   if (value.endDate != null) {
//                     final newSelectedPickerRange = PickerDateRange(
//                         value.startDate,
//                         value.endDate!.add(const Duration(days: 1)));

//                     selectedFilteredDate.value =
//                         newSelectedPickerRange.startDate!;
//                     displayFilteredDate.value =
//                         '$startFilteredDate sampai $endFilteredDate';
//                     filterInvoices(newSelectedPickerRange);
//                     dateIsSelected.value = true;
//                     Get.back();
//                   }
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void clearHandle() async {
//     startFilteredDate.value = '';
//     endFilteredDate.value = '';
//     displayFilteredDate.value = '';
//     dateIsSelected.value = false;
//     filterInvoices('');
//   }

// //! Detail Invoice
//   final numberFormat = NumberFormat("#,##0", "id_ID");
//   final purchaseCart = <Cart>[].obs;
//   final returnCart = <Cart>[].obs;
//   final afterReturnCart = <Cart>[].obs;
//   final showChange = false.obs;
//   final showReturnFee = false.obs;
//   final totalChange = 0.obs;

// //! Detail Repayment
//   final repaymentCtrlText = TextEditingController();
//   void onPayChanged(String value, Invoice invoice) {
//     // int change = (invoice.change! * -1) - totalReturnFinal.value;
//     int valueInt = int.parse(value.isEmpty ? '0' : value.replaceAll('.', ''));
//     showChange.value = valueInt > invoice.payment!.debt!;
//     totalChange.value =
//         showChange.value ? invoice.payment!.debt! - valueInt : 0;
//     if (value.isNotEmpty) {
//       String newValue = numberFormat.format(valueInt);
//       if (newValue != repaymentCtrlText.text) {
//         repaymentCtrlText.value = TextEditingValue(
//           text: newValue,
//           selection: TextSelection.collapsed(offset: newValue.length),
//         );
//       }
//     }
//   }

//   void handleRepayment(Invoice invoice) async {
//     // int change = (invoice.change! * -1) - totalReturnFinal.value;
//     String pureRepaymentText = repaymentCtrlText.text.replaceAll('.', '');
//     if (repaymentCtrlText.text == '') pureRepaymentText = '0';
//     String title = '';
//     String middleText = '';

//     if (int.parse(pureRepaymentText) == 0) {
//       title = 'Ups';
//       middleText = 'Nominal tagihan belum di isi';
//     } else if (invoice.payment!.debt! > int.parse(pureRepaymentText)) {
//       title = 'Lanjutkan?';
//       middleText = 'Nominal tagihan tidak sesuai, lanjutkan?';
//     } else {
//       title = 'update';
//     }
//     if (title != 'update') {
//       await Get.defaultDialog(
//         title: title,
//         middleText: middleText,
//         confirm: TextButton(
//           onPressed: () async {
//             if (title == 'Lanjutkan?') {
//               title = 'update';
//             }
//             Get.back();
//           },
//           child: title == 'Ups' ? const Text('OK') : const Text('Lanjutkan'),
//         ),
//         cancel: title == 'Lanjutkan?'
//             ? TextButton(
//                 onPressed: () {
//                   Get.back();
//                 },
//                 child: const Text('Batal'),
//               )
//             : null,
//       );
//     }

//     if (title == 'update') {
//       await updateInvoicesRepayment(int.parse(pureRepaymentText), invoice);
//     }
//   }

//   Future updateInvoicesRepayment(int pay, Invoice invoice) async {
//     // int change = invoice.change! + pay;
//     // bool isCash = true;
//     try {
//       invoice.payment!.cash = invoice.payment!.cash! + pay;

//       // debugPrint((invoice.change! + returnFee.value).toString());
//       // debugPrint((invoice.change).toString());
//       // debugPrint(invoice.payment!.debt.toString());
//       invoiceServices.updateInvoice(invoice);

//       await Get.defaultDialog(
//         title: 'Berhasil',
//         middleText: 'Tagihan berhasil dibayar',
//         confirm: TextButton(
//           onPressed: () {
//             Get.back();
//             Get.back();
//             Get.back();
//           },
//           child: const Text('OK'),
//         ),
//       );
//     } on PostgrestException catch (e) {
//       Get.defaultDialog(
//         title: 'Error',
//         middleText: e.message,
//         confirm: TextButton(
//           onPressed: () => Get.back(),
//           child: const Text('OK'),
//         ),
//       );
//     }
//   }

//   //! EDIT DATA =====
//   //! Invoice Data
//   final id = ''.obs;

//   //! Customer Data
//   final customers = <Customer>[].obs;
//   // Rx<Customer?> selectedCustomer = Rx<Customer?>(null);
//   final displayName = ''.obs;
//   final isRegisteredCustomer = false.obs;

//   //! dateTime Data
//   final isDateTimeNow = true.obs;
//   final selectedDate = DateTime.now().obs;
//   final selectedTime = TimeOfDay.now().obs;
//   final displayDate = DateTime.now().toString().obs;
//   final displayTime = TimeOfDay.now().toString().obs;

//   //! Cart Data
//   final editPurchaseCart = <Cart>[].obs;
//   final editReturnCart = <Cart>[].obs;
//   final editAfterReturnCart = <Cart>[].obs;
//   final totalPurchase = 0.obs;
//   final totalDiscount = 0.obs;
//   final totalReturn = 0.obs;
//   final returnFee = 0.obs;
//   final totalReturnFinal = 0.obs;

//   //! EDIT FUNCTION =====
//   //! Customer Function
//   // final customerNameController = TextEditingController();
//   // final customerPhoneController = TextEditingController();
//   // final customerAddressController = TextEditingController();
//   // void handleCustomer(String value) {
//   //   isRegisteredCustomer.value = false;
//   //   selectedCustomer.value = null;
//   // }

//   // void registeredCustomerCheckBox(bool? value) {
//   //   isRegisteredCustomer.value = !isRegisteredCustomer.value;
//   // }

//   //! dateTime Function
//   void handleDate(BuildContext context) async {
//     // displayDate.value = selectedDate.value.toString();
//     Get.defaultDialog(
//       title: 'Ubah Tanggal',
//       backgroundColor: Colors.white,
//       content: SizedBox(
//         width: 400,
//         height: 350,
//         child: SfDateRangePicker(
//           headerStyle: DateRangePickerHeaderStyle(
//               backgroundColor: Colors.white,
//               textStyle: context.textTheme.bodyLarge),
//           showNavigationArrow: true,
//           backgroundColor: Colors.white,
//           monthViewSettings: const DateRangePickerMonthViewSettings(
//             firstDayOfWeek: 1,
//           ),
//           initialSelectedDate: selectedDate.value,
//           minDate: DateTime(2000),
//           maxDate: DateTime.now(),
//           showActionButtons: true,
//           cancelText: 'Batal',
//           onCancel: () => Get.back(),
//           onSubmit: (p0) {
//             selectedDate.value = p0 as DateTime;
//             displayDate.value = DateFormat('dd MMMM y', 'id').format(p0);
//             Get.back();
//           },
//         ),
//       ),
//     );
//   }

//   void handleTime(BuildContext context) async {
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: selectedTime.value,
//     );
//     if (pickedTime != null) selectedTime.value = pickedTime;
//     DateTime convertedTime = DateTime(
//         2024, 1, 1, selectedTime.value.hour, selectedTime.value.minute);
//     displayTime.value = DateFormat('HH:mm', 'id').format(convertedTime);
//   }

//   // void dateTimeCheckBox() async {
//   //   isDateTimeNow.value = !isDateTimeNow.value;
//   //   if (!isDateTimeNow.value) {
//   //     displayDate.value = '';
//   //     displayTime.value = '';
//   //   } else {
//   //     displayDate.value = DateTime.now().toString();
//   //     displayTime.value = TimeOfDay.now().toString();
//   //   }
//   //   selectedDate.value = DateTime.now();
//   //   selectedTime.value = TimeOfDay.now();
//   // }

//   // final addProduct = false.obs;
//   //! Cart Function
//   bool isBreak = false;
//   // bool isDisableButton = false;
//   void removeFromCart(List<Cart> targetCartList, Cart cart) {
//     if (editPurchaseCart.length > 1) {
//       targetCartList.remove(cart);
//     } else {
//       Get.defaultDialog(
//           title: 'Uups', middleText: 'Invoice tidak boleh kosong');
//       isBreak = true;
//     }
//   }

//   final returnFeeTextController = TextEditingController();
//   void returnFeeHandle(String value, Invoice invoice) {
//     int valueInt = int.parse((value.isEmpty) ? '0' : value.replaceAll('.', ''));
//     returnFee.value = valueInt;
//     updateCalculateData();
//     if (value.isNotEmpty) {
//       String newValue = numberFormat.format(valueInt);
//       showReturnFee.value = valueInt > 0;
//       if (newValue != returnFeeTextController.text) {
//         returnFeeTextController.value = TextEditingValue(
//           text: newValue,
//           selection: TextSelection.collapsed(offset: newValue.length),
//         );
//       }
//     }
//   }

//   void removeFromReturnCart(Cart productCart) {
//     editReturnCart.remove(productCart);
//   }

//   void quantityHandle(Cart productCart, int quantity) {
//     Cart newCart = productCart;
//     newCart.quantity = quantity;
//     updateCart(editPurchaseCart, newCart);

//     int indexEditReturnCart = editReturnCart.indexWhere(
//         (cart) => cart.product?.productId == productCart.product?.productId);

//     bool isIndexEditAfterReturnCart = indexEditReturnCart > -1;

//     int prevReturnQuantity = isIndexEditAfterReturnCart
//         ? editReturnCart[indexEditReturnCart].quantity!
//         : 0;

//     debugPrint(quantity.toString());
//     debugPrint(prevReturnQuantity.toString());
//     // if (isIndexEditAfterReturnCart) {
//     final newAfterReturnCart = Cart(
//       product: productCart.product,
//       quantity: quantity - prevReturnQuantity,
//       individualDiscount: productCart.individualDiscount,
//       bundleDiscount: productCart.bundleDiscount,
//     );
//     updateCart(editAfterReturnCart, newAfterReturnCart);
//     // } else {

//     // }
//   }

//   final qtyMoveCount = 0.obs;

//   void returnHandle(Cart productCart, int addValue) {
//     int indexeditAfterReturnCart = editAfterReturnCart.indexWhere(
//         (cart) => cart.product?.productId == productCart.product?.productId);
//     bool isIndexPurchaseExist = indexeditAfterReturnCart > -1;

//     int prevPurchaseQuantity = isIndexPurchaseExist
//         ? editAfterReturnCart[indexeditAfterReturnCart].quantity!
//         : 0;

//     int newPurchaseQuantity = prevPurchaseQuantity + addValue;

//     if (newPurchaseQuantity > 0) {
//       final purchaseCart = Cart(
//         product: productCart.product,
//         quantity: isIndexPurchaseExist ? prevPurchaseQuantity + addValue : 1,
//         individualDiscount: productCart.individualDiscount,
//         bundleDiscount: productCart.bundleDiscount,
//       );
//       updateCart(editAfterReturnCart, purchaseCart);
//     } else {
//       if (editAfterReturnCart.length <= 1) {
//         Get.defaultDialog(
//           title: 'Oops',
//           middleText: 'Invoice product tidak boleh kosong.',
//         );
//         return;
//       } else {
//         editAfterReturnCart.remove(productCart);
//         updateCalculateData();
//       }
//     }

//     // !==========

//     int indexEditReturnCart = editReturnCart.indexWhere(
//         (cart) => cart.product?.productId == productCart.product?.productId);
//     bool isIndexReturnExist = indexEditReturnCart > -1;

//     int prevReturnQuantity =
//         isIndexReturnExist ? editReturnCart[indexEditReturnCart].quantity! : 0;

//     int newReturnQuantity = prevReturnQuantity - addValue;

//     // debugPrint(newReturnQuantity.toString());

//     if (newReturnQuantity > 0) {
//       final returnCart = Cart(
//         product: productCart.product,
//         quantity: isIndexReturnExist ? prevReturnQuantity - addValue : 1,
//         individualDiscount: productCart.individualDiscount,
//         bundleDiscount: productCart.bundleDiscount,
//       );
//       updateCart(editReturnCart, returnCart);
//       // debugPrint(returnCart.quantity.toString());
//     } else {
//       editReturnCart.remove(productCart);
//       if (editReturnCart.isEmpty) {
//         returnFee.value = 0;
//       }
//       updateCalculateData();
//     }
//   }

//   final lastChangeDiscount = 0.obs;

//   void discountHandle(Cart productCart,
//       TextEditingController discountController, String value) {
//     if (value.isNotEmpty) {
//       String newValue =
//           numberFormat.format(int.parse(value.replaceAll('.', '')));
//       if (newValue != discountController.text) {
//         discountController.value = TextEditingValue(
//           text: newValue,
//           selection: TextSelection.collapsed(offset: newValue.length),
//         );
//       }
//     }

//     // int index = editPurchaseCart.indexWhere(
//     //     (cart) => cart.product?.productId == productCart.product?.productId);

//     int discount = value == '' ? 0 : int.parse(value);
//     Cart newCart = productCart;
//     newCart.individualDiscount = discount;
//     updateCart(editPurchaseCart, newCart);
//   }

//   final payTextController = TextEditingController();
//   Timer? debounce;
//   void onPayHandle(String value) {
//     if (value.isNotEmpty) {
//       String newValue =
//           numberFormat.format(int.parse(value.replaceAll('.', '')));
//       if (newValue != payTextController.text) {
//         payTextController.value = TextEditingValue(
//           text: newValue,
//           selection: TextSelection.collapsed(offset: newValue.length),
//         );
//       }
//     }

//     if (debounce?.isActive ?? false) debounce!.cancel();
//     debounce = Timer(const Duration(milliseconds: 500), () {
//       if (value == '') value = '0';
//       // debugPrint(
//       //     (int.parse(value.replaceAll('.', '')) - totalPurchase.value).toString());
//       totalChange.value =
//           (int.parse(value.replaceAll('.', '')) - totalPurchase.value);
//     });
//   }

//   @override
//   void dispose() {
//     debounce?.cancel();
//     super.dispose();
//   }

//   Future saveReturnInvoice(Invoice invoice) async {
//     try {
//       // invoice.cartList!.purchaseCart = editPurchaseCart;
//       invoice.cartList!.returnCart = editReturnCart;
//       invoice.cartList!.afterReturnCart = editAfterReturnCart;
//       invoice.payment!.returnFee = returnFee.value;
//       invoice.payment!.totalReturn = totalReturn.value;

//       int totalPurchaseAferReturn = editAfterReturnCart.fold(
//         0,
//         (prev, cart) =>
//             prev +
//             (cart.product!.sellPrice! * cart.quantity!) -
//             cart.individualDiscount!,
//       );

//       invoice.payment!.debt = (totalPurchaseAferReturn + returnFee.value);

//       debugPrint(totalPurchaseAferReturn.toString());
//       debugPrint(totalReturnFinal.value.toString());
//       debugPrint(invoice.payment!.totalPay.toString());
//       invoiceServices.updateInvoice(invoice);

//       await Get.defaultDialog(
//         title: 'Berhasil',
//         middleText: 'Return berhasil disimpan',
//         confirm: TextButton(
//           onPressed: () {
//             Get.back();
//             Get.back();
//             Get.back();
//           },
//           child: const Text('OK'),
//         ),
//       );
//     } on PostgrestException catch (e) {
//       Get.defaultDialog(
//         title: 'Error',
//         middleText: e.message,
//         confirm: TextButton(
//           onPressed: () => Get.back(),
//           child: const Text('OK'),
//         ),
//       );
//     }
//   }

//   Future saveInvoice(Invoice invoice) async {
//     try {
//       DateTime dateTime = DateTime(
//         selectedDate.value.year,
//         selectedDate.value.month,
//         selectedDate.value.day,
//         selectedTime.value.hour,
//         selectedTime.value.minute,
//       );
//       Timestamp timestampDateTime = Timestamp.fromDate(dateTime);
//       final payment = payTextController.text == ''
//           ? 0
//           : int.parse(payTextController.text.replaceAll('.', ''));

//       invoice.customer = customerInputFieldC.selectedCustomer.value;
//       invoice.createdAt = timestampDateTime;
//       invoice.cartList!.purchaseCart = editPurchaseCart;
//       invoice.cartList!.afterReturnCart = editAfterReturnCart;
//       invoice.payment!.totalBill = totalPurchase.value;
//       invoice.payment!.totalPay = payment;

//       int totalPurchaseAferReturn = editAfterReturnCart.fold(
//         0,
//         (prev, cart) =>
//             prev +
//             (cart.product!.sellPrice! * cart.quantity!) -
//             cart.individualDiscount!,
//       );

//       invoice.payment!.debt = (totalPurchaseAferReturn + returnFee.value);

//       // invoice.payment!.debt = (totalChange.value - totalReturn.value) >= 0;
//       // debugPrint(totalChange.value.toString());
//       // debugPrint(totalReturn.value.toString());
//       // debugPrint(returnFee.value.toString());
//       invoiceServices.updateInvoice(invoice);

//       await Get.defaultDialog(
//         title: 'Berhasil',
//         middleText: 'Invoice berhasil diubah',
//         confirm: TextButton(
//           onPressed: () {
//             Get.back();
//             Get.back();
//             Get.back();
//           },
//           child: const Text('OK'),
//         ),
//       );
//     } on PostgrestException catch (e) {
//       Get.defaultDialog(
//         title: 'Error',
//         middleText: e.message,
//         confirm: TextButton(
//           onPressed: () => Get.back(),
//           child: const Text('OK'),
//         ),
//       );
//     }
//   }

//   // Future saveInvoice() async {
//   //   final payment = payTextController.text == ''
//   //       ? 0
//   //       : int.parse(payTextController.text.replaceAll('.', ''));
//   //   final change = totalChange.value;
//   //   late final Customer customer;
//   //   DateTime dateTime = DateTime(
//   //     selectedDate.value.year,
//   //     selectedDate.value.month,
//   //     selectedDate.value.day,
//   //     selectedTime.value.hour,
//   //     selectedTime.value.minute,
//   //   ).subtract(const Duration(hours: 7));
//   //   if (selectedCustomer.value != null) {
//   //     customer = Customer(
//   //       id: selectedCustomer.value!.id,
//   //       customerId: selectedCustomer.value!.customerId,
//   //       name: selectedCustomer.value!.name,
//   //       phone: selectedCustomer.value!.phone,
//   //       address: selectedCustomer.value!.address,
//   //       uuid: selectedCustomer.value!.uuid,
//   //     );
//   //   } else {
//   //     customer = Customer(
//   //       name: customerNameController.text,
//   //       phone: customerPhoneController.text,
//   //       address: customerAddressController.text,
//   //       uuid: authService.uid.value,
//   //     );
//   //   }

//   //   // final Map<String, Object?> data = {
//   //   //   'created_at': dateTime.toIso8601String(),
//   //   //   'customer': customer,
//   //   //   'products_cart': ProductsCart(cartList: cartList).toJson(),
//   //   //   'products_return_cart': ProductsCart(cartList: cartListReturn).toJson(),
//   //   //   'bill': totalPurchase.value,
//   //   //   'pay': payment,
//   //   //   'return_fee': returnFee.value,
//   //   //   'change': change,
//   //   //   'is_paid': change > 0 ? true : false,
//   //   // };

//   //   Future success() async {
//   //     // invoiceServices.updateInvoice(newInvoice)
//   //     // List<Invoice> newData =
//   //     //     await InvoiceProvider.update(data, id.value, uuid);
//   //     // refreshFetch(newData);
//   //     return Get.defaultDialog(
//   //       title: 'Berhasil',
//   //       middleText: 'Invoice Edit berhasil disimpan.',
//   //       confirm: TextButton(
//   //         onPressed: () async {
//   //           purchaseCart.clear();
//   //           returnCart.clear();
//   //           // await resetToInitCartList();
//   //           payTextController.text = '';
//   //           totalChange.value = 0;
//   //           totalPurchase.value = 0;
//   //           totalDiscount.value = 0;
//   //           totalReturnFinal.value = 0;
//   //           Get.back();
//   //           Get.back();
//   //           Get.back();
//   //         },
//   //         child: const Text('OK'),
//   //       ),
//   //     );
//   //   }

//   //   Future validate(String validateCode) async {
//   //     Get.defaultDialog(
//   //       title: 'Ups',
//   //       middleText: validateCode == 'debt'
//   //           ? 'Total tagihan belum terpenuhi. lanjutkan?'
//   //           : 'Data Customer tidak lengkap. lanjutkan?',
//   //       confirm: TextButton(
//   //         onPressed: () async {
//   //           await success();
//   //           Get.back();
//   //         },
//   //         child: const Text('Simpan'),
//   //       ),
//   //       cancel: TextButton(
//   //         onPressed: () {
//   //           Get.back();
//   //         },
//   //         child: Text(
//   //           'Batal',
//   //           style: TextStyle(color: Colors.black.withOpacity(0.5)),
//   //         ),
//   //       ),
//   //     );
//   //   }

//   //   try {
//   //     (customerNameController.text == '' ||
//   //             customerPhoneController.text == '' ||
//   //             customerAddressController.text == '')
//   //         ? validate('Customer')
//   //         : change < 0
//   //             ? validate('debt')
//   //             : success();
//   //   } on PostgrestException catch (e) {
//   //     Get.defaultDialog(
//   //       title: 'Error',
//   //       middleText: e.message,
//   //       confirm: TextButton(
//   //         onPressed: () => Get.back(),
//   //         child: const Text('OK'),
//   //       ),
//   //     );
//   //   }
//   // }

//   ProductController productController = Get.put(ProductController());
//   void filterProducts(String productName) {
//     productController.filterProducts(productName);
//   }

//   void addToCart(Product product) {
//     editPurchaseCart.add(
//       Cart(
//         product: product,
//         quantity: 1,
//         individualDiscount: 0,
//         bundleDiscount: 0,
//       ),
//     );
//     updateCalculateData();
//   }

//   void initDetailInvoice(Invoice invoice) {
//     purchaseCart.clear();
//     purchaseCart.addAll(invoice.cartList!.purchaseCart!);

//     returnCart.clear();
//     if (invoice.cartList!.returnCart != null) {
//       returnCart.addAll(invoice.cartList!.returnCart!);
//     }

//     afterReturnCart.clear();
//     if (invoice.cartList!.afterReturnCart != null) {
//       afterReturnCart.addAll(invoice.cartList!.afterReturnCart!);
//     }

//     // selectedDate.value = invoice.createdAt!.toDate();
//     // selectedTime.value = TimeOfDay.fromDateTime(selectedDate.value);

//     resetEditData(invoice);

//     // totalReturn.value = returnCart.fold(
//     //   0,
//     //   (prev, cart) => prev + (cart.product!.sellPrice! * cart.quantity!),
//     // );

//     // int invoiceReturn = invoice.returnFee ?? 0;
//     // returnFee.value = invoiceReturn;
//     // totalReturnFinal.value = totalReturn.value - invoiceReturn;
//   }

//   void resetEditData(Invoice invoice) {
//     id.value = invoice.id!;

//     isRegisteredCustomer.value = invoice.customer!.customerId != null;

//     editPurchaseCart.clear();
//     for (var cart in invoice.cartList!.purchaseCart!) {
//       Cart newCart = Cart(
//         product: cart.product,
//         quantity: cart.quantity,
//         individualDiscount: cart.individualDiscount,
//         bundleDiscount: cart.individualDiscount,
//       );
//       editPurchaseCart.add(newCart);
//     }

//     // editPurchaseCart.addAll(purchaseCart);

//     editReturnCart.clear();
//     if (invoice.cartList!.returnCart != null) {
//       for (var cart in invoice.cartList!.returnCart!) {
//         Cart newCart = Cart(
//           product: cart.product,
//           quantity: cart.quantity,
//           individualDiscount: cart.individualDiscount,
//           bundleDiscount: cart.individualDiscount,
//         );
//         editReturnCart.add(newCart);
//       }
//     }

//     editAfterReturnCart.clear();
//     if (invoice.cartList!.afterReturnCart != null) {
//       for (var cart in invoice.cartList!.afterReturnCart!) {
//         Cart newCart = Cart(
//           product: cart.product,
//           quantity: cart.quantity,
//           individualDiscount: cart.individualDiscount,
//           bundleDiscount: cart.individualDiscount,
//         );
//         editAfterReturnCart.add(newCart);
//       }
//     } else {
//       for (var cart in invoice.cartList!.purchaseCart!) {
//         Cart newCart = Cart(
//           product: cart.product,
//           quantity: cart.quantity,
//           individualDiscount: cart.individualDiscount,
//           bundleDiscount: cart.individualDiscount,
//         );
//         editAfterReturnCart.add(newCart);
//       }
//     }
//     // editReturnCart.addAll(returnCart);
//     customerInputFieldC.asignCustomer(invoice.customer!);
//     // customerInputFieldC.customerNameController.text = invoice.customer!.name!;
//     // customerInputFieldC.customerPhoneController.text = invoice.customer!.phone!;
//     // customerInputFieldC.customerAddressController.text =
//     //     invoice.customer!.address!;
//     // customerInputFieldC.displayName.value =
//     //     invoice.customer!.customerId != null ? invoice.customer!.name! : '';

//     payTextController.text = currency.format(
//         invoice.payment!.totalPay! >= invoice.payment!.totalBill!
//             ? invoice.payment!.totalBill!
//             : invoice.payment!.totalPay!);
//     totalChange.value =
//         invoice.payment!.totalPay! >= invoice.payment!.totalBill!
//             ? 0
//             : invoice.payment!.totalPay! - invoice.payment!.totalBill!;
//     totalPurchase.value = invoice.payment!.totalBill!;

//     DateTime invoiceDateTime = invoice.createdAt!.toDate();

//     DateTime date = DateTime(
//       invoiceDateTime.year,
//       invoiceDateTime.month,
//       invoiceDateTime.day,
//       invoiceDateTime.hour,
//       invoiceDateTime.minute,
//     );

//     selectedDate.value = date;
//     displayDate.value =
//         DateFormat('dd MMMM y', 'id').format(selectedDate.value);

//     selectedTime.value = TimeOfDay.fromDateTime(date);
//     displayTime.value = DateFormat('HH:mm', 'id').format(date);

//     if (invoice.payment!.returnFee != null) {
//       returnFee.value = invoice.payment!.returnFee!;
//       totalReturnFinal.value = totalReturn.value - invoice.payment!.returnFee!;
//     }

//     updateCalculateData();

//     // totalReturn.value = editReturnCart.fold(
//     //   0,
//     //   (prev, cart) =>
//     //       prev +
//     //       (cart.product!.sellPrice! * cart.quantity!) -
//     //       cart.individualDiscount!,
//     // );
//   }

//   void updateCart(RxList<Cart> targetCartList, Cart newCart) {
//     int index = targetCartList.indexWhere(
//         (cart) => cart.product?.productId == newCart.product?.productId);

//     if (index > -1) {
//       targetCartList.replaceRange(index, index + 1, [newCart]);
//     } else {
//       targetCartList.add(newCart);
//     }

//     updateCalculateData();
//   }

//   updateCalculateData() {
//     // totalDiscount.value = 0;
//     // for (var editCart in editPurchaseCart) {
//     //   totalPurchase.value +=
//     //       ((editCart.product!.sellPrice! * editCart.quantity!) -
//     //           editCart.individualDiscount!);

//     //   totalDiscount.value += editCart.individualDiscount!;
//     // }
//     //! TotalReturn
//     totalReturn.value = editReturnCart.fold(
//       0,
//       (prev, cart) => prev + (cart.product!.sellPrice! * cart.quantity!),
//     );

//     //! TotalReturnFinal
//     totalReturnFinal.value = totalReturn.value - returnFee.value;

//     //! TotalHarga
//     totalPurchase.value = editPurchaseCart.fold(
//       0,
//       (prev, cart) =>
//           prev +
//           (cart.product!.sellPrice! * cart.quantity!) -
//           cart.individualDiscount!,
//     );

//     //! TotalDiskon
//     totalDiscount.value = editPurchaseCart.fold(
//       0,
//       (prev, cart) => prev + cart.individualDiscount!,
//     );

//     //! TotalKembalian
//     String payText =
//         payTextController.text == '' ? '0' : payTextController.text;
//     totalChange.value =
//         int.parse(payText.replaceAll('.', '')) - totalPurchase.value;
//   }

//   destroyHandle(Invoice invoice) async {
//     try {
//       Get.defaultDialog(
//         title: 'Error',
//         middleText: 'Hapus Invoice ini?',
//         confirm: TextButton(
//           onPressed: () async {
//             invoiceServices.deleteInvoice(invoice.id!);
//             // refreshFetch(await InvoiceProvider.destroy(invoice));
//             Get.back();
//             Get.back();
//           },
//           child: const Text('OK'),
//         ),
//         cancel: TextButton(
//           onPressed: () => Get.back(),
//           child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
//         ),
//       );
//     } on PostgrestException catch (e) {
//       Get.defaultDialog(
//         title: 'Error',
//         middleText: e.message,
//         confirm: TextButton(
//           onPressed: () => Get.back(),
//           child: const Text('OK'),
//         ),
//       );
//     }
//   }
// }
