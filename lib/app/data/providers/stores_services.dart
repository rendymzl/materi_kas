import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../models/account_model.dart';
import '../models/store_model.dart';
import 'auth_services.dart';

class StoreServices extends GetxController {
  final AuthService authService = Get.find();
  final CollectionReference _storesCollection =
      FirebaseFirestore.instance.collection('stores');

  final account = Account(
    uid: '',
    ownerUid: '',
    name: '',
    email: '',
    role: '',
  ).obs;

  final isOwner = true.obs;

  var cashier = <Account>[].obs;

  Future<void> fetchStore() async {
    try {
      DocumentSnapshot docSnapshot =
          await _storesCollection.doc(authService.uid.value).get();
      if (docSnapshot.exists) {
        var customerData = docSnapshot.data() as Map<String, dynamic>;
        account.value = Account.fromJson(customerData);
      } else {
        QuerySnapshot workerQuery = await FirebaseFirestore.instance
            .collectionGroup('workers')
            .where('uid', isEqualTo: authService.uid.value)
            .get();

        if (workerQuery.docs.isNotEmpty) {
          List<Map<String, dynamic>> workerData = workerQuery.docs
              .where((doc) => doc['uid'] == authService.uid.value)
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          account.value = Account.fromJson(workerData[0]);
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
      }
      await fetchWorkers();
      isOwner.value = account.value.role == 'owner';
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchWorkers() async {
    try {
      QuerySnapshot querySnapshot = await _storesCollection
          .doc(account.value.ownerUid)
          .collection('workers')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var workersList = querySnapshot.docs
            .map((doc) => Account.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        cashier.value = workersList;
      } else {
        cashier.value = [];
      }

      // store.update((val) {
      //   val?.workers.value = workersList;
      // });
    } catch (e) {
      Get.defaultDialog(
        title: 'Error',
        middleText: e.toString(),
        // 'Terjadi kesalahan saat mengambil data kasir. Silakan coba lagi.',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }

  Future<String> getId() async {
    return _storesCollection.doc().id;
  }

  Future<void> addAccount(Account account) async {
    try {
      DocumentReference docRef = _storesCollection.doc(authService.uid.value);
      Map<String, dynamic> accountJson = account.toJson();
      await docRef.set(accountJson);
      await fetchStore();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addPromo(String textPromo) async {
    // try {
    // DocumentReference docRef = _storesCollection.doc(authService.uid.value);
    account.value.stores.value!.promo.value = textPromo;
    await updateAccount(account.value);
    // await fetchStore();
    // } catch (e) {
    //   debugPrint(e.toString());
    // }
  }

  Future<void> addCashier(Account account) async {
    try {
      DocumentReference docRef = _storesCollection
          .doc(authService.uid.value)
          .collection('workers')
          .doc(account.uid);
      Map<String, dynamic> accountJson = account.toJson();
      await docRef.set(accountJson);
      await fetchStore();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addStore(Stores stores) async {
    try {
      Map<String, Map<String, dynamic>> storesMap = {};
      storesMap['stores'] = stores.toJson();
      await _storesCollection.doc(authService.uid.value).update(storesMap);
      await fetchStore();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      Map<String, dynamic> accountJson = account.toJson();
      await _storesCollection.doc(authService.uid.value).update(accountJson);
      await fetchStore();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Future<void> deleteCustomer(String id) async {
  //   try {
  //     await _storesCollection
  //         .doc(authService.uid.value)
  //         .update({id: FieldValue.delete()});
  //     // customers.removeWhere((customer) => customer.id == id);
  //     // foundCustomers.removeWhere((customer) => customer.id == id);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // Future<void> deleteAllCustomer() async {
  //   try {
  //     await _customersCollection.doc(authService.uid.value).delete();
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // void searchCustomers(String customerName) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (customerName.isEmpty) {
  //       List<Customer> customersList = [];
  //       customersList.addAll(customers);
  //       customersList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
  //       List<Customer> subList = customersList.take(50).toList();
  //       foundCustomers.clear();
  //       foundCustomers.addAll(subList);
  //     } else {
  //       foundCustomers.value = customers.where((customer) {
  //         return customer.name!
  //             .toLowerCase()
  //             .contains(customerName.toLowerCase());
  //       }).toList();
  //     }
  //   });
  // }
}
