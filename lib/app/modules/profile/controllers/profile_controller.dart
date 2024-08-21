import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/account_model.dart';
// import '../../../data/providers/add_cashier_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widget/side_menu_controller.dart';

class ProfileController extends GetxController {
  late SideMenuController sideMenuC = Get.find();
  // final AddCashier addCashierApi = AddCashier();
  final formKey = GlobalKey<FormState>();
  final formCashierKey = GlobalKey<FormState>();

  final storeNameController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final storeTelpController = TextEditingController();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final stores = sideMenuC.store.value;
  late final cashiers = <Account>[].obs;

  var storeName = ''.obs;
  var storeAddress = ''.obs;
  var storePhone = ''.obs;
  var storeTelp = ''.obs;

  @override
  void onInit() async {
    cashiers.assignAll(await Account.getCashier(sideMenuC.store.value!.id!));
    debugPrint('akunid sekarang: ${sideMenuC.account.value!.id!}');
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
        // Stores store = Stores(
        //   uid: '',
        //   name: storeNameController.text.trim(),
        //   address: storeAddressController.text.trim(),
        //   phone: storePhoneController.text.trim(),
        //   telp: storeTelpController.text.trim(),
        // );

        // await storeService.addStore(store);

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
  // Future<void> addAdminRoleToUser(String userId) async {
  //   final response = await Supabase.instance.client.auth.admin.updateUserById(
  //     userId,
  //     attributes: AdminUserAttributes(
  //       userMetadata: {
  //         'role': 'admin',
  //       },
  //     ),
  //   );

  //   if (response.user != null) {
  //     debugPrint(
  //         'Role admin berhasil ditambahkan pada pengguna dengan ID: $userId');
  //   }
  // }

  Future<void> registerWorker() async {
    if (formCashierKey.currentState?.validate() ?? false) {
      Get.defaultDialog(
        title: 'Menambahkan kasir...',
        content: const CircularProgressIndicator(),
        barrierDismissible: false,
      );
      try {
        final AuthResponse userCredential =
            await Supabase.instance.client.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        debugPrint('awdawd');
        Account account = Account(
          accountId: userCredential.user!.id,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          role: 'worker',
          createdAt: DateTime.now().toLocal(),
          storeId: sideMenuC.store.value!.id,
        );

        await Account.insert(account);

        debugPrint('daftar berhasil: ${account.name}');
        debugPrint('store sekarang: ${sideMenuC.store.value!.id!}');
        cashiers
            .assignAll(await Account.getCashier(sideMenuC.store.value!.id!));
        debugPrint('cashiers: $cashiers');
        nameController.text = '';
        emailController.text = '';
        passwordController.text = '';
        Get.back();
      } catch (e) {
        Get.back();
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
