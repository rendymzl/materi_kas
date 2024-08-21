import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    OutlineInputBorder outlineRed =
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          width: 400,
          height: 500,
          child: Card(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      controller.isLoginPage.value
                          ? 'Selamat datang'
                          : 'Daftar',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Obx(
                    () => Form(
                      key: controller.formkey,
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: () => Form.of(primaryFocus!.context!).save(),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.emailFieldC,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Symbols.email, fill: 1),
                              labelStyle: const TextStyle(color: Colors.grey),
                              floatingLabelStyle:
                                  const TextStyle(color: Colors.black),
                              border: const OutlineInputBorder(),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedErrorBorder: outlineRed,
                              errorBorder: outlineRed,
                            ),
                            onChanged: (value) =>
                                controller.clickedField['email'] = true,
                            onSaved: (String? value) =>
                                controller.clicked.value = false,
                            validator: (value) =>
                                controller.validatorEmail(value!),
                            onFieldSubmitted: (_) =>
                                controller.signInWithEmail(),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: controller.passwordFieldC,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Symbols.lock, fill: 1),
                              suffixIcon: IconButton(
                                icon:
                                    const Icon(Symbols.remove_red_eye, fill: 1),
                                onPressed: () =>
                                    controller.toggleHidePassword(),
                              ),
                              labelStyle: const TextStyle(color: Colors.grey),
                              floatingLabelStyle:
                                  const TextStyle(color: Colors.black),
                              border: const OutlineInputBorder(),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedErrorBorder: outlineRed,
                              errorBorder: outlineRed,
                            ),
                            onChanged: (value) =>
                                controller.clickedField['password'] = true,
                            onSaved: (String? value) =>
                                controller.clicked.value = false,
                            validator: (value) =>
                                controller.validatorPassword(value!),
                            obscureText: controller.hidePassword.value,
                            onFieldSubmitted: (_) =>
                                controller.signInWithEmail(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () => controller.isLoginPage.value
                            ? controller.signInWithEmail()
                            : controller.signUpWithEmail(),
                        child: Obx(
                          () => Text(
                            controller.isLoginPage.value ? 'Masuk' : 'Daftar',
                          ),
                        ),
                      ))
                    ],
                  ),
                  // const Row(children: [
                  //   Expanded(child: Divider(color: Colors.grey)),
                  //   Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 12),
                  //     child: Text(
                  //       'ATAU',
                  //       style: TextStyle(color: Colors.grey),
                  //     ),
                  //   ),
                  //   Expanded(child: Divider(color: Colors.grey)),
                  // ]),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         icon: SvgPicture.asset(
                  //           'assets/logos/google.svg',
                  //           width: 24,
                  //           height: 24,
                  //         ),
                  //         label: Obx(
                  //           () => Text(
                  //             controller.isLoginPage.value
                  //                 ? 'Masuk dengan akun google'
                  //                 : 'Daftar dengan akun google',
                  //             style: const TextStyle(
                  //                 fontWeight: FontWeight.w400,
                  //                 color: Colors.black),
                  //           ),
                  //         ),
                  //         onPressed: () {},
                  //         style: OutlinedButton.styleFrom(
                  //           side: const BorderSide(color: Colors.grey),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: const Text(
                          'Lupa Password',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                        onTap: () {},
                      ),
                      Obx(
                        () => Row(
                          children: [
                            Text(
                              controller.isLoginPage.value
                                  ? 'Belum punya akun? '
                                  : 'Sudah punya akun? ',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            // const SizedBox(width: 12),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                child: Text(
                                  controller.isLoginPage.value
                                      ? 'Daftar'
                                      : 'Masuk',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                                onTap: () => controller.toggleLoginPage(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
