import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../main.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/invoice_provider.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../product/controllers/product_controller.dart';

class InvoiceController extends GetxController {
  // HomeController homeController = Get.put(HomeController());
  late final String uuid;
  late final List<Invoice> invoiceList = <Invoice>[].obs;
  final foundInvoices = <Invoice>[].obs;

  @override
  void onInit() async {
    super.onInit();
    uuid = supabase.auth.currentUser!.id;
    foundProducts.value = productList;
    customers.value = customerList;
    List<Invoice> newData = await InvoiceProvider.fetchData(uuid);
    refreshFetch(newData);
  }

  //! Fetch
  void refreshFetch(List<Invoice> newData) async {
    invoiceList.clear();
    invoiceList.assignAll(newData);
    foundInvoices.value = invoiceList;
  }

  // final disabledButton = true.obs;
  final numberFormat = NumberFormat("#,##0", "id_ID");
  final showChange = false.obs;
  final totalCharge = 0.obs;

  void onPayChanged(String value, TextEditingController pay, Invoice invoice) {
    if (value == '') value = '0';
    int charge = invoice.change! * -1;
    int valueInt = int.parse(value.replaceAll('.', ''));
    totalCharge.value = valueInt - charge;
    if (value.isNotEmpty) {
      String newValue = numberFormat.format(valueInt);
      valueInt > charge ? showChange.value = true : showChange.value = false;
      if (newValue != pay.text) {
        pay.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }
  }

  void handleRepayment(Invoice invoice, TextEditingController pay) async {
    int change = invoice.change! * -1;
    String newValue = pay.text.replaceAll('.', '');
    if (pay.text == '') newValue = '0';
    String title = '';
    String middleText = '';

    if (int.parse(newValue) == 0) {
      title = 'Ups';
      middleText = 'Nominal tagihan belum di isi';
    } else if (change > int.parse(newValue)) {
      title = 'Lanjutkan?';
      middleText = 'Nominal tagihan tidak sesuai, lanjutkan?';
    } else {
      title = 'update';
    }
    if (title != 'update') {
      await Get.defaultDialog(
        title: title,
        middleText: middleText,
        confirm: TextButton(
          onPressed: () async {
            if (title == 'Lanjutkan?') {
              title = 'update';
            }
            Get.back();
          },
          child: title == 'Ups' ? const Text('OK') : const Text('Lanjutkan'),
        ),
        cancel: title == 'Lanjutkan?'
            ? TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Batal'),
              )
            : null,
      );
    }

    if (title == 'update') {
      await updateInvoices(int.parse(newValue), invoice);
    }
  }

