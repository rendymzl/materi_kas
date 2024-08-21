import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materi_kas/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import '../data/providers/auth_services.dart';
// import '../data/providers/stores_services.dart';
import '../data/models/account_model.dart';
import '../data/models/store_model.dart';
import '../data/providers/customer_services.dart';
import '../data/providers/invoice_services.dart';
import '../data/providers/product_services.dart';
// import '../modules/init/controllers/init_controller.dart';

class SideMenuController extends GetxController {
  late ProductService productService =
      Get.put(ProductService(), permanent: true);
  late InvoiceService invoiceService =
      Get.put(InvoiceService(), permanent: true);
  late CustomerServices customerService =
      Get.put(CustomerServices(), permanent: true);

  SupabaseClient supabase = Supabase.instance.client;

  late final uid = ''.obs;
  late final isLogin = false.obs;
  // late final isOwner = true.obs;

  //!store
  late final Rx<Stores?> store = Rx<Stores?>(null);
  //!account
  late final Rx<Account?> account = Rx<Account?>(null);

  Future<void> handleInit() async {
    isLogin.value = supabase.auth.currentUser != null;
    if (isLogin.value) {
      await fetchData();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offNamed(Routes.LOGIN);
      });
    }
  }

  /// Mengambil data yang diperlukan setelah login dan mengatur state aplikasi.
  Future<void> fetchData() async {
    // Mengatur UID pengguna saat ini.
    uid.value = supabase.auth.currentUser!.id;
    // Mengambil data akun berdasarkan UID.
    account.value = await Account.get(uid.value);
    // Menentukan apakah pengguna adalah admin berdasarkan peran.
    isAdmin.value = account.value!.role == 'owner';

    // Jika data akun tidak ditemukan, maka pengguna akan diarahkan ke halaman login.
    if (account.value == null) {
      Get.offNamed(Routes.LOGIN);
      return;
    }

    // Jika akun tidak memiliki ID toko, maka pengguna akan diarahkan ke halaman setup.
    if (account.value!.storeId == null) {
      Get.offNamed(Routes.SETUP);
      return;
    }

    // Mengambil data toko berdasarkan ID toko dari akun.
    // store.value = await Stores.get(account.value!.storeId!);
    store.value = await Stores.getPs(account.value!.storeId!);
    // Jika data toko tidak ditemukan, maka pengguna akan diarahkan ke halaman setup.
    if (store.value == null) {
      Get.offNamed(Routes.SETUP);
      return;
    }

    // Berlangganan ke layanan produk, invoice, dan pelanggan.
    await productService.subscribe();
    await invoiceService.subscribe();
    await customerService.fetch();
    // Mengarahkan pengguna ke halaman utama setelah data berhasil diambil.
    Get.offNamed(Routes.HOME);
  }

  //   Future<void> asignAccount() async {

  //   uid.value = supabase.auth.currentUser!.id;
  //   // if (supabase.auth.)
  //   account.value = (await Account.get(uid.value))!;
  //   if (account.value.storeId != null) {
  //     store.value = (await Stores.get(account.value.storeId!))!;
  //   }
  //   await productService.subscribe();
  //   await invoiceService.subscribe();
  //   await customerService.fetch();
  //   // await productService.subscribe();
  // }

  // late StoreServices storeService = Get.find();
  // late final isOwner = authService.isOwner;
  final isExpand = true.obs;
  final selectedIndex = 0.obs;

  late final isAdmin = true.obs;

  void toggleDrawer() {
    isExpand.value = !isExpand.value;
  }

  void handleClick(int index) {
    selectedIndex.value = index;
    switch (index) {
      case 0:
        Get.offNamed(Routes.HOME);
        break;
      case 1:
        Get.offNamed(Routes.INVOICE);
        break;
      case 2:
        Get.offNamed(Routes.CUSTOMER);
        break;
      case 3:
        Get.offNamed(Routes.PRODUCT);
        break;
      case 4:
        Get.offNamed(Routes.SALES);
        break;
      case 5:
        Get.offNamed(Routes.STATISTIC);
        break;
      default:
        Get.offNamed(Routes.PROFILE);
        break;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    Get.offNamed(Routes.LOGIN);
  }
}
