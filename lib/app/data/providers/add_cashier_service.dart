import 'package:get/get.dart';

class AddCashier extends GetConnect {
  static const String url =
      'http://localhost:3000'; // Ganti dengan URL server Anda

  Future<Map<String, dynamic>> createAccount(
      String email, String password, String ownerUid) async {
    final response = await post(
      '$url/createAccount',
      {
        'email': email,
        'password': password,
        'ownerUid': ownerUid,
      },
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.status.hasError) {
      throw Exception('Failed to create account: ${response.statusText}');
    } else {
      return response.body;
    }
  }
}
