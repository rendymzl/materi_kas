import 'dart:async';
// import 'dart:ffi';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../data/models/cart_item_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/providers/invoice_services.dart';
import '../../../data/providers/product_services.dart';
import '../../../widget/customer_input_field_controller.dart';
import '../../../widget/date_picker_controller.dart';
import '../../../widget/side_menu_controller.dart';
import '../../product/controllers/product_controller.dart';

class InvoiceController extends GetxController {
  late SideMenuController sideMenuC = Get.find();
  late InvoiceService invoiceServices = Get.find();
  late ProductService productServices = Get.find();
  late CustomerInputFieldController customerInputFieldC =
      Get.put(CustomerInputFieldController());
  late DatePickerController datePickerC = Get.put(DatePickerController());

  late final invoices = invoiceServices.invoices;
  late final foundInvoices = invoiceServices.foundInvoices;
  late final products = productServices.products;
  late final foundProducts = productServices.foundProducts;

  late final isAdmin = sideMenuC.isAdmin.value;

  final isComa = false.obs;

  final editedCart = Cart(items: <CartItem>[].obs).obs;

  List<CartItem> initCartItems = [];
  List<CartItem> updatedInvQty = [];

  // final currency = NumberFormat('#,##0', 'id_ID');

  List<CartItem> filterPurchase(Invoice invoice) {
    List<CartItem> workerData = invoice.purchaseList.value.items
        .where((p) => p.quantity.value > 0)
        .map((purchased) => purchased)
        .toList();
    return workerData;
  }

  List<CartItem> filterReturn(Invoice invoice) {
    List<CartItem> workerData = invoice.purchaseList.value.items
        .where((p) => p.quantityReturn.value > 0)
        .map((purchased) => purchased)
        .toList();
    return workerData;
  }

  final editReturnManual = false.obs;
  void toggleEditReturnManual() {
    editReturnManual.value = !editReturnManual.value;
  }

  @override
  void onInit() async {
    filterInvoices('');
    ever(editReturnManual, (_) => updateMaxQuantity());
    super.onInit();
  }

  void updateMaxQuantity() {
    if (initCartItems.isNotEmpty && updatedInvQty.isNotEmpty) {
      for (var initCart in initCartItems) {
        var qtyUpdate = updatedInvQty
            .firstWhereOrNull((item) => item.product.id == initCart.product.id);
        if (qtyUpdate != null) {
          initCart.quantity.value = qtyUpdate.quantity.value;
          initCart.quantityReturn.value = qtyUpdate.quantityReturn.value;
        }
        debugPrint('==================ttl qty ${initCart.quantity.value}');
        debugPrint(
            '==================ttrtrn qty ${initCart.quantityReturn.value}');
      }
    }
  }

  //! Filtered
  void filterInvoices(dynamic searchValue) {
    if (searchValue is String) {
      invoiceServices.searchInvoicesByName(searchValue);
    } else if (searchValue is PickerDateRange) {
      invoiceServices.searchInvoicesByPickerDateRange(searchValue);
    }
  }

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
    startFilteredDate.value = '';
    endFilteredDate.value = '';
    displayFilteredDate.value = '';
    dateIsSelected.value = false;
    filterInvoices('');
  }

