import 'package:cloud_firestore/cloud_firestore.dart';

class OperatingCost {
  String? id;
  Timestamp? createdAt;
  String? name;
  int? amount;
  String? note;

  OperatingCost({
    this.id,
    this.createdAt,
    this.name,
    this.amount,
    this.note,
  });

  OperatingCost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    name = json['name'];
    amount = json['amount'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['amount'] = amount;
    data['note'] = note;
    return data;
  }
}
