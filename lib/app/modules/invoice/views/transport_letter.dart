// Helper function to generate invoice bytes
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../main.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/providers/stores_services.dart';
import 'invoice_print_controller.dart';

Future<List<int>> generateTransportBytes(Invoice invoice) async {
  StoreServices storeServices = Get.find();
  final PrinterController printerController = Get.put(PrinterController());
  late final account = storeServices.account;
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);

  List<int> bytes = [];

  // Add header
  bytes += generator.text(
    invoice.account.value.stores.value!.name.value,
    styles: const PosStyles(
      align: PosAlign.center,
      bold: true,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
    ),
  );
  bytes += generator.text(
    invoice.account.value.stores.value!.address.value,
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  String phone = invoice.account.value.stores.value!.phone.value;
  String telp = invoice.account.value.stores.value!.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
  bytes += generator.text(
    '$phone $slash $telp',
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  bytes += generator.hr();
  bytes += generator.text(
    'SURAT JALAN',
    styles: const PosStyles(
      bold: true,
      align: PosAlign.center,
    ),
  );
  bytes += generator.hr();

  // Add invoice details
  bytes += generator.row([
    PosColumn(
      text: invoice.invoiceId!,
      width: 6,
      styles: const PosStyles(bold: true),
    ),
    PosColumn(
      text: DateFormat('dd-MM-y, HH:mm', 'id').format(
        invoice.createdAt.value!.toDate(),
      ),
      width: 6,
    ),
  ]);
  bytes += generator.row([
    PosColumn(
      text: 'Pelanggan: ${invoice.customer.value!.name}',
      width: 6,
    ),
    PosColumn(
      text: 'Kasir: ${invoice.account.value.name}',
      width: 6,
    ),
  ]);
  bytes += generator.text(
    'No Telp: ${invoice.customer.value!.phone}',
    styles: const PosStyles(
        // align: PosAlign.center,
        ),
  );
  bytes += generator.text(
    'Alamat: ${invoice.customer.value!.address}',
    styles: const PosStyles(
        // align: PosAlign.center,
        ),
  );
  bytes += generator.feed(1);

  // Add items
  bytes += generator.hr();
  bytes += generator.row([
    PosColumn(
      text: 'No',
      width: 1,
      styles: const PosStyles(bold: true),
    ),
    PosColumn(
      text: 'Nama Barang',
      width: 7,
      styles: const PosStyles(bold: true),
    ),
    PosColumn(
      text: '',
      width: 4,
      styles: const PosStyles(bold: true, align: PosAlign.right),
    ),
  ]);
  bytes += generator.hr();
  List<CartItem> purchase = printerController.filterPurchase(invoice);

  for (var i = 0; i < purchase.length; i++) {
    var item = purchase[i];
    if (item.quantity.value > 0) {
      bytes += generator.row([
        PosColumn(
          text: '${i + 1}',
          width: 1,
        ),
        PosColumn(
          text: item.product.productName,
          width: 7,
        ),
        PosColumn(
          text: '',
          width: 4,
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '${decimal.format(item.quantity.value)} ${item.product.unit}',
          width: 4,
          // styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
  }

  // Add totals
  bytes += generator.hr();

  bytes += generator.feed(2);
  if (invoice.totalReturn > 0) {
    bytes += generator.row([
      PosColumn(
        text: 'Barang yang direturn:',
        width: 8,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
      PosColumn(
        text: '',
        width: 4,
      ),
    ]);
    bytes += generator.hr();
    List<CartItem> returned = printerController.filterReturn(invoice);
    for (var i = 0; i < returned.length; i++) {
      var item = returned[i];
      if (item.quantityReturn.value > 0) {
        bytes += generator.row([
          PosColumn(
            text: '${i + 1}',
            width: 1,
          ),
          PosColumn(
            text: item.product.productName,
            width: 7,
          ),
          PosColumn(
            text: '',
            width: 4,
          ),
        ]);
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 4,
          ),
          PosColumn(
            text:
                '${decimal.format(item.quantityReturn.value)} ${item.product.unit}',
            width: 4,
          ),
          PosColumn(
            text: '',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    }
  }

  bytes += generator.feed(3);

  return bytes;
}