//! Detail Dialog

  Future<Invoice> reCreateInvoice(Invoice inv) async {
    // RxList<CartItem> items = inv.purchaseList.value.items.map((item) {

    // })
    //  CartItem cartItem = CartItem(product: inv.purchaseList.value.items., quantity: quantity)
    final newInvoice = Invoice.fromJson(inv.toJson());

    return newInvoice;
  }

  final purchaseList = Cart(items: <CartItem>[].obs).obs;
  final returnList = Cart(items: <CartItem>[].obs).obs;
  final afterReturnList = Cart(items: <CartItem>[].obs).obs;

  final showChange = false.obs;
  final showReturnFee = false.obs;
  final totalChange = 0.obs;

  //! EDIT DATA =====

  final showPaymentCard = false.obs;

  late ScrollController scrollController = ScrollController();

  void scrollHandle() {
    Future.delayed(const Duration(milliseconds: 50), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  //! dateTime Data
  final isDateTimeNow = true.obs;
  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final displayDate = DateTime.now().toString().obs;
  final displayTime = TimeOfDay.now().toString().obs;

  //! Cart Data
  final createdAt = DateTime.now().obs;
  final customer = Customer().obs;
  // final purchaseList = Cart(items: items).obs;

  // late final priceType = 1.obs;
  // late final moneyChange = 0.obs;
  // late final totalBill = 0.obs;
  // late final totalDiscount = 0.obs;
  // late final totalReturn = 0.obs;
  // late final returnFee = 0.obs;
  // late final totalReturnFinal = 0.obs;

  // void priceTypeHandleCheckBox(int type) async {
  //   priceType.value == type ? priceType.value = 1 : priceType.value = type;
  //   // totalBill.value = cart.value.getTotal(priceType.value);
  // }

  //! EDIT FUNCTION =====

  //! dateTime Function
  void handleDate(BuildContext context) async {
    // displayDate.value = selectedDate.value.toString();
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
            displayDate.value = DateFormat('dd MMMM y', 'id').format(p0);
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
    if (pickedTime != null) selectedTime.value = pickedTime;
    DateTime convertedTime = DateTime(
        2024, 1, 1, selectedTime.value.hour, selectedTime.value.minute);
    displayTime.value = DateFormat('HH:mm', 'id').format(convertedTime);
  }

  //! Cart Function
  void removeFromCart(CartItem cartItem, Invoice invoice, bool isReturn) {
    //!registerCartItem
    var initCartItem = initCartItems
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (initCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      initCartItems.add(newCartItem);
      initCartItem = initCartItems.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //!registerNewCartItem
    var forUpdateCartItem = updatedInvQty
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (forUpdateCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      updatedInvQty.add(newCartItem);
      forUpdateCartItem = updatedInvQty.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //! qty
    if (isReturn) {
      cartItem.quantityReturn.value = 0;
      forUpdateCartItem!.quantityReturn.value = 0;
      forUpdateCartItem.quantity.value = cartItem.totalQuantity - 0;
    } else {
      cartItem.quantity.value = 0;
      forUpdateCartItem!.quantity.value = 0;
      forUpdateCartItem.quantityReturn.value = cartItem.totalQuantity - 0;
    }

    // isReturn
    //     ? invoice.purchaseList.value
    //         .updateQuantityReturn(cartItem.product.id, qtyEdit)
    //     : invoice.purchaseList.value.updateQuantity(
    //         cartItem.product.id, initCartItem.totalQuantity - qtyEdit);
    invoice.updateIsDebtPaid();

    //!process Stock
    isReturn
        ? forUpdateCartItem.product.stock.value =
            initCartItem!.quantityReturn.value - 0
        : forUpdateCartItem.product.stock.value =
            0 - initCartItem!.quantity.value;

    // debugPrint('qty ${cartItem.quantity.value}');
    // debugPrint('rtn qty ${cartItem.quantityReturn.value}');
    // debugPrint('Stok ${forUpdateCartItem.product.stock.value}');

    // final existingProduct = initCartItems
    //     .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    // if (existingProduct != null) {
    //   existingProduct.product.stock.value = 0;
    // } else {
    //   initCartItems.add(cartItem);
    // }
  }

  void quantityReturnHandle(CartItem cartItem, String quantityReturn,
      Invoice invoice, TextEditingController qtyTextC) {
    double? qtyReturn = double.tryParse(quantityReturn);
    qtyReturn ??= 0;

    //!registerCartItem
    var initCartItem = initCartItems
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (initCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      initCartItems.add(newCartItem);
      initCartItem = initCartItems.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //!registerNewCartItem
    var forUpdateCartItem = updatedInvQty
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (forUpdateCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      updatedInvQty.add(newCartItem);
      forUpdateCartItem = updatedInvQty.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }
    debugPrint(' total qty init${initCartItem!.totalQuantity}');
    //!process Quantity
    if (qtyReturn >= initCartItem.totalQuantity) {
      qtyReturn = initCartItem.totalQuantity;
      // debugPrint((qtyReturn).toString());
    }
    cartItem.quantityReturn.value = qtyReturn;
    if (!qtyTextC.text.endsWith(',')) {
      String displayQtyValue = qtyReturn % 1 == 0
          ? qtyReturn.toInt().toString()
          : qtyReturn.toString().replaceAll('.', ',');
      qtyTextC.text = displayQtyValue;
    }

    invoice.purchaseList.value.updateQuantity(
        cartItem.product.id!, initCartItem.totalQuantity - qtyReturn);
    invoice.purchaseList.value
        .updateQuantityReturn(cartItem.product.id!, qtyReturn);
    invoice.updateIsDebtPaid();

    //!process Stock

    debugPrint('============== ${initCartItem.quantityReturn.value}');
    forUpdateCartItem!.product.stock.value =
        initCartItem.quantityReturn.value - qtyReturn;
    debugPrint('qty ${cartItem.quantity.value}');
    debugPrint('rtn qty ${cartItem.quantityReturn.value}');
    debugPrint('Stok ${forUpdateCartItem.product.stock.value}');
  }

  void quantityEditHandle(CartItem cartItem, String quantityEdit,
      Invoice invoice, TextEditingController qtyTextC, bool isReturn) {
    double? qtyEdit = double.tryParse(quantityEdit);
    qtyEdit ??= 0;

    //!registerCartItem
    var initCartItem = initCartItems
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (initCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      initCartItems.add(newCartItem);
      initCartItem = initCartItems.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //!registerNewCartItem
    var forUpdateCartItem = updatedInvQty
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (forUpdateCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      updatedInvQty.add(newCartItem);
      forUpdateCartItem = updatedInvQty.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //! qty
    if (isReturn) {
      cartItem.quantityReturn.value = qtyEdit;
      forUpdateCartItem!.quantityReturn.value = qtyEdit;
      forUpdateCartItem.quantity.value = cartItem.totalQuantity - qtyEdit;
    } else {
      cartItem.quantity.value = qtyEdit;
      forUpdateCartItem!.quantity.value = qtyEdit;
      forUpdateCartItem.quantityReturn.value = cartItem.totalQuantity - qtyEdit;
    }

    if (!qtyTextC.text.endsWith(',')) {
      String displayQtyValue = qtyEdit % 1 == 0
          ? qtyEdit.toInt().toString()
          : qtyEdit.toString().replaceAll('.', ',');
      qtyTextC.text = displayQtyValue;
    }

    // isReturn
    //     ? invoice.purchaseList.value
    //         .updateQuantityReturn(cartItem.product.id, qtyEdit)
    //     : invoice.purchaseList.value.updateQuantity(
    //         cartItem.product.id, initCartItem.totalQuantity - qtyEdit);
    invoice.updateIsDebtPaid();

    //!process Stock
    isReturn
        ? forUpdateCartItem.product.stock.value =
            initCartItem!.quantityReturn.value - qtyEdit
        : forUpdateCartItem.product.stock.value =
            qtyEdit - initCartItem!.quantity.value;

    debugPrint('qty ${cartItem.quantity.value}');
    debugPrint('rtn qty ${cartItem.quantityReturn.value}');
    debugPrint('Stok ${forUpdateCartItem.product.stock.value}');
  }

  ProductController productController = Get.put(ProductController());
  void filterProducts(String productName) {
    productController.filterProducts(productName);
  }

  void addToCart(CartItem cartItem, Invoice editInvoice) {
    //!registerCartItem
    var initCartItem = initCartItems
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (initCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      initCartItems.add(newCartItem);
      initCartItem = initCartItems.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //!registerNewCartItem
    var forUpdateCartItem = updatedInvQty
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (forUpdateCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      newCartItem.product.stock.value = 0;
      updatedInvQty.add(newCartItem);
      forUpdateCartItem = updatedInvQty.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //!process Quantity
    final existingItem = editInvoice.purchaseList.value.items
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);
    if (existingItem != null) {
      // existingItem.quantity.value += 1;
    } else {
      editInvoice.purchaseList.value.items.add(cartItem);
    }

    //!process Stock
    forUpdateCartItem!.product.stock.value += 1;

    debugPrint('qty ${cartItem.quantity.value}');
    debugPrint('rtn qty ${cartItem.quantityReturn.value}');
    debugPrint('Stok ${forUpdateCartItem.product.stock.value}');
  }

  void addToReturnCart(CartItem cartItem, Invoice editInvoice) {
    //!registerCartItem
    var initCartItem = initCartItems
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (initCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      initCartItems.add(newCartItem);
      initCartItem = initCartItems.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //!registerNewCartItem
    var forUpdateCartItem = updatedInvQty
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (forUpdateCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      newCartItem.product.stock.value = 0;
      updatedInvQty.add(newCartItem);
      forUpdateCartItem = updatedInvQty.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //!process Quantity
    Cart cartReturn = Cart(items: <CartItem>[].obs);
    CartItem returnCartItemReturn = CartItem.fromJson(cartItem.toJson());
    returnCartItemReturn.quantityReturn.value =
        returnCartItemReturn.quantity.value;
    returnCartItemReturn.quantity.value = 0;
    cartReturn.addItem(returnCartItemReturn);
    if (editInvoice.returnList.value != null) {
      editInvoice.returnList.value!.items.add(returnCartItemReturn);
    } else {
      editInvoice.returnList.value = cartReturn;
    }
    // final existingItem = editInvoice.purchaseList.value.items
    //     .firstWhereOrNull((item) => item.product.id == cartItem.product.id);
    // if (existingItem != null) {
    //   // existingItem.quantity.value += 1;
    // } else {
    //   editInvoice.returnList.value = cartItem;
    // }

    //!process Stock
    forUpdateCartItem!.product.stock.value += 1;

    debugPrint('qty ${cartItem.quantity.value}');
    debugPrint('rtn qty ${cartItem.quantityReturn.value}');
    debugPrint('Stok ${forUpdateCartItem.product.stock.value}');
  }

  void addToStock(
      CartItem cartItem, Invoice invoice, double value, bool isReturn) {
    //!registerCartItem
    var initCartItem = initCartItems
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (initCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      // newCartItem.product.stock.value = 0;
      initCartItems.add(newCartItem);
      initCartItem = initCartItems.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //!registerNewCartItem
    var forUpdateCartItem = updatedInvQty
        .firstWhereOrNull((item) => item.product.id == cartItem.product.id);

    if (forUpdateCartItem == null) {
      CartItem newCartItem = CartItem.fromJson(cartItem.toJson());
      newCartItem.product.stock.value = 0;
      updatedInvQty.add(newCartItem);
      forUpdateCartItem = updatedInvQty.firstWhereOrNull(
          (item) => item.product.id == newCartItem.product.id);
    }

    //!process Quantity
    cartItem.quantity.value += value * (isReturn ? 1 : -1);
    cartItem.quantityReturn.value -= value * (isReturn ? 1 : -1);

    //!process Stock
    forUpdateCartItem!.product.stock.value += value * (isReturn ? 1 : -1);
    debugPrint('qty ${cartItem.quantity.value}');
    debugPrint('rtn qty ${cartItem.quantityReturn.value}');
    debugPrint('Stok ${forUpdateCartItem.product.stock.value}');
  }

  void asignEditData(Invoice invoice) {
    // id.value = invoice.id!;

    // editPurchaseList.value.items.clear();
    // editPurchaseList.value.items.assignAll(invoice.purchaseList);
    // for (var cart in invoice.cartList!.purchaseCart!) {
    //   Cart newCart = Cart(
    //     product: cart.product,
    //     quantity: cart.quantity,
    //     individualDiscount: cart.individualDiscount,
    //     bundleDiscount: cart.individualDiscount,
    //   );
    //   editPurchaseCart.add(newCart);
    // }

    // editPurchaseCart.addAll(purchaseCart);

    // editReturnCart.clear();
    // if (invoice.cartList!.returnCart != null) {
    //   for (var cart in invoice.cartList!.returnCart!) {
    //     Cart newCart = Cart(
    //       product: cart.product,
    //       quantity: cart.quantity,
    //       individualDiscount: cart.individualDiscount,
    //       bundleDiscount: cart.individualDiscount,
    //     );
    //     editReturnCart.add(newCart);
    //   }
    // }

    // editAfterReturnCart.clear();
    // if (invoice.cartList!.afterReturnCart != null) {
    //   for (var cart in invoice.cartList!.afterReturnCart!) {
    //     Cart newCart = Cart(
    //       product: cart.product,
    //       quantity: cart.quantity,
    //       individualDiscount: cart.individualDiscount,
    //       bundleDiscount: cart.individualDiscount,
    //     );
    //     editAfterReturnCart.add(newCart);
    //   }
    // } else {
    //   for (var cart in invoice.cartList!.purchaseCart!) {
    //     Cart newCart = Cart(
    //       product: cart.product,
    //       quantity: cart.quantity,
    //       individualDiscount: cart.individualDiscount,
    //       bundleDiscount: cart.individualDiscount,
    //     );
    //     editAfterReturnCart.add(newCart);
    //   }
    // }
    // // editReturnCart.addAll(returnCart);
    // customerInputFieldC.asignCustomer(invoice.customer!);
    // // customerInputFieldC.customerNameController.text = invoice.customer!.name!;
    // // customerInputFieldC.customerPhoneController.text = invoice.customer!.phone!;
    // // customerInputFieldC.customerAddressController.text =
    // //     invoice.customer!.address!;
    // // customerInputFieldC.displayName.value =
    // //     invoice.customer!.customerId != null ? invoice.customer!.name! : '';

    // payTextC.text = currency.format(
    //     invoice.totalPaid <= invoice.total ? invoice.totalPaid : invoice.total);
    // totalChange.value =
    //     invoice.payment!.totalPay! >= invoice.payment!.totalBill!
    //         ? 0
    //         : invoice.payment!.totalPay! - invoice.payment!.totalBill!;
    // totalPurchase.value = invoice.payment!.totalBill!;
    showPaymentCard.value = false;

    DateTime invoiceDateTime = invoice.createdAt.value!;

    DateTime date = DateTime(
      invoiceDateTime.year,
      invoiceDateTime.month,
      invoiceDateTime.day,
      invoiceDateTime.hour,
      invoiceDateTime.minute,
    );

    selectedDate.value = date;
    displayDate.value =
        DateFormat('dd MMMM y', 'id').format(selectedDate.value);

    selectedTime.value = TimeOfDay.fromDateTime(date);
    displayTime.value = DateFormat('HH:mm', 'id').format(date);

    // if (invoice.payment!.returnFee != null) {
    //   returnFee.value = invoice.payment!.returnFee!;
    //   totalReturnFinal.value = totalReturn.value - invoice.payment!.returnFee!;
    // }

    // updateCalculateData();

    // // totalReturn.value = editReturnCart.fold(
    // //   0,
    // //   (prev, cart) =>
    // //       prev +
    // //       (cart.product!.sellPrice! * cart.quantity!) -
    // //       cart.individualDiscount!,
    // // );
  }

  void updateCart(RxList<Cart> targetCartList, Cart newCart) {
    // int index = targetCartList.indexWhere(
    //     (cart) => cart.product?.productId == newCart.product?.productId);

    // if (index > -1) {
    //   targetCartList.replaceRange(index, index + 1, [newCart]);
    // } else {
    //   targetCartList.add(newCart);
    // }

    // updateCalculateData();
  }

  updateCalculateData() {
    // totalDiscount.value = 0;
    // for (var editCart in editPurchaseCart) {
    //   totalPurchase.value +=
    //       ((editCart.product!.sellPrice! * editCart.quantity!) -
    //           editCart.individualDiscount!);

    //   totalDiscount.value += editCart.individualDiscount!;
    // }
    // //! TotalReturn
    // totalReturn.value = editReturnCart.fold(
    //   0,
    //   (prev, cart) => prev + (cart.product!.sellPrice! * cart.quantity!),
    // );

    // //! TotalReturnFinal
    // totalReturnFinal.value = totalReturn.value - returnFee.value;

    // //! TotalHarga
    // totalPurchase.value = editPurchaseCart.fold(
    //   0,
    //   (prev, cart) =>
    //       prev +
    //       (cart.product!.sellPrice! * cart.quantity!) -
    //       cart.individualDiscount!,
    // );

    // //! TotalDiskon
    // totalDiscount.value = editPurchaseCart.fold(
    //   0,
    //   (prev, cart) => prev + cart.individualDiscount!,
    // );

    // //! TotalKembalian
    // String payText =
    //     payTextC.text == '' ? '0' : payTextC.text;
    // totalChange.value =
    //     int.parse(payText.replaceAll('.', '')) - totalPurchase.value;
  }

  destroyHandle(Invoice invoice) async {
    try {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Hapus Invoice ini?',
        confirm: TextButton(
          onPressed: () async {
            await invoice.delete();
            // invoiceServices.deleteInvoice(invoice.id!);
            // refreshFetch(await InvoiceProvider.destroy(invoice));
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
