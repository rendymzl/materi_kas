import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materi_kas/app/routes/app_pages.dart';

import '../../../data/providers/customer_services.dart';
import '../../../data/providers/invoice_services.dart';
import '../../../data/providers/product_services.dart';

// import '../../../../main.dart';

class LoginController extends GetxController {
  late ProductService productService = Get.find();
  late InvoiceService invoiceService = Get.find();
  late CustomerServices customerServices = Get.find();

  @override
  void onInit() {
    super.onInit();
    emailFieldC.text = '';
    passwordFieldC.text = '';
  }

  final formkey = GlobalKey<FormState>();
  final hidePassword = true.obs;

  final clickedField = {'email': false, 'password': false}.obs;

  void toggleHidePassword() {
    hidePassword.value = !hidePassword.value;
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

  Future<void> signInWithEmail() async {
    clicked.value = true;
    if (formkey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailFieldC.text.trim(),
          password: passwordFieldC.text,
        );
        await productService.fetchProducts();
        await invoiceService.fetchInvoices();
        await customerServices.fetchCustomers();
        Get.offNamed(Routes.HOME);
      } on FirebaseAuthException catch (e) {
        debugPrint(e.code);
        // String errorMessage = e.code;
        // if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        String errorMessage = 'Email atau kata sandi salah.';
        // } else {
        //   errorMessage = 'Terjadi kesalahan saat masuk. Silakan coba lagi.';
        // }

        // errorMessage.contains('Invalid login credentials')
        //     ? errorMessage = 'Email atau kata sandi salah.'
        //     : errorMessage = 'Terjadi kesalahan saat masuk. Silakan coba lagi.';
        Get.defaultDialog(
          title: 'Oops!',
          middleText: errorMessage,
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    }
  }
}
