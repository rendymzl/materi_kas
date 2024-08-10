import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../main.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/sales_invoice_model.dart';
import '../../../data/models/sales_model.dart';
import '../../../data/providers/product_services.dart';
import '../../../data/providers/sales_customer_services.dart';
import '../../../data/providers/sales_invoice_services.dart';
// import '../../../routes/app_pages.dart';
import '../../../widget/customer_input_field_controller.dart';
import '../../../widget/date_picker_controller.dart';
import '../../../widget/payment_controller.dart';

class BuyProductController extends GetxController {
  late ProductService productService = Get.find();
  late SalesCustomerServices salesCustomerSecvice = Get.find();
  late SalesInvoiceService salesInvoiceSecvice = Get.find();
  late CustomerInputFieldController customerInputFieldC =
      Get.put(CustomerInputFieldController());
  late PaymentController paymentController = Get.put(PaymentController());

  late final products = productService.products;
  late final foundProducts = productService.foundProducts;
  // final productsBySalesName = <Product>[].obs;
  // final foundProductsBySalesName = <Product>[].obs;
  late final sales = salesCustomerSecvice.customers;
  late final foundSales = salesCustomerSecvice.foundCustomers;
  late final invoices = salesInvoiceSecvice.invoices;
  late DatePickerController datePickerC = Get.find();
  final cart = Cart(items: <CartItem>[].obs).obs;

  Rx<Sales?> selectedSales = Rx<Sales?>(null);
  final salesTextC = TextEditingController();
  final showSuffixClear = false.obs;
  final GlobalKey textFieldKey = GlobalKey();

  final foundProductEdit = <Product>[].obs;
  List<Product> updatedStockProducts = [];

  final isComa = false.obs;

  // final currency = NumberFormat('#,##0', 'id_ID');

