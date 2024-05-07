class Customer {
  String? id;
  String? customerId;
  DateTime? createAt;
  String? name;
  String? phone;
  String? address;
  late String uuid;

  Customer(
      {this.id,
      this.customerId,
      this.createAt,
      this.name,
      this.phone,
      this.address,
      required this.uuid});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    createAt = json['create_at'] == null
        ? DateTime.now()
        : DateTime.parse(json['create_at']);
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
    uuid = json['owner_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['create_at'] = createAt;
    data['name'] = name;
    data['phone'] = phone;
    data['address'] = address;
    data['owner_id'] = uuid;
    return data;
  }
}
