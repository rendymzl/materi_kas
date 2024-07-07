import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService extends GetxController {
  final isLoggedIn = false.obs;
  final uid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        uid.value = '';
        isLoggedIn.value = false;
      } else {
        uid.value = user.uid; // Simpan UID pengguna
        isLoggedIn.value = true;
        debugPrint(user.uid);
      }
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    isLoggedIn.value = false;
    uid.value = '';
  }
}