  // final reload = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => DatePickerController());
    Get.lazyPut(() => CustomerInputFieldController());
    filterProducts('');
    foundProductEdit.assignAll(foundProducts);
    // sortProductsBySales('');
  }

  void filterProducts(String productName) {
    productService.searchProducts(productName);
    // if (productName.isEmpty) {
    //   // List<Product> productsList = [];
    //   foundProductsBySalesName.clear();
    //   foundProductsBySalesName.addAll(productsBySalesName);
    // } else {
    //   foundProductsBySalesName.value = productsBySalesName.where((product) {
    //     return product.productName
    //         .toLowerCase()
    //         .contains(productName.toLowerCase());
    //   }).toList();
    // }
  }

  void filterSales(String salesName) {
    salesCustomerSecvice.searchCustomers(salesName);
  }

  void selectedSalesHandle(Sales sales) {
    selectedSales.value = sales;
    showSuffixClear.value = true;
    salesTextC.text = selectedSales.value!.name!;
    debugPrint(salesTextC.text);
    // productsBySalesName
    //     .assignAll(findProductsBySalesName(foundProducts, sales.name!));
    // filterProducts('');
  }

  // List<Product> findProductsBySalesName(
  //     List<Product> products, String salesName) {
  //   return products
  //       .where((product) =>
  //           product.sales?.name?.toLowerCase() == salesName.toLowerCase())
  //       .toList();
  // }

  late ScrollController scrollController = ScrollController();

  void clear() {
    showSuffixClear.value = false;
    selectedSales.value = null;
    salesTextC.text = '';
  }

  void addToCart(Product product) async {
    Product editProduct = Product.fromJson(product.toJson());

    CartItem newItem = CartItem(product: editProduct, quantity: 1);

    cart.value.addItem(newItem);

    final existingupdatedProducts =
        updatedStockProducts.firstWhereOrNull((item) => item.id == product.id);

    if (existingupdatedProducts != null) {
      existingupdatedProducts.stock.value -= 1;
    } else {
      Product newProduct = Product.fromJson(product.toJson());
      newProduct.stock.value = -1;

      CartItem newItem = CartItem(product: newProduct, quantity: 1);
      updatedStockProducts.add(newItem.product);
    }

    final qqq =
        updatedStockProducts.firstWhereOrNull((item) => item.id == product.id);

    debugPrint(qqq!.stock.value.toString());

    int index = cart.value.items
        .indexWhere((selectItem) => selectItem.product.id == product.id);

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

  void removeFromCart(CartItem cartItem) {
    cart.value.removeItem(cartItem.product.id);
    final existingProduct = updatedStockProducts
        .firstWhereOrNull((item) => item.id == cartItem.product.id);

    // cartItem.product.stock = cartItem.product.stock + cartItem.quantity.value;

    if (existingProduct != null) {
      existingProduct.stock.value = 0;
    }
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
            // invoiceId.value = await generateInvoice(selectedSales.value);
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
    // invoiceId.value = await generateInvoice(selectedSales.value);
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
  destroyHandle(SalesInvoice invoice) async {
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
  void quantityHandle(CartItem cartItem, String quantity) {
    double qty = double.tryParse(quantity) ?? 0;

    Product newProduct = Product.fromJson(cartItem.product.toJson());
    newProduct.stock.value = qty * -1;

    CartItem newItem = CartItem(product: newProduct, quantity: qty);

    final existingupdatedProducts = updatedStockProducts
        .firstWhereOrNull((item) => item.id == newItem.product.id);

    cart.value.updateQuantity(cartItem.product.id, qty);

    if (existingupdatedProducts != null) {
      existingupdatedProducts.stock = newItem.product.stock;
    } else {
      updatedStockProducts.add(cartItem.product);
    }

    final qqq = updatedStockProducts
        .firstWhereOrNull((item) => item.id == cartItem.product.id);

    debugPrint(qqq!.stock.value.toString());

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
  void costPriceHandle(
      String productId, TextEditingController costPriceTextC, String value) {
    if (value.isNotEmpty) {
      String newValue = currency.format(int.parse(value.replaceAll('.', '')));
      if (newValue != costPriceTextC.text) {
        costPriceTextC.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }

    double valueDouble = value == '' ? 0 : double.parse(value);

    cart.value.updateDiscount(productId, valueDouble);
    totalDiscount.value = cart.value.totalIndividualDiscount;
    totalBill.value = cart.value.getTotal(priceType.value);
  }

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

    double valueDouble = value == '' ? 0 : double.parse(value);

    cart.value.updateDiscount(productId, valueDouble);
    totalDiscount.value = cart.value.totalIndividualDiscount;
    totalBill.value = cart.value.getTotal(priceType.value);
  }

  //* calculating
  final priceType = 1.obs;
  final moneyChange = 0.0.obs;
  final totalBill = 0.0.obs;
  final totalDiscount = 0.0.obs;
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

  // Future<String> generateInvoice(Sales? customer) async {
  //   String clientCode =
  //       (customer != null) ? customer.salesId!.toUpperCase() : 'G';

  //   DateTime date = selectedDate.value;
  //   String year = date.year.toString().substring(2);
  //   String month = date.month.toString().padLeft(2, '0');
  //   String day = date.day.toString().padLeft(2, '0');

  //   String dateCode = '$clientCode$month$day$year';

  //   List<Invoice> result = invoices
  //       .where((element) => element.invoiceId!.contains(dateCode))
  //       .toList();

  //   int lastSerialNumber = result.length;
  //   lastSerialNumber++;

  //   String serialNumber = lastSerialNumber.toString().padLeft(3, '0');

  //   String invoiceNumber = 'INV$serialNumber/$dateCode';

  //   return invoiceNumber;
  // }

  final nomorInvoice = ''.obs;

  Future<SalesInvoice> createInvoice() async {
    late final Sales customer;
    DateTime dateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );

    Timestamp timestampDateTime = Timestamp.fromDate(dateTime);

    if (selectedSales.value != null) {
      customer = Sales(
        id: selectedSales.value!.id,
        salesId: selectedSales.value!.salesId,
        name: selectedSales.value!.name,
        phone: selectedSales.value!.phone,
        address: selectedSales.value!.address,
        // uuid: selectedSales.value!.uuid,
      );
    } else {
      customer = Sales(
        name: customerInputFieldC.customerNameController.text,
        phone: customerInputFieldC.customerPhoneController.text,
        address: customerInputFieldC.customerAddressController.text,
        // uuid: authService.uid.value,
      );
    }

    final invoice = SalesInvoice(
      invoiceId: nomorInvoice.value,
      createdAt: timestampDateTime,
      sales: customer,
      purchaseList: cart.value,
      priceType: priceType.value,
      discount: totalDiscount.value,
      payments: [],
      debtAmount: cart.value.getTotal(priceType.value),
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

    customerInputFieldC.clear();

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

  // Future<void> signOut() async {
  //   await authService.signOut();
  //   Get.offNamed(Routes.LOGIN);
  // }
}