  Future updateInvoices(int pay, Invoice invoice) async {
    int change = invoice.change! + pay;
    try {
      Map<String, Object?> data = {
        'pay': invoice.pay! + pay,
        'change': change,
        'is_paid': change >= 0,
        'owner_id': invoice.uuid
      };
      List<Invoice> newData =
          await InvoiceProvider.update(data, invoice.id!, uuid);
      refreshFetch(newData);
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Tagihan berhasil dibayar',
        confirm: TextButton(
          onPressed: () {
            Get.back();
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
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

  //! Edit
  // final init = true.obs;
  CustomerController customerController = Get.put(CustomerController());
  late final customerList = customerController.customerList;
  final customers = <Customer>[].obs;
  Rx<Customer?> selectedCustomer = Rx<Customer?>(null);
  final customerNameController = TextEditingController();
  final displayName = ''.obs;
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();
  final isRegisteredCustomer = false.obs;
  final cartList = <Cart>[].obs;
  // final moneyChange = 0.obs;
  final totalPrice = 0.obs;
  final totalDiscount = 0.obs;
  ScrollController scrollController = ScrollController();
  final invoiceId = ''.obs;
  final id = ''.obs;
  final addProduct = false.obs;

  //! dateTime
  final isDateTimeNow = true.obs;
  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final displayDate = DateTime.now().toString().obs;
  final displayTime = TimeOfDay.now().toString().obs;

  void handleDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
    );

    selectedDate.value = pickedDate ?? DateTime.now();
    displayDate.value = pickedDate.toString();
  }

  void handleTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );

    selectedTime.value = pickedTime ?? TimeOfDay.now();
    displayTime.value = pickedTime.toString();
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

  void handleCustomer(String value) {
    isRegisteredCustomer.value = false;
    selectedCustomer.value = null;
  }

  void handleCheckBox(bool? value) {
    isRegisteredCustomer.value = !isRegisteredCustomer.value;

    customerNameController.text = '';
    customerPhoneController.text = '';
    customerAddressController.text = '';
    selectedCustomer.value = null;
    displayName.value = '';
  }

  void removeFromCart(Cart productCart) {
    productCart.quantity = 1;
    cartList.remove(productCart);

    int payValue = 0;
    payTextController.text == ''
        ? payValue = 0
        : payValue = int.parse(payTextController.text.replaceAll('.', ''));
    totalCharge.value =
        payValue - (totalPrice.value - productCart.product!.sellPrice!);
  }

  void quantityHandle(Cart productCart, String qty) {
    int index = cartList.indexWhere(
        (selectItem) => selectItem.product?.id == productCart.product?.id);

    int qtyParse = qty == '' ? 0 : int.parse(qty);
    productCart.quantity = qtyParse;
    cartList.replaceRange(index, index + 1, [productCart]);
  }

  final payTextController = TextEditingController();
  void discountHandle(Cart productCart,
      TextEditingController discountController, String value) {
    if (value.isNotEmpty) {
      String newValue =
          numberFormat.format(int.parse(value.replaceAll('.', '')));
      if (newValue != discountController.text) {
        discountController.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }

    int index = cartList.indexWhere(
        (selectItem) => selectItem.product?.id == productCart.product?.id);

    int discountParse = value == '' ? 0 : int.parse(value);
    productCart.individualDiscount = discountParse;
    cartList.replaceRange(index, index + 1, [productCart]);
  }

  Timer? debounce;
  void onPayHandle(String value) {
    if (value.isNotEmpty) {
      String newValue =
          numberFormat.format(int.parse(value.replaceAll('.', '')));
      if (newValue != payTextController.text) {
        payTextController.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }

    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      if (value == '') value = '0';
      totalCharge.value =
          int.parse(value.replaceAll('.', '')) - totalPrice.value;
    });
  }

  Future saveInvoice() async {
    final payment = payTextController.text == ''
        ? 0
        : int.parse(payTextController.text.replaceAll('.', ''));
    final change = totalCharge.value;
    late final Customer customer;
    DateTime dateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );
    if (selectedCustomer.value != null) {
      customer = Customer(
        id: selectedCustomer.value!.id,
        customerId: selectedCustomer.value!.customerId,
        name: selectedCustomer.value!.name,
        phone: selectedCustomer.value!.phone,
        address: selectedCustomer.value!.address,
        uuid: selectedCustomer.value!.uuid,
      );
    } else {
      customer = Customer(
        name: customerNameController.text,
        phone: customerPhoneController.text,
        address: customerAddressController.text,
        uuid: uuid,
      );
    }

    final Map<String, Object?> data = {
      'created_at': dateTime.toIso8601String(),
      'customer': customer,
      'products_cart': ProductsCart(cartList: cartList).toJson(),
      'bill': totalPrice.value,
      'pay': payment,
      'change': change,
      'is_paid': change > 0 ? true : false,
    };

    Future success() async {
      List<Invoice> newData =
          await InvoiceProvider.update(data, id.value, uuid);
      refreshFetch(newData);
      return Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Invoice Edit berhasil disimpan.',
        confirm: TextButton(
          onPressed: () {
            cartList.clear();
            payTextController.text = '';
            totalCharge.value = 0;
            totalPrice.value = 0;
            totalDiscount.value = 0;
            Get.back();
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    }

    Future validate(String validateCode) async {
      Get.defaultDialog(
        title: 'Ups',
        middleText: validateCode == 'debt'
            ? 'Total tagihan belum terpenuhi. lanjutkan?'
            : 'Data Customer tidak lengkap. lanjutkan?',
        confirm: TextButton(
          onPressed: () async {
            await success();
            Get.back();
          },
          child: const Text('Simpan'),
        ),
        cancel: TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ),
      );
    }

    try {
      (customerNameController.text == '' ||
              customerPhoneController.text == '' ||
              customerAddressController.text == '')
          ? validate('Customer')
          : change < 0
              ? validate('debt')
              : success();
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

  ProductController productController = Get.put(ProductController());
  late final productList = productController.productList;
  final foundProducts = <Product>[].obs;
  void filterProducts(String productName) {
    // var result = <Product>[];
    productController.filterProducts(productName);

    // productName.isEmpty
    //     ? result = productList
    //     : result = productList
    //         .where((product) => product.productName
    //             .toString()
    //             .toLowerCase()
    //             .contains(productName))
    //         .toList();

    // foundProducts.value = result;
  }

  void addToCart(Product product) {
    // invoiceId.value = generateInvoice(selectedCustomer.value);
    int index = cartList
        .indexWhere((selectItem) => selectItem.product?.id == product.id);

    if (index != -1) {
      Cart productCart = Cart(
          product: product,
          quantity: cartList[index].quantity! + 1,
          individualDiscount: 0,
          bundleDiscount: 0);

      cartList.replaceRange(index, index + 1, [productCart]);

      Future.delayed(const Duration(milliseconds: 1), () {
        scrollController.animateTo(
          index * 80.0,
          // scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });
    } else {
      Cart productCart = Cart(
          product: product,
          quantity: 1,
          individualDiscount: 0,
          bundleDiscount: 0);

      cartList.add(productCart);

      Future.delayed(const Duration(milliseconds: 10), () {
        scrollController.animateTo(
          // index * 80.0,
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });
    }
    int payValue = 0;
    payTextController.text == ''
        ? payValue = 0
        : payValue = int.parse(payTextController.text.replaceAll('.', ''));
    totalCharge.value = payValue - (totalPrice.value + product.sellPrice!);
  }

  // void filterProducts(String productName) {
  //   var result = <Invoice>[];
  //   productName.isEmpty
  //       ? result = invoiceList
  //       : result = invoiceList
  //           .where((invoice) => invoice.productsCart!.cartList
  //               .toString()
  //               .toLowerCase()
  //               .contains(productName))
  //           .toList();

  //   foundProducts.value = result;
  // }

  // void filterProducts(String productName) {
  //   var result = <Invoice>[];
  //   productName.isEmpty
  //       ? result = invoiceList
  //       : result = invoiceList
  //           .where((product) => product.productName
  //               .toString()
  //               .toLowerCase()
  //               .contains(productName))
  //           .toList();

  //   foundProducts.value = result;
  // }

  destroyHandle(Invoice invoice) async {
    try {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Hapus Invoice ini?',
        confirm: TextButton(
          onPressed: () async {
            refreshFetch(await InvoiceProvider.destroy(invoice));
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
}
