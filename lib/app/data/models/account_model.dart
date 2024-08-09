import 'package:get/get.dart';

import 'store_model.dart';

class Account {
  String uid;
  String ownerUid;
  String name;
  String email;
  String role;
  Rx<Stores?> stores;

  Account({
    required this.uid,
    required this.ownerUid,
    required this.name,
    required this.email,
    required this.role,
    Stores? stores,
  }) : stores = Rx<Stores?>(stores);

  Account.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        ownerUid = json['owner_uid'],
        name = json['name'],
        email = json['email'],
        role = json['role'],
        stores = Rx<Stores?>(
            json['stores'] != null ? Stores.fromJson(json['stores']) : null);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['owner_uid'] = ownerUid;
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['stores'] = stores.value?.toJson();
    return data;
  }
}
