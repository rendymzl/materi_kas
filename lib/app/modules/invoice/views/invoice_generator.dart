// Helper function to generate invoice bytes
import 'dart:typed_data';

// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../main.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/providers/stores_services.dart';
import 'generator.dart';
import 'invoice_print_controller.dart';
import 'print_column_model.dart';

var divider = Uint8List.fromList(
    '--------------------------------------------------------------------------------'
        .codeUnits);
var space = Uint8List.fromList([27, 74, 24]);

Future<List<int>> generateInvoiceBytes(Invoice invoice) async {
  StoreServices storeServices = Get.find();
  final PrinterController printerController = Get.put(PrinterController());
  late final account = storeServices.account;
  Generator generator = Generator();
  List<int> bytes = [];

  //!widht 80
  bytes += generator.row([
    PrintColumn(
        text: account.value.stores.value!.name.value.toUpperCase(),
        width: 27,
        bold: true,
        size: 'large'),
    PrintColumn(
        text: '${DateFormat('dd-MM-y', 'id').format(
          invoice.createdAt.value!.toDate(),
        )} ${invoice.invoiceId!}',
        width: 26,
        // bold: false,
        align: 'right'),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: 'Toko Bangunan',
      width: 35,
    ),
    PrintColumn(
      text: '',
      width: 2,
    ),
    PrintColumn(
      text: 'Kepada Yth.',
      width: 11,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(
        text:
            invoice.customer.value != null ? invoice.customer.value!.name! : '',
        width: 30),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: account.value.stores.value!.address.value,
      width: 35,
    ),
    PrintColumn(
      text: '',
      width: 2,
    ),
    PrintColumn(
      text: 'Alamat',
      width: 11,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(
        text: invoice.customer.value != null
            ? invoice.customer.value!.address!
            : '',
        width: 30),
  ]);

  String phone = invoice.account.value.stores.value!.phone.value;
  String telp = invoice.account.value.stores.value!.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
  bytes += generator.row([
    PrintColumn(
      text: '$phone $slash $telp',
      width: 35,
    ),
    PrintColumn(
      text: '',
      width: 2,
    ),
    PrintColumn(
      text: 'No Telp',
      width: 11,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(
        text: invoice.customer.value != null
            ? invoice.customer.value!.phone!
            : '',
        width: 30),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: 'Kasir: ${account.value.name}',
      width: 35,
    ),
  ]);

  bytes += divider;
  bytes += generator.row([
    PrintColumn(text: 'No', width: 3),
    PrintColumn(text: 'Nama Barang', width: 32),
    PrintColumn(text: 'Harga Satuan    ', width: 13, align: 'right'),
    PrintColumn(text: 'Jumlah', width: 10),
    PrintColumn(text: 'Diskon', width: 9, align: 'right'),
    PrintColumn(text: 'Total Harga', width: 13, align: 'right'),
  ]);
  bytes += divider;

  List<CartItem> purchase = printerController.filterPurchase(invoice);
  for (var i = 0; i < purchase.length; i++) {
    var item = purchase[i];
    if (item.quantity.value > 0) {
      bytes += generator.row([
        PrintColumn(text: '${i + 1}', width: 3),
        PrintColumn(text: item.product.productName, width: 32),
        PrintColumn(
            text:
                '${currency.format(item.product.getPrice(invoice.priceType.value))} x ',
            width: 13,
            align: 'right'),
        PrintColumn(
            text: '${decimal.format(item.quantity.value)} ${item.product.unit}',
            width: 10),
        PrintColumn(
            text: currency.format(item.individualDiscount.value),
            width: 9,
            align: 'right'),
        PrintColumn(
            text: currency.format(item.getSubtotal(invoice.priceType.value)),
            width: 13,
            align: 'right'),
      ]);
    }
  }
  for (var i = 0; i < 14 - purchase.length; i++) {
    bytes += space;
  }
  bytes += divider;
  bytes += generator.row([
    PrintColumn(
      text: '',
      width: 5,
    ),
    PrintColumn(
      text: 'Menerima,',
      width: 20,
    ),
    PrintColumn(
      text: 'Hormat Kami,',
      width: 20,
    ),
    PrintColumn(
      text: '',
      width: 5,
    ),
    PrintColumn(
      text: 'Subtotal',
      width: 15,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(
        text: currency.format(invoice.subtotal), width: 13, align: 'right'),
  ]);
  bytes += generator.row([
    PrintColumn(
      text: '',
      width: 50,
    ),
    PrintColumn(
      text: 'Diskon',
      width: 15,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(
        text: invoice.totalDiscount > 0
            ? '-${currency.format(invoice.totalDiscount)}'
            : '0',
        width: 13,
        align: 'right'),
  ]);
  bytes += generator.row([
    PrintColumn(
      text: '',
      width: 50,
    ),
    PrintColumn(
      text: 'Biaya Lainnya',
      width: 15,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(
        text: currency.format(invoice.totalOtherCosts),
        width: 13,
        align: 'right'),
  ]);
  bytes += generator.row([
    PrintColumn(
      text: '',
      width: 50,
    ),
    PrintColumn(
      text: 'Total',
      width: 15,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(
        text: currency.format(invoice.total), width: 13, align: 'right'),
  ]);

  bytes += space;
  bytes += generator.row([
    PrintColumn(
      text: '',
      width: 50,
    ),
    PrintColumn(
      text: 'Bayar',
      width: 15,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(
        text: currency.format(invoice.totalPaid), width: 13, align: 'right'),
  ]);
  bytes += generator.row([
    PrintColumn(
      text: '',
      width: 50,
    ),
    PrintColumn(
      text: invoice.change <= 0 ? 'Kembalian' : 'Kurang Bayar',
      width: 15,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(
        text: currency.format(invoice.change * -1), width: 13, align: 'right'),
  ]);

  bytes += [27, 69, 0]; // ESC E 0 untuk normal (non-bold)
  bytes += space;
  bytes += space;
  return bytes;
}
