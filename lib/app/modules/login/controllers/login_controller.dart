import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materi_kas/app/routes/app_pages.dart';

import '../../../../main.dart';

class LoginController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    editingEmail.text = 'tesr@example.com';
    editingPassword.text = 'indonesia21';
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

  final editingEmail = TextEditingController();
  final editingPassword = TextEditingController();

  Future<void> signInWithEmail() async {
    clicked.value = true;
    if (formkey.currentState!.validate()) {
      try {
        await supabase.auth.signInWithPassword(
          email: editingEmail.text.trim(),
          password: editingPassword.text,
        );

        Get.offNamed(Routes.HOME);
      } catch (error) {
        String errorMessage = error.toString();
        errorMessage.contains('Invalid login credentials')
            ? errorMessage = 'Email atau kata sandi salah.'
            : errorMessage = 'Terjadi kesalahan saat masuk. Silakan coba lagi.';
        Get.defaultDialog(
          title: 'Error',
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
