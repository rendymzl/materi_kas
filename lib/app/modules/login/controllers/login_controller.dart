// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materi_kas/app/routes/app_pages.dart';

import '../../../data/models/account_model.dart';
import '../../../data/providers/auth_services.dart';
import '../../../data/providers/customer_services.dart';
import '../../../data/providers/invoice_services.dart';
import '../../../data/providers/operating_cost_services.dart';
import '../../../data/providers/product_services.dart';
import '../../../data/providers/sales_customer_services.dart';
import '../../../data/providers/sales_invoice_services.dart';
import '../../../data/providers/stores_services.dart';

class LoginController extends GetxController {
  late StoreServices storeService = Get.find();

  late AuthService authService = Get.find();
  late ProductService productService = Get.find();
  late InvoiceService invoiceService = Get.find();
  late SalesInvoiceService salesInvoiceService = Get.find();
  late CustomerServices customerServices = Get.find();
  late SalesCustomerServices salesCustomerServices = Get.find();
  late OperatingCostServices operatingCostServices = Get.find();

  final isLoginPage = true.obs;

  @override
  void onInit() {
    super.onInit();
    emailFieldC.text = '';
    passwordFieldC.text = '';
    isLoginPage.value = true;
  }

  final formkey = GlobalKey<FormState>();
  final hidePassword = true.obs;

  final clickedField = {'email': false, 'password': false}.obs;

  void toggleHidePassword() {
    hidePassword.value = !hidePassword.value;
  }

  void toggleLoginPage() {
    isLoginPage.value = !isLoginPage.value;
  }

  final clicked = false.obs;

  String? validatorEmail(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['email'] == true) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value) && clicked.value) {
      return 'Email tidak valid';
    }
    return null;
  }

  String? validatorPassword(String value) {
    if (value.isEmpty && clickedField['password'] == true) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  final emailFieldC = TextEditingController();
  final passwordFieldC = TextEditingController();

  Future<void> signUpWithEmail() async {
    // debugPrint('signup');
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailFieldC.text.trim(),
        password: passwordFieldC.text,
      );

      Account account = Account(
        uid: userCredential.user!.uid,
        ownerUid: userCredential.user!.uid,
        name: '',
        email: emailFieldC.text.trim(),
        role: 'owner',
      );

      await storeService.addAccount(account);

      Get.offAllNamed(Routes.SETUP);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchData() async {
    debugPrint('fetchings');
    await storeService.fetchStore();
    await productService.fetchProducts();
    await invoiceService.fetchInvoices();
    await salesCustomerServices.fetchCustomers();
    await customerServices.fetchCustomers();
    await salesInvoiceService.fetchInvoices();
    await salesInvoiceService.fetchInvoices();
    await operatingCostServices.fetchOperatingCost();
  }

  Future<void> signInWithEmail() async {
    clicked.value = true;
    if (formkey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailFieldC.text.trim(),
          password: passwordFieldC.text,
        );

        await fetchData();

        Get.offAllNamed(Routes.HOME);
      } on FirebaseAuthException catch (e) {
        debugPrint('Error code: ${e.code}');
        Get.defaultDialog(
          title: 'Oops!',
          middleText: e.message ?? 'Terjadi kesalahan',
          confirm: TextButton(
            onPressed: () {
              authService.signOut();
              Get.back();
            },
            child: const Text('OK'),
          ),
        );
      } catch (e) {
        debugPrint('Unexpected error: $e');
        Get.defaultDialog(
          title: 'Oops!',
          middleText:
              'Terjadi kesalahan tidak terduga. Silakan coba lagi nanti.',
          confirm: TextButton(
            onPressed: () {
              authService.signOut();
              Get.back();
            },
            child: const Text('OK'),
          ),
        );
      }
    }
  }
}
