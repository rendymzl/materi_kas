import 'package:get/get.dart';

class Stores {
  String? uid;
  Rx<String> name;
  Rx<String> address;
  Rx<String> phone;
  Rx<String> telp;
  Rx<String?> promo;
  // RxList<User> workers;

  Stores({
    this.uid,
    required String name,
    required String address,
    String phone = '',
    String telp = '',
    String? promo = '',
    // List<User>? workers,
  })  : name = Rx<String>(name),
        address = Rx<String>(address),
        phone = Rx<String>(phone),
        telp = Rx<String>(telp),
        promo = Rx<String>(promo ?? '');
  // workers = RxList<User>(workers ?? [])

  Stores.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = Rx<String>(json['name']),
        address = Rx<String>(json['address']),
        phone = Rx<String>(json['phone']),
        telp = Rx<String>(json['telp']),
        promo = Rx<String>(json['promo'] ?? '');
  // workers = RxList<User>(
  //     (json['workers'] as List).map((i) => User.fromJson(i)).toList());

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name.value;
    data['address'] = address.value;
    data['phone'] = phone.value;
    data['telp'] = telp.value;
    data['promo'] = promo.value;
    // data['workers'] = workers.map((item) => item.toJson()).toList();
    return data;
  }
}
