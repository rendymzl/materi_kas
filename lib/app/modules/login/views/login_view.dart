import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
        child: SizedBox(
          width: 400,
          height: 500,
          child: Card(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Selamat datang',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => Form(
                      key: controller.formkey,
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: () => Form.of(primaryFocus!.context!).save(),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.editingEmail,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Symbols.email, fill: 1),
                              labelText: "Email",
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
                            controller: controller.editingPassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Symbols.lock, fill: 1),
                              suffixIcon: IconButton(
                                icon:
                                    const Icon(Symbols.remove_red_eye, fill: 1),
                                onPressed: () =>
                                    controller.toggleHidePassword(),
                              ),
                              labelText: "Password",
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () => controller.signInWithEmail(),
                              child: const Text("Masuk")))
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'ATAU',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ]),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: SvgPicture.asset(
                            'assets/logos/google.svg',
                            width: 24,
                            height: 24,
                          ),
                          label: const Text(
                            'Masuk dengan akun google',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: const Text(
                          'Lupa Password',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                        onTap: () {},
                      )
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
