import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materi_kas/app/data/models/account_model.dart';

import '../../../data/models/store_model.dart';
import '../../../data/providers/customer_services.dart';
import '../../../data/providers/invoice_services.dart';
import '../../../data/providers/operating_cost_services.dart';
import '../../../data/providers/product_services.dart';
import '../../../data/providers/sales_customer_services.dart';
import '../../../data/providers/sales_invoice_services.dart';
import '../../../data/providers/stores_services.dart';
import '../../../routes/app_pages.dart';

class SetupController extends GetxController {
  late StoreServices storeService = Get.put(StoreServices());
  late ProductService productService = Get.find();
  late InvoiceService invoiceService = Get.find();
  late SalesInvoiceService salesInvoiceService = Get.find();
  late CustomerServices customerServices = Get.find();
  late SalesCustomerServices salesCustomerServices = Get.find();
  late OperatingCostServices operatingCostServices = Get.find();
  final formKey = GlobalKey<FormState>();

  final storeNameController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final storeTelpController = TextEditingController();

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

        storeService.addStore(store);

        await storeService.fetchStore();
        await productService.fetchProducts();
        await invoiceService.fetchInvoices();
        await salesCustomerServices.fetchCustomers();
        await customerServices.fetchCustomers();
        await salesInvoiceService.fetchInvoices();
        await salesInvoiceService.fetchInvoices();
        await operatingCostServices.fetchOperatingCost();

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
}
