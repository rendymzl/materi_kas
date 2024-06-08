import 'dart:async';

import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:materi_kas/app/data/models/customer_model.dart';
import 'package:materi_kas/app/modules/invoice/controllers/invoice_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../main.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/invoice_provider.dart';
import '../../../routes/app_pages.dart';
import '../../../widget/side_menu_controller.dart';
import '../../customer/controllers/customer_controller.dart';
import '../../product/controllers/product_controller.dart';

class HomeController extends GetxController {
  ProductController productController = Get.put(ProductController());
  CustomerController customerController = Get.put(CustomerController());
  InvoiceController invoiceController = Get.put(InvoiceController());

  late final String uuid;
  late final productList = productController.productList;
  late final customerList = customerController.customerList;
  late final invoiceList = invoiceController.invoiceList;
  final foundProducts = <Product>[].obs;
  final customers = <Customer>[].obs;
  final invoices = <Invoice>[].obs;
  final cartList = <Cart>[].obs;
  Rx<Customer?> selectedCustomer = Rx<Customer?>(null);

  @override
  void onInit() {
    super.onInit();
    Get.put(SideMenuController(), permanent: true);
    uuid = supabase.auth.currentUser!.id;
    foundProducts.value = productList;
    customers.value = customerList;
    invoices.value = invoiceList;
    // GetStorage cacheUuid = GetStorage(uuid);
  }

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

  late ScrollController scrollController = ScrollController();

  void addToCart(Product product) {
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
        if (scrollController.hasClients) {
          scrollController.animateTo(
            // index * 80.0,
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void removeFromCart(Cart productCart) {
    productCart.quantity = 1;
    cartList.remove(productCart);
  }

  //! dateTime
  final isDateTimeNow = true.obs;
  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final displayDate = DateTime.now().toString().obs;
  final displayTime = TimeOfDay.now().toString().obs;

  void handleDate(BuildContext context) async {
    // displayDate.value = selectedDate.value.toString();
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
          onSubmit: (p0) {
            selectedDate.value = p0 as DateTime;
            displayDate.value = p0.toString();
            Get.back();
          },
        ),
      ),
    );

    // DateTime? pickedDate = await showDatePickerDialog(
    //   context: context,
    //   height: 400,
    //   width: 400,
    //   initialDate: selectedDate.value,
    //   selectedDate: selectedDate.value,
    //   minDate: DateTime(2000),
    //   maxDate: DateTime.now(),
    // );

    // selectedDate.value = pickedDate ?? DateTime.now();
    // displayDate.value = pickedDate.toString();
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

  //! delete
  destroyHandle(Invoice invoice) async {
    try {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Hapus barang ini?',
        confirm: TextButton(
          onPressed: () async {
            List<Invoice> newData = await InvoiceProvider.destroy(invoice);
            invoiceController.refreshFetch(newData);
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
  void quantityHandle(Cart productCart, String qty) {
    int index = cartList.indexWhere(
        (selectItem) => selectItem.product?.id == productCart.product?.id);

    int qtyParse = qty == '' ? 0 : int.parse(qty);
    productCart.quantity = qtyParse;
    cartList.replaceRange(index, index + 1, [productCart]);
  }

  //* discount
  final pay = TextEditingController();
  final numberFormat = NumberFormat("#,##0", "id_ID");
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

  //* calculating
  final moneyChange = 0.obs;
  final totalPrice = 0.obs;
  final totalDiscount = 0.obs;

  Timer? debounce;

  void onPayChanged(String value) {
    if (value.isNotEmpty) {
      String newValue =
          numberFormat.format(int.parse(value.replaceAll('.', '')));
      if (newValue != pay.text) {
        pay.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }

    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      moneyChange.value =
          value == '' ? 0 : int.parse(value.replaceAll('.', ''));
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  final customerNameController = TextEditingController();
  final displayName = ''.obs;
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();
  final isRegisteredCustomer = false.obs;

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

  final invoiceId = ''.obs;

  String getLastSerialNumber(Invoice invoice) {
    String? invoiceNumber = invoice.invoiceId;
    DateTime? invoiceDate = invoice.createdAt!.add(const Duration(hours: 7));
    String serialPart = '000';
    if (invoiceNumber != null) {
      List<String> parts = invoiceNumber.split('/');
      DateTime selected = selectedDate.value;
      if (parts.length == 2 &&
          invoiceDate.year == selected.year &&
          invoiceDate.month == selected.month &&
          invoiceDate.day == selected.day) {
        serialPart = parts[0].replaceAll('INV', '');
        serialPart = serialPart.replaceFirst(RegExp('^0+'), '');

        return serialPart;
      }
    }

    return serialPart;
  }

  Future<String> generateInvoice(Customer? customer) async {
    Invoice inv = invoices.lastWhere(
      (invData) => invData.createdAt! == invoices.first.createdAt,
      orElse: () => Invoice(),
    );

    int lastSerialNumber = int.parse(getLastSerialNumber(inv));
    lastSerialNumber++;

    String serialNumber = lastSerialNumber.toString().padLeft(3, '0');

    String clientCode =
        (customer != null) ? customer.customerId!.toUpperCase() : 'G';

    DateTime date = selectedDate.value;
    String year = date.year.toString().substring(2);
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');

    String invoiceNumber = 'INV$serialNumber/$clientCode$month$day$year';

    return invoiceNumber;
  }

  Future saveInvoice() async {
    invoiceId.value = await generateInvoice(selectedCustomer.value);
    final payment =
        pay.text == '' ? 0 : int.parse(pay.text.replaceAll('.', ''));
    final change = moneyChange.value - totalPrice.value;
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

    final invoice = Invoice(
      invoiceId: invoiceId.value,
      createdAt: dateTime,
      customer: customer,
      productsCart: ProductsCart(cartList: cartList),
      bill: totalPrice.value,
      pay: payment,
      change: change,
      isPaid: change > 0 ? true : false,
      uuid: uuid,
    );

    Future success() async {
      await InvoiceProvider.create(invoice);
      return Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Invoice berhasil disimpan.',
        confirm: TextButton(
          onPressed: () {
            cartList.clear();
            pay.text = '';
            moneyChange.value = 0;
            totalPrice.value = 0;
            totalDiscount.value = 0;

            displayDate.value = DateTime.now().toString();
            displayTime.value = TimeOfDay.now().toString();

            selectedDate.value = DateTime.now();
            selectedTime.value = TimeOfDay.now();
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

  Future<void> signOut() async {
    await supabase.auth.signOut();
    Get.offNamed(Routes.LOGIN);
  }
}
