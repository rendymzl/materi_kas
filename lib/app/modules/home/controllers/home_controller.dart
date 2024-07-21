import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materi_kas/app/data/models/customer_model.dart';
import 'package:materi_kas/app/data/providers/customer_services.dart';
import 'package:materi_kas/app/data/providers/invoice_services.dart';
import 'package:materi_kas/app/modules/home/views/payment_dialog.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../data/models/cart_item_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/auth_services.dart';
import '../../../data/providers/product_services.dart';
import '../../../routes/app_pages.dart';
import '../../../widget/customer_input_field_controller.dart';
import '../../../widget/model/payment_controller.dart';

// enum PaymentMethod { cash, transfer }

class HomeController extends GetxController {
  late AuthService authService = Get.find();
  late ProductService productService = Get.find();
  late InvoiceService invoiceServices = Get.find();
  late CustomerServices customerServices = Get.find(); //! HAPUS NANTI
  final CustomerInputFieldController customerInputFieldC = Get.find();
  final PaymentController paymentController = Get.find();

  late final products = productService.products;
  late final foundProducts = productService.foundProducts;
  late final invoices = invoiceServices.invoices;
  // final cart = <Cart>[].obs;
  final cart = Cart(items: <CartItem>[].obs).obs;

  Rx<Customer?> selectedCustomer = Rx<Customer?>(null);

  final currency = NumberFormat('#,##0', 'id_ID');

  // final reload = 0.obs;

  @override
  void onInit() {
    super.onInit();
    productService.fetchProducts(); //! HAPUS NANTI
    customerServices.fetchCustomers(); //! HAPUS NANTI
    invoiceServices.fetchInvoices(); //! HAPUS NANTI
    filterProducts('');
  }

  void filterProducts(String productName) {
    productService.searchProducts(productName);
  }

  late ScrollController scrollController = ScrollController();

  void addToCart(Product product) async {
    // if (index != -1) {
    //   Cart productCart = Cart(
    //       product: product,
    //       quantity: cart[index].quantity! + 1,
    //       individualDiscount: 0,
    //       bundleDiscount: 0);

    //   cart.replaceRange(index, index + 1, [productCart]);

    // } else {
    //   Cart productCart = Cart(
    //       product: product,
    //       quantity: 1,
    //       individualDiscount: 0,
    //       bundleDiscount: 0);

    //   cart.add(productCart);

    CartItem newItem = CartItem(product: product, quantity: 1);

    cart.value.addItem(newItem);

    int index = cart.value.items
        .indexWhere((selectItem) => selectItem.product.id == product.id);

    debugPrint(index.toString());
    Future.delayed(const Duration(milliseconds: 50), () {
      scrollController.animateTo(
        index * 80.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    });

    totalBill.value = cart.value.getTotal(priceType.value);
    // Future.delayed(const Duration(milliseconds: 10), () {
    //   if (scrollController.hasClients) {
    //     scrollController.animateTo(
    //       scrollController.position.maxScrollExtent,
    //       duration: const Duration(milliseconds: 200),
    //       curve: Curves.easeInOut,
    //     );
    //   }
    // });

    // }
  }

  void removeFromCart(String productCart) {
    cart.value.removeItem(productCart);
    totalBill.value = cart.value.getTotal(priceType.value);
  }

  //! dateTime
  final isDateTimeNow = true.obs;
  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final displayDate = DateTime.now().toString().obs;
  final displayTime = TimeOfDay.now().toString().obs;

  void handleDate(BuildContext context) async {
    Get.defaultDialog(
      title: 'Pilih Tanggal',
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 400,
        height: 350,
        child: SfDateRangePicker(
          headerStyle: DateRangePickerHeaderStyle(
              backgroundColor: Colors.white,
              textStyle: context.textTheme.bodyLarge),
          showNavigationArrow: true,
          backgroundColor: Colors.white,
          monthViewSettings: const DateRangePickerMonthViewSettings(
            firstDayOfWeek: 1,
          ),
          initialSelectedDate: selectedDate.value,
          minDate: DateTime(2000),
          maxDate: DateTime.now(),
          showActionButtons: true,
          cancelText: 'Batal',
          onCancel: () => Get.back(),
          onSubmit: (p0) async {
            selectedDate.value = p0 as DateTime;
            displayDate.value = p0.toString();
            // invoiceId.value = await generateInvoice(selectedCustomer.value);
            Get.back();
          },
        ),
      ),
    );
  }

