// import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'stores_services.dart';

// class AuthService extends GetxController {
//   late StoreServices storeService = Get.put(StoreServices());
//   final isLoggedIn = false.obs;
//   final uid = ''.obs;
//   // late final account = storeService.account.value.role;

//   @override
//   void onInit() {
//     super.onInit();
//     checkLoginStatus();
//   }

//   // bool get isOwner {
//   //   debugPrint(account);
//   //   return account == 'owner';
//   // }

//   void checkLoginStatus() {
//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       if (user == null) {
//         uid.value = '';
//         isLoggedIn.value = false;
//       } else {
//         uid.value = user.uid; // Simpan UID pengguna
//         isLoggedIn.value = true;
//       }
//     });
//   }

//   Future<void> signOut() async {
//     await FirebaseAuth.instance.signOut();
//     isLoggedIn.value = false;
//     uid.value = '';
//   }
// }
