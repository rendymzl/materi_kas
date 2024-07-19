import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  String? id;
  String? customerId;
  Timestamp? createdAt;
  String? name;
  String? phone;
  String? address;
  // late String uuid;

  Customer({
    this.id,
    this.customerId,
    this.createdAt,
    this.name,
    this.phone,
    this.address,
    // required this.uuid,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    createdAt = json['created_at'];
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
    // uuid = json['owner_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['phone'] = phone;
    data['address'] = address;
    // data['owner_id'] = uuid;
    return data;
  }
}
