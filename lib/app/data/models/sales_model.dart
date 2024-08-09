import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../providers/sales_invoice_services.dart';
import 'sales_invoice_model.dart';

class Sales {
  String? id;
  String? salesId;
  Timestamp? createdAt;
  String? name;
  String? phone;
  String? address;
  // late String uuid;

  Sales({
    this.id,
    this.salesId,
    this.createdAt,
    this.name,
    this.phone,
    this.address,
    // required this.uuid,
  });

  Sales.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    salesId = json['sales_id'];
    createdAt = json['created_at'];
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
    // uuid = json['owner_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['sales_id'] = salesId;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['phone'] = phone;
    data['address'] = address;
    // data['owner_id'] = uuid;
    return data;
  }

  // late SalesInvoiceService salesInvoiceSecvice = Get.find();
  // late final salesInvoices = salesInvoiceSecvice.invoices;

  List<SalesInvoice> getInvoiceListBySalesId(List<SalesInvoice> salesInvoices) {
    return salesInvoices
        .where((invoice) =>
            invoice.sales.value?.id?.toLowerCase() == id!.toLowerCase())
        .toList();
  }

  double getTotalDebt(List<SalesInvoice> salesInvoices) {
    double totalDebt = getInvoiceListBySalesId(salesInvoices)
        .fold(0, (prev, invoice) => prev + invoice.remainingDebt);

    return totalDebt;
  }
}
