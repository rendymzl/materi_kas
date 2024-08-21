// Helper function to generate invoice bytes
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../main.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/invoice_model.dart';
// import '../../../data/providers/stores_services.dart';
import '../../../widget/side_menu_controller.dart';
import 'invoice_print_controller.dart';

Future<List<int>> generateReceiptBytes(Invoice invoice) async {
  late SideMenuController sideMenuC = Get.find();
  final PrinterController printerController = Get.put(PrinterController());
  // late final account = sideMenuC.account.value;
  late final store = sideMenuC.store.value;
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);

  List<int> bytes = [];

  // Add header
  bytes += generator.text(
    store!.name.value,
    styles: const PosStyles(
      align: PosAlign.center,
      bold: true,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
    ),
  );
  bytes += generator.text(
    store.address.value,
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  String phone = store.phone.value;
  String telp = store.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
  bytes += generator.text(
    '$phone $slash $telp',
    styles: const PosStyles(
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
        invoice.createdAt.value!,
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
  if (invoice.isReturn) {
    bytes += generator.text(
      '-- Pesanan Awal --',
      styles: const PosStyles(bold: true),
    );
  }

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
      text: 'Harga',
      width: 4,
      styles: const PosStyles(bold: true, align: PosAlign.right),
    ),
  ]);
  bytes += generator.hr();
  // List<CartItem> purchase = printerController.filterPurchase(invoice);

  for (var i = 0; i < invoice.purchaseList.value.items.length; i++) {
    var item = invoice.purchaseList.value.items[i];
    // if (item.quantity.value > 0) {
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
        text:
            '    ${currency.format(item.product.getPrice(invoice.priceType.value))} x ',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: '${decimal.format(item.totalQuantity)} ${item.product.unit}',
        width: 4,
        // styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text:
            currency.format(item.getSubTotalPurchase(invoice.priceType.value)),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    // }
  }

  // Add totals
  bytes += generator.hr();
  bytes += generator.row([
    PosColumn(
      text: 'Subtotal:',
      width: 8,
    ),
    PosColumn(
      text: currency.format(invoice.subTotalPurchase),
      width: 4,
      styles: const PosStyles(align: PosAlign.right),
    ),
  ]);
  bytes += generator.row([
    PosColumn(
      text: 'Total diskon:',
      width: 8,
    ),
    PosColumn(
      text: invoice.totalDiscount > 0
          ? '-${currency.format(invoice.totalDiscount)}'
          : '0',
      width: 4,
      styles: const PosStyles(align: PosAlign.right),
    ),
  ]);
  if (invoice.totalOtherCosts > 0) {
    bytes += generator.row([
      PosColumn(
        text: 'Biaya lainnya:',
        width: 8,
      ),
      PosColumn(
        text: invoice.totalOtherCosts > 0
            ? currency.format(invoice.totalOtherCosts)
            : '0',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
  }

  bytes += generator.row([
    PosColumn(
      text: '',
      width: 8,
    ),
    PosColumn(
      text: '----------',
      width: 4,
      styles: const PosStyles(bold: true, align: PosAlign.right),
    ),
  ]);

  bytes += generator.row([
    PosColumn(
      text: 'Total tagihan:',
      width: 8,
      styles: const PosStyles(bold: true),
    ),
    PosColumn(
      text: currency.format(invoice.total),
      width: 4,
      styles: const PosStyles(bold: true, align: PosAlign.right),
    ),
  ]);

  if (invoice.isReturn) {
    bytes += generator.feed(2);
    bytes += generator.text(
      '-- Barang yang direturn --',
      styles: const PosStyles(bold: true),
    );

    bytes += generator.hr();
    List<CartItem> returned = printerController.filterReturn(invoice);
    if (invoice.returnList.value != null) {
      returned.addAll(invoice.returnList.value!.items);
    }
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
            text:
                '    ${currency.format(item.product.getPrice(invoice.priceType.value))} x ',
            width: 4,
          ),
          PosColumn(
            text:
                '${decimal.format(item.quantityReturn.value)} ${item.product.unit}',
            width: 4,
          ),
          PosColumn(
            text: currency.format(item.getTotalReturn(invoice.priceType.value)),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    }

    // Add totals
    // bytes += generator.hr();
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Total return:',
    //     width: 8,
    //   ),
    //   PosColumn(
    //     text: invoice.isReturn
    //         ? '-${currency.format(invoice.subtotalReturn)}'
    //         : '0',
    //     width: 4,
    //     styles: const PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Biaya return:',
    //     width: 8,
    //   ),
    //   PosColumn(
    //     text: currency.format(invoice.returnFee.value),
    //     width: 4,
    //     styles: const PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Total:',
    //     width: 8,
    //     styles: const PosStyles(bold: true),
    //   ),
    //   PosColumn(
    //     text: '-${currency.format(invoice.totalReturn)}',
    //     width: 4,
    //     styles: const PosStyles(bold: true, align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.feed(1);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Total setelah return:',
    //     width: 8,
    //     styles: const PosStyles(bold: true),
    //   ),
    //   PosColumn(
    //     text: currency.format(invoice.total - invoice.totalReturn),
    //     width: 4,
    //     styles: const PosStyles(bold: true, align: PosAlign.right),
    //   ),
    // ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
        text: 'Subtotal return:',
        width: 8,
        // styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: invoice.isReturn
            ? '-${currency.format((invoice.totalReturn + invoice.returnFee.value))}'
            : '0',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Biaya return:',
        width: 8,
        // styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currency.format(invoice.returnFee.value),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: '',
        width: 8,
      ),
      PosColumn(
        text: '----------',
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total return:',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: '-${currency.format(invoice.totalReturn)}',
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total tagihan:',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currency.format(invoice.totalPurchase),
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    // if (invoice.totalPaid > 0) {
    //   bytes += generator.row([
    //     PosColumn(
    //       text: 'Total pembayaran masuk:',
    //       width: 8,
    //     ),
    //     PosColumn(
    //       text: '-${currency.format(invoice.totalPaid)}',
    //       width: 4,
    //       styles: const PosStyles(align: PosAlign.right),
    //     ),
    //   ]);
    // }
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
        text: 'Total setelah return:',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currency.format(invoice.totalFinal),
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
  }

  if (!invoice.isReturn) {
    bytes += generator.row([
      PosColumn(
        text: 'Bayar:',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currency.format(invoice.totalPaid),
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
        text: invoice.change <= 0 ? 'Kembalian:' : 'Kurang Bayar:',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currency.format(invoice.change * -1),
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
  }

  bytes += generator.feed(2);
  bytes += generator.text(
    'Barang yang sudah dibeli',
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  bytes += generator.text(
    'tidak dapat ditukar/dikembalikan!',
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  bytes += generator.feed(1);
  bytes += generator.text(
    // account.value.stores.value != null
    //     ? account.value.stores.value!.promo.value ?? ''
    //     :
    '',
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  bytes += generator.feed(1);
  bytes += generator.text(
    'Terimakasih atas pembelian anda!',
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  bytes += generator.feed(3);

  return bytes;
}