  void handleTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );

    selectedTime.value = pickedTime ?? TimeOfDay.now();
    displayTime.value = pickedTime.toString();
    // invoiceId.value = await generateInvoice(selectedCustomer.value);
  }

  void dateTimeCheckBox() async {
    isDateTimeNow.value = !isDateTimeNow.value;
    if (!isDateTimeNow.value) {
      displayDate.value = '';
      displayTime.value = '';
    } else {
      displayDate.value = DateTime.now().toString();
      displayTime.value = TimeOfDay.now().toString();
    }
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
  }

  void priceTypeHandleCheckBox(int type) async {
    priceType.value == type ? priceType.value = 1 : priceType.value = type;
    totalBill.value = cart.value.getTotal(priceType.value);
  }

  //! delete
  destroyHandle(Invoice invoice) async {
    try {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Hapus barang ini?',
        confirm: TextButton(
          onPressed: () async {
            await productService.deleteProduct(invoice.id!);
            Get.back();
          },
          child: const Text('OK'),
        ),
        cancel: TextButton(
          onPressed: () => Get.back(),
          child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
        ),
      );
    } on PostgrestException catch (e) {
      Get.defaultDialog(
        title: 'Error',
        middleText: e.message,
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }

  //! MoneyHandle
  //* quantity
  void quantityHandle(String productId, String quantity) {
    int qty = int.tryParse(quantity) ?? 0;
    cart.value.updateQuantity(productId, qty);
    totalBill.value = cart.value.getTotal(priceType.value);
  }
  // void quantityHandle(Cart productCart, String qty) {
  //   int index = cart.indexWhere((selectItem) =>
  //       selectItem.product?.productId == productCart.product?.productId);

  //   int qtyParse = qty == '' ? 0 : int.parse(qty);
  //   productCart.quantity = qtyParse;
  //   cart.replaceRange(index, index + 1, [productCart]);
  // }

  //* discount
  // final payTextC = TextEditingController();
  // final numberFormat = NumberFormat("#,##0", "id_ID");
  void discountHandle(String productId,
      TextEditingController discountController, String value) {
    if (value.isNotEmpty) {
      String newValue = currency.format(int.parse(value.replaceAll('.', '')));
      if (newValue != discountController.text) {
        discountController.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }

    int valueInt = value == '' ? 0 : int.parse(value);

    cart.value.updateDiscount(productId, valueInt);
    totalDiscount.value = cart.value.totalIndividualDiscount;
    totalBill.value = cart.value.getTotal(priceType.value);

    // int index = cart.indexWhere((selectItem) =>
    //     selectItem.product?.productId == productCart.product?.productId);

    // int discountParse = value == '' ? 0 : int.parse(value);
    // productCart.individualDiscount = discountParse;
    // cart.replaceRange(index, index + 1, [productCart]);
  }

  //* calculating
  final priceType = 1.obs;
  final moneyChange = 0.obs;
  final totalBill = 0.obs;
  final totalDiscount = 0.obs;
  // final isCash = true.obs;
  // final cash = 0.obs;
  // final transfer = 0.obs;
  // final totalPay = 0.obs;

  Timer? debounce;

  // void onPayChanged(String value) {
  //   if (value.isNotEmpty) {
  //     String newValue =
  //         numberFormat.format(int.parse(value.replaceAll('.', '')));
  //     if (newValue != payTextC.text) {
  //       payTextC.value = TextEditingValue(
  //         text: newValue,
  //         selection: TextSelection.collapsed(offset: newValue.length),
  //       );
  //     }
  //   }

  //   if (debounce?.isActive ?? false) debounce!.cancel();
  //   debounce = Timer(const Duration(milliseconds: 500), () {
  //     moneyChange.value =
  //         value == '' ? 0 : int.parse(value.replaceAll('.', ''));
  //   });
  // }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  final displayName = ''.obs;
  // final customerNameController = customerInputFieldC;
  // final customerPhoneController = customerInputFieldC;
  // final customerAddressController = customerInputFieldC;

  // final invoiceId = ''.obs;

  // String getLastSerialNumber(Invoice invoice) {
  //   String? invoiceNumber = invoice.invoiceId;
  //   Timestamp? invoiceDate = invoice.createdAt!;
  //   String serialPart = '000';
  //   if (invoiceNumber != null) {
  //     List<String> parts = invoiceNumber.split('/');
  //     DateTime invoiceDateTime = invoiceDate.toDate();
  //     DateTime selected = selectedDate.value;
  //     if (parts.length == 2 &&
  //         invoiceDateTime.year == selected.year &&
  //         invoiceDateTime.month == selected.month &&
  //         invoiceDateTime.day == selected.day) {
  //       serialPart = parts[0].replaceAll('INV', '');
  //       serialPart = serialPart.replaceFirst(RegExp('^0+'), '');

  //       return serialPart;
  //     }
  //   }

  //   return serialPart;
  // }

  Future<String> generateInvoice(Customer? customer) async {
    String clientCode =
        (customer != null) ? customer.customerId!.toUpperCase() : 'G';

    DateTime date = selectedDate.value;
    String year = date.year.toString().substring(2);
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');

    String dateCode = '$clientCode$month$day$year';

    List<Invoice> result = invoices
        .where((element) => element.invoiceId!.contains(dateCode))
        .toList();

    int lastSerialNumber = result.length;
    lastSerialNumber++;

    String serialNumber = lastSerialNumber.toString().padLeft(3, '0');

    String invoiceNumber = 'INV$serialNumber/$dateCode';

    return invoiceNumber;
  }

  Future<Invoice> createInvoice() async {
    late final Customer customer;
    DateTime dateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );

    Timestamp timestampDateTime = Timestamp.fromDate(dateTime);

    if (selectedCustomer.value != null) {
      customer = Customer(
        id: selectedCustomer.value!.id,
        customerId: selectedCustomer.value!.customerId,
        name: selectedCustomer.value!.name,
        phone: selectedCustomer.value!.phone,
        address: selectedCustomer.value!.address,
        // uuid: selectedCustomer.value!.uuid,
      );
    } else {
      customer = Customer(
        name: customerInputFieldC.customerNameController.text,
        phone: customerInputFieldC.customerPhoneController.text,
        address: customerInputFieldC.customerAddressController.text,
        // uuid: authService.uid.value,
      );
    }

    final invoice = Invoice(
      invoiceId: await generateInvoice(selectedCustomer.value),
      createdAt: timestampDateTime,
      customer: customer,
      purchaseList: cart.value.items,
      priceType: priceType.value,
      discount: totalDiscount.value,
      payments: [],
      debtAmount: cart.value.getTotal(priceType.value),
      // debtAmount: cart.value.getTotal(priceType.value) - payment.amountPaid,
      // isDebtPaid: payment.amountPaid > cart.value.getTotal(priceType.value)
      // payment: Payment(
      //   totalBill: totalBill.value,
      //   totalDiscount: totalDiscount.value,
      //   cash: cash.value,
      //   transfer: transfer.value,
      //   totalPay: totalPay.value,
      //   debt: debt,
      // ),
      // uuid: authService.uid.value,
    );

    return invoice;
  }

  void resetData() {
    cart.value.items.clear();
    // payTextC.text = '';
    moneyChange.value = 0;
    totalBill.value = 0;
    totalDiscount.value = 0;
    // cash.value = 0;
    // transfer.value = 0;
    // totalPay.value = 0;

    customerInputFieldC.resetCustomerField();

    displayDate.value = DateTime.now().toString();
    displayTime.value = TimeOfDay.now().toString();

    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
  }

  // Future<void> saveInvoice(Invoice invoice) async {
  //   Future success() async {
  //     Map<String, Map<String, dynamic>> invoicesMap = {};
  //     String newInvioceId = await productService.getId();
  //     invoice.id = newInvioceId;
  //     invoicesMap[newInvioceId] = invoice.toJson();
  //     Get.defaultDialog(
  //       title: 'Menyimpan Invoice...',
  //       content: const CircularProgressIndicator(),
  //       barrierDismissible: false,
  //     );
  //     try {
  //       await invoiceServices.addInvoices(invoicesMap);
  //       Get.back();
  //       return Get.defaultDialog(
  //         title: 'Berhasil',
  //         middleText: 'Invoice berhasil disimpan.',
  //         confirm: TextButton(
  //           onPressed: () {
  //             cart.value.items.clear();
  //             // payTextC.text = '';
  //             moneyChange.value = 0;
  //             totalBill.value = 0;
  //             totalDiscount.value = 0;
  //             // cash.value = 0;
  //             // transfer.value = 0;
  //             // totalPay.value = 0;

  //             customerInputFieldC.resetCustomerField();

  //             displayDate.value = DateTime.now().toString();
  //             displayTime.value = TimeOfDay.now().toString();

  //             selectedDate.value = DateTime.now();
  //             selectedTime.value = TimeOfDay.now();
  //             Get.back();
  //             Get.back();
  //           },
  //           child: const Text('OK'),
  //         ),
  //       );
  //     } catch (e) {
  //       Get.back();
  //       Get.defaultDialog(
  //         title: 'Gagal Menyimpan Invoice!',
  //         middleText: e.toString(),
  //         barrierDismissible: false,
  //       );
  //     }
  //   }

  //   Future validate(String validateCode) async {
  //     Get.defaultDialog(
  //       title: 'Ups',
  //       middleText: validateCode == 'debt'
  //           ? 'Total tagihan belum terpenuhi. lanjutkan?'
  //           : 'Data Customer tidak lengkap. lanjutkan?',
  //       confirm: TextButton(
  //         onPressed: () async {
  //           await success();
  //           Get.back();
  //         },
  //         child: const Text('Simpan'),
  //       ),
  //       cancel: TextButton(
  //         onPressed: () {
  //           Get.back();
  //         },
  //         child: Text(
  //           'Batal',
  //           style: TextStyle(color: Colors.black.withOpacity(0.5)),
  //         ),
  //       ),
  //     );
  //   }

  //   try {
  //     debugPrint('clicked');
  //     (customerInputFieldC.customerNameController.text == '' ||
  //             customerInputFieldC.customerPhoneController.text == '' ||
  //             customerInputFieldC.customerAddressController.text == '')
  //         ? validate('Customer')
  //         : moneyChange.value < 0
  //             ? validate('debt')
  //             : success();
  //   } on PostgrestException catch (e) {
  //     Get.defaultDialog(
  //       title: 'Error',
  //       middleText: e.message,
  //       confirm: TextButton(
  //         onPressed: () => Get.back(),
  //         child: const Text('OK'),
  //       ),
  //     );
  //   }
  // }

  Future<void> signOut() async {
    await authService.signOut();
    Get.offNamed(Routes.LOGIN);
  }
}
