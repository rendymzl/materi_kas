import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/account_model.dart';
import '../../../data/models/store_model.dart';
import '../../../data/providers/add_cashier_service.dart';
import '../../../data/providers/auth_services.dart';
import '../../../data/providers/stores_services.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find();
  final AddCashier addCashierApi = AddCashier();
  late StoreServices storeService = Get.put(StoreServices());
  final formKey = GlobalKey<FormState>();
  final formCashierKey = GlobalKey<FormState>();

  final storeNameController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final storeTelpController = TextEditingController();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final stores = storeService.account.value.stores;
  late final cashiers = storeService.cashier;

  var storeName = ''.obs;
  var storeAddress = ''.obs;
  var storePhone = ''.obs;
  var storeTelp = ''.obs;

  @override
  void onInit() {
    super.onInit();
    storeNameController.addListener(() {
      storeName.value = storeNameController.text;
    });
    storeAddressController.addListener(() {
      storeAddress.value = storeAddressController.text;
    });
    storePhoneController.addListener(() {
      storePhone.value = storePhoneController.text;
    });
    storeTelpController.addListener(() {
      storeTelp.value = storeTelpController.text;
    });
  }

  String? validateStoreName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama toko tidak boleh kosong';
    }
    return null;
  }

  String? validateStoreAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat toko tidak boleh kosong';
    }
    return null;
  }

  Future<void> submitData() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        Stores store = Stores(
          uid: '',
          name: storeNameController.text.trim(),
          address: storeAddressController.text.trim(),
          phone: storePhoneController.text.trim(),
          telp: storeTelpController.text.trim(),
        );

        await storeService.addStore(store);

        Get.offNamed(Routes.HOME); // Arahkan ke halaman utama setelah setup
      } catch (e) {
        Get.defaultDialog(
          title: 'Error',
          middleText:
              'Terjadi kesalahan saat menyimpan data toko. Silakan coba lagi.',
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  String? validateCashierName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama kasir tidak boleh kosong';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  // Future<void> tesFunc() async {
  //   final response = await addCashierApi.createAccount();

  //   // final HttpsCallableResult result = await callable.call();

  //   debugPrint(response.toString());
  // }

  Future<void> registerWorker() async {
    // debugPrint(formKey.currentState?.validate().toString());
    if (formCashierKey.currentState?.validate() ?? false) {
      try {
        Get.defaultDialog(
          title: 'Menambahkan kasir...',
          content: const CircularProgressIndicator(),
          barrierDismissible: false,
        );
        final result = await addCashierApi.createAccount(
          emailController.text.trim(),
          passwordController.text.trim(),
          authService.uid.value,
        );
        final newWorkerUid = result['uid'];

        Account cashier = Account(
            uid: newWorkerUid,
            ownerUid: authService.uid.value,
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            role: 'worker',
            stores: storeService.account.value.stores.value);
        // Simpan data worker ke Firestore
        await storeService.addCashier(cashier);
        Get.back();
        nameController.text = '';
        emailController.text = '';
        passwordController.text = '';
      } on FirebaseAuthException catch (e) {
        Get.defaultDialog(
          title: 'Error',
          middleText: e.message ?? 'Terjadi kesalahan saat mendaftar worker',
          confirm: TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('OK'),
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
        Get.defaultDialog(
          title: 'Error',
          middleText: 'Terjadi kesalahan tidak terduga',
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    }
  }
}
