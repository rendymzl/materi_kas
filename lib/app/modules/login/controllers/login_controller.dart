import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materi_kas/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/account_model.dart';
import '../../../widget/side_menu_controller.dart';

class LoginController extends GetxController {
  late SideMenuController sideMenuC = Get.find();

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
    try {
      final AuthResponse userCredential =
          await Supabase.instance.client.auth.signUp(
        email: emailFieldC.text.trim(),
        password: passwordFieldC.text,
      );

      Account account = Account(
          accountId: userCredential.user!.id,
          name: '',
          email: emailFieldC.text.trim(),
          role: 'owner',
          createdAt: DateTime.now().toLocal());

      await Account.insert(account);
      await sideMenuC.handleInit();

      debugPrint('daftar berhasil: ${account.name}');
    } on AuthException catch (e) {
      debugPrint(e.message);
    }
  }

  Future<void> signInWithEmail() async {
    clicked.value = true;
    if (formkey.currentState!.validate()) {
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: emailFieldC.text.trim(),
          password: passwordFieldC.text,
        );

        await sideMenuC.handleInit();

        debugPrint('login berhasil: ${sideMenuC.uid.value}');
        Get.offAllNamed(Routes.HOME);
      } on AuthException catch (e) {
        debugPrint('Unexpected error: ${e.message}');
        Get.defaultDialog(
          title: 'Oops!',
          middleText: 'Email atau password salah.',
          confirm: TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('OK'),
          ),
        );
      }
    }
  }
}
