import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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
  final initInvoices = <Invoice>[].obs;

  @override
  void onInit() async {
    super.onInit();
    uuid = supabase.auth.currentUser!.id;
    foundProducts.value = productList;
    customers.value = customerList;
    List<Invoice> newData = await InvoiceProvider.fetchData(uuid, null);
    refreshFetch(newData);
  }

  final loadingInvoiceDisplay = false.obs;

  Future<void> resetToInitCartList() async {
    // List<Invoice> newData = await InvoiceProvider.fetchData(uuid, null);
    // refreshFetch(newData);
    cartList.value = initCartList
        .map((cart) => Cart(
              product: cart.product,
              quantity: cart.quantity,
              individualDiscount: cart.individualDiscount,
              bundleDiscount: cart.bundleDiscount,
            ))
        .toList();
    cartListReturn.value = initCartListReturn
        .map((cart) => Cart(
              product: cart.product,
              quantity: cart.quantity,
              individualDiscount: cart.individualDiscount,
              bundleDiscount: cart.bundleDiscount,
            ))
        .toList();
  }

  //! Fetch
  void refreshFetch(List<Invoice> newData) async {
    invoiceList.clear();
    invoiceList.assignAll(newData);
  }

  //! Filtered Display
  final startFilteredDate = ''.obs;
  final endFilteredDate = ''.obs;
  final displayFilteredDate = ''.obs;
  final dateIsSelected = false.obs;
  final selectedFilteredDate = DateTime.now().obs;

  handleFilteredDate(BuildContext context) {
    startFilteredDate.value = '';
    endFilteredDate.value = '';
    displayFilteredDate.value = '';
    Get.defaultDialog(
      title: 'Pilih Tanggal',
      backgroundColor: Colors.white,
      content: Column(
        children: [
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$startFilteredDate',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Text('sampai',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(
                  '$endFilteredDate',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            );
          }),
          SizedBox(
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
              initialSelectedDate: selectedFilteredDate.value,
              selectionMode: DateRangePickerSelectionMode.range,
              minDate: DateTime(2000),
              maxDate: DateTime.now(),
              showActionButtons: true,
              cancelText: 'Batal',
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                startFilteredDate.value =
                    DateFormat('dd MMMM y', 'id').format(args.value.startDate!);
                if (args.value.endDate != null) {
                  endFilteredDate.value =
                      DateFormat('dd MMMM y', 'id').format(args.value.endDate!);
                }
              },
              onCancel: () => Get.back(),
              onSubmit: (value) {
                if (value is PickerDateRange) {
                  if (value.endDate != null) {
                    final newSelectedPickerRange = PickerDateRange(
                        value.startDate,
                        value.endDate!.add(const Duration(days: 1)));

                    selectedFilteredDate.value =
                        newSelectedPickerRange.startDate!;
                    displayFilteredDate.value =
                        '$startFilteredDate sampai $endFilteredDate';
                    filterInvoices(newSelectedPickerRange);
                    dateIsSelected.value = true;
                    Get.back();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void clearHandle() async {
    dateIsSelected.value = false;
    startFilteredDate.value = '';
    endFilteredDate.value = '';
    displayFilteredDate.value = '';
    List<Invoice> newData = await InvoiceProvider.fetchData(uuid, null);
    refreshFetch(newData);
  }

  Timer? debounce;
  void filterInvoices(PickerDateRange invoiceDateRange) async {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 200), () async {
      List<Invoice> newData =
          await InvoiceProvider.fetchData(uuid, invoiceDateRange);
      refreshFetch(newData);
    });
  }

  final numberFormat = NumberFormat("#,##0", "id_ID");
  final showChange = false.obs;
  final showReturnFee = false.obs;
  final totalCharge = 0.obs;

  void onPayChanged(String value, TextEditingController pay, Invoice invoice) {
    int charge = invoice.change! * -1;
    int valueInt = int.parse((value.isEmpty) ? '0' : value.replaceAll('.', ''));
    totalCharge.value = valueInt - charge;
    if (value.isNotEmpty) {
      String newValue = numberFormat.format(valueInt);
      showChange.value = valueInt > charge;
      if (newValue != pay.text) {
        pay.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }
  }

  final returnFeeTextController = TextEditingController();
  void returnFeeHandle(String value, Invoice invoice) {
    int valueInt = int.parse((value.isEmpty) ? '0' : value.replaceAll('.', ''));
    returnFee.value = valueInt;
    totalReturn.value = totalReturnPrice.value - valueInt;
    if (value.isNotEmpty) {
      String newValue = numberFormat.format(valueInt);
      showReturnFee.value = valueInt > 0;
      if (newValue != returnFeeTextController.text) {
        returnFeeTextController.value = TextEditingValue(
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
  final initCartList = <Cart>[].obs;
  final cartListReturn = <Cart>[].obs;
  final initCartListReturn = <Cart>[].obs;
  // final moneyChange = 0.obs;
  final totalPrice = 0.obs;
  final totalReturnPrice = 0.obs;
  final totalReturn = 0.obs;
  final totalDiscount = 0.obs;
  final returnFee = 0.obs;
  // ScrollController scrollController = ScrollController();
  final invoiceId = ''.obs;
  final id = ''.obs;
  final addProduct = false.obs;
  // final maxHeightList = 500.obs;

  //! dateTime
  final isDateTimeNow = true.obs;
  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final displayDate = DateTime.now().toString().obs;
  final displayTime = TimeOfDay.now().toString().obs;

  void handleDate(BuildContext context) async {
    displayDate.value = selectedDate.value.toString();
    Get.defaultDialog(
      title: 'Ubah Tanggal',
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
          onSubmit: (p0) {
            selectedDate.value = p0 as DateTime;
            displayDate.value = p0.toString();
            Get.back();
          },
          // onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {

          // },
        ),
      ),
      // debugPrint('current ${selectedDate.value}');
      // debugPrint('==================');
      // DateTime? pickedDate = await showDatePickerDialog(
      //   context: context,
      //   initialDate: selectedDate.value,
      //   selectedDate: selectedDate.value,
      //   minDate: DateTime(2000),
      //   maxDate: DateTime.now(),
      // locale: const Locale('id', 'ID'),
    );

    // selectedDate.value = pickedDate ?? DateTime.now();
    // displayDate.value = pickedDate.toString();
  }

  void handleTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );
    if (pickedTime != null) selectedTime.value = pickedTime;
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

  bool isStop = false;
  void removeFromCart(Cart productCart) {
    if (cartList.length > 1) {
      // productCart.quantity = 1;
      cartList.remove(productCart);
      int payValue = 0;
      payTextController.text == ''
          ? payValue = 0
          : payValue = int.parse(payTextController.text.replaceAll('.', ''));
      totalCharge.value =
          payValue - (totalPrice.value - productCart.product!.sellPrice!);
    } else {
      Get.snackbar('Uups', 'Invoice tidak boleh kosong',
          colorText: Colors.white);
      isStop = true;
      debugPrint('1 ${totalReturnPrice.value}');
    }
  }

  void removeFromReturnCart(Cart productCart) {
    cartListReturn.remove(productCart);
  }

  // void quantityReturnHandleDialog(Cart productCart) {
  //   final TextEditingController qtyController = TextEditingController();
  //   qtyController.text = '${productCart.quantity}';
  //   Get.defaultDialog(
  //     title: 'Masukkan Jumlah Return',
  //     content: TextField(
  //       controller: qtyController,
  //       decoration: const InputDecoration(
  //         labelText: 'Jumlah',
  //         border: OutlineInputBorder(),
  //       ),
  //       keyboardType: TextInputType.number,
  //       inputFormatters: [
  //         FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
  //         TextInputFormatter.withFunction(
  //           (oldValue, newValue) =>
  //               newValue.text.length > productCart.quantity.toString().length
  //                   ? oldValue
  //                   : newValue,
  //         ),
  //       ],
  //     ),
  //     onConfirm: () {
  //       int qtyReturn = int.parse(qtyController.text);
  //       int qtyRemain = productCart.quantity! - int.parse(qtyController.text);
  //       if (qtyReturn > 0 && qtyReturn <= productCart.quantity!) {
  //         quantityReturnHandle(productCart, qtyController.text);
  //         quantityHandle(productCart, qtyRemain.toString());
  //         Get.back();
  //       } else {
  //         Get.snackbar('Error',
  //             'Jumlah harus lebih dari 0 dan tidak boleh lebih dari ${productCart.quantity}',
  //             colorText: Colors.white);
  //       }
  //     },
  //   );
  // }

  // void returnProduct(Cart productCart) {
  //   if (cartList.length > 1) {
  //     cartListReturn.add(productCart);
  //     cartList.remove(productCart);
  //   } else {
  //     Get.snackbar('Uups', 'Cart list tidak boleh kosong',
  //         colorText: Colors.white);
  //   }
  // }

  void quantityHandle(Cart productCart, int qty) {
    int index = cartList.indexWhere(
        (selectItem) => selectItem.product?.id == productCart.product?.id);

    productCart.quantity = qty;
    cartList.replaceRange(index, index + 1, [productCart]);
  }

  final qtyMoveCount = 0.obs;

  void returnHandle(Cart productCart, bool isAddToReturn) {
    isStop = false;

    if (isAddToReturn) {
      addToCart(productCart, -1);
      debugPrint('2 ${totalReturnPrice.value}');
      if (isStop) {
        return;
      } else {
        addToReturnCart(productCart, 1);
        totalReturnPrice.value += productCart.product!.sellPrice!;
        totalReturn.value += productCart.product!.sellPrice!;
        qtyMoveCount.value++;
      }
    } else {
      addToReturnCart(productCart, -1);
      addToCart(productCart, 1);
      totalReturnPrice.value -= productCart.product!.sellPrice!;
      totalReturn.value -= productCart.product!.sellPrice!;
      qtyMoveCount.value--;
    }
    debugPrint('3 ${totalReturnPrice.value}');
  }

  final payTextController = TextEditingController();
  final lastChangeDiscount = 0.obs;
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
    // debugPrint(payTextController.text);
    // debugPrint(totalPrice.value.toString());
    if (payTextController.text == '') payTextController.text = '0';
    int initTotalPrice = totalPrice.value + lastChangeDiscount.value;
    debugPrint(initTotalPrice.toString());
    lastChangeDiscount.value = discountParse;
    // debugPrint(lastChangeDiscount.value.toString());
    totalCharge.value = (int.parse(payTextController.text.replaceAll('.', '')) -
            initTotalPrice) +
        discountParse;
  }

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

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
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
    ).subtract(const Duration(hours: 7));
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
      'products_return_cart': ProductsCart(cartList: cartListReturn).toJson(),
      'bill': totalPrice.value,
      'pay': payment,
      'return_fee': returnFee.value,
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
          onPressed: () async {
            cartList.clear();
            cartListReturn.clear();
            await resetToInitCartList();
            payTextController.text = '';
            totalCharge.value = 0;
            totalPrice.value = 0;
            totalDiscount.value = 0;
            totalReturn.value = 0;
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
    productController.filterProducts(productName);
  }

  void filterInvoicesId(String invoiceId) async {
    displayFilteredDate.value = '';
    dateIsSelected.value = false;
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 200), () async {
      List<Invoice> newData =
          await InvoiceProvider.fetchDataById(uuid, invoiceId);
      refreshFetch(newData);
    });
  }

  void addToCart(Cart pCart, int qty) {
    int index = cartList.indexWhere(
        (selectItem) => selectItem.product?.id == pCart.product!.id);

    if (index != -1) {
      int totalQty = cartList[index].quantity! + qty;
      if (totalQty == 0) {
        removeFromCart(pCart);
      } else {
        // totalReturnPrice.value += pCart.product!.sellPrice!;
        Cart productCart = Cart(
          product: pCart.product,
          quantity: totalQty,
          individualDiscount: pCart.individualDiscount,
          bundleDiscount: pCart.bundleDiscount,
        );

        cartList.replaceRange(index, index + 1, [productCart]);
      }
    } else {
      // totalReturnPrice.value += pCart.product!.sellPrice!;
      cartList.add(
        Cart(
          product: pCart.product,
          quantity: qty,
          individualDiscount: pCart.individualDiscount,
          bundleDiscount: pCart.bundleDiscount,
        ),
      );
    }

    if (isStop) {
      return;
    } else {
      int payValue = 0;
      payTextController.text == ''
          ? payValue = 0
          : payValue = int.parse(payTextController.text.replaceAll('.', ''));
      if (qty > 0) {
        totalCharge.value =
            payValue - (totalPrice.value + pCart.product!.sellPrice! * qty);
      } else {
        totalCharge.value = payValue -
            (totalPrice.value - pCart.product!.sellPrice! * qty.abs());
      }
    }
  }

  void addToReturnCart(Cart pReturnCart, int qty) {
    int index = cartListReturn.indexWhere(
      (selectItem) => selectItem.product?.id == pReturnCart.product!.id,
    );

//         int indexCartList = cartList.indexWhere(
//         (selectItem) => selectItem.product?.id == pReturnCart.product!.id);

// if (cartList.length == 1 && cartList[indexCartList].quantity! == 1)
    if (index != -1) {
      int totalQty = cartListReturn[index].quantity! + qty;
      if (totalQty == 0) {
        removeFromReturnCart(pReturnCart);
      } else {
        Cart productCart = Cart(
          product: pReturnCart.product,
          quantity: totalQty,
          individualDiscount: pReturnCart.individualDiscount,
          bundleDiscount: pReturnCart.bundleDiscount,
        );

        cartListReturn.replaceRange(index, index + 1, [productCart]);
      }
    } else {
      cartListReturn.add(
        Cart(
          product: pReturnCart.product,
          quantity: qty,
          individualDiscount: pReturnCart.individualDiscount,
          bundleDiscount: pReturnCart.bundleDiscount,
        ),
      );
    }
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
