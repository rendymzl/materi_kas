import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materi_kas/app/data/models/customer_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  late final String uuid;
  late final productList = productController.productList;
  late final customerList = customerController.customerList;
  final foundProducts = <Product>[].obs;
  final customers = <Customer>[].obs;
  final cartList = <Cart>[].obs;
  Rx<Customer?> selectedCustomer = Rx<Customer?>(null);

  @override
  void onInit() {
    super.onInit();
    Get.put(SideMenuController(), permanent: true);
    uuid = supabase.auth.currentUser!.id;
    foundProducts.value = productList;
    customers.value = customerList;
  }

  void filterProducts(String productName) {
    var result = <Product>[];
    productName.isEmpty
        ? result = productList
        : result = productList
            .where((product) => product.productName
                .toString()
                .toLowerCase()
                .contains(productName))
            .toList();

    foundProducts.value = result;
  }

  ScrollController scrollController = ScrollController();

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
        scrollController.animateTo(
          // index * 80.0,
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void removeFromCart(Cart productCart) {
    productCart.quantity = 1;
    cartList.remove(productCart);
  }

  void quantityHandle(Cart productCart, String qty) {
    int index = cartList.indexWhere(
        (selectItem) => selectItem.product?.id == productCart.product?.id);

    int qtyParse = qty == '' ? 0 : int.parse(qty);
    productCart.quantity = qtyParse;
    cartList.replaceRange(index, index + 1, [productCart]);
  }

  final pay = TextEditingController();
  final numberFormat = NumberFormat("#,##0", "id_ID");
  final isRegisteredCustomer = false.obs;

  final moneyChange = 0.obs;
  final totalPrice = 0.obs;

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
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();

  void handleCustomer(String value) {}

  Future saveInvoice() async {
    final payment =
        pay.text == '' ? 0 : int.parse(pay.text.replaceAll('.', ''));
    const invoiceId = '';
    final change = moneyChange.value - totalPrice.value;
    final invoice = Invoice(
      invoiceId: invoiceId,
      customer: Customer(
          name: 'dummyName',
          phone: '082212212121',
          address:
              'Kp. Munjul RT 01 RW 06 Kelurahan Kayumanis Kec tanahsareal Bogor',
          uuid: uuid),
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
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    }

    try {
      change <= 0
          ? Get.defaultDialog(
              title: 'Ups',
              middleText: 'Total tagihan belum terpenuhi.',
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
              ))
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
